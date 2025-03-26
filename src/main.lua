local lfs = require 'lfs'
local BRUCE_VAULT_PATH = '/tmp/.bruce-vault/'
local GPG_IDS_FILE = BRUCE_VAULT_PATH .. '.gpg-history'

function init()
	if os.execute('ls ' .. BRUCE_VAULT_PATH .. ' > /dev/null') == nil then
		os.execute('mkdir ' .. BRUCE_VAULT_PATH)
		print('Bruce Vault created')
		return 
	end
	
	print('Bruce Vault already exists.')
end

function encrypt(data, credential_path, gpg_id)
	os.execute('echo "' .. data .. '" > ' .. credential_path)
	os.execute(string.format(
		'gpg --yes --output %s.gpg -r %s -e %s', 
		credential_path, gpg_id, credential_path)
	)
		
	os.execute('rm ' .. credential_path)
end

function verifyFile(file)
	local attr = lfs.attributes(file .. '.gpg')
	return attr and attr.mode == "file"
end

function showCredentialStatus(credential_path)
	if verifyFile(credential_path) then
		print('\nCredential added successfully')
	else
		print("\nCould not add the credential")
	end
end 

function add(...)
	local args = ...
	
	if #args ~= 2 and #args ~= 3 then
		--[[
			args = {
				[1] = credential
				or
				[1] = credential,
				[2] = gpg_id,
				[3] = bla,
				[4] = bla
				et cetera
			}
		]]--
		return print(
			'usage: bruce add [--print, -p || --open-editor, -op]' ..
			' <credential || folder/credential> <gpg_id>'
			)
	end
	
	if #args == 2 then
		--[[
			args = {
				[1] = credential,
				[2] = gpg_id
			}
		]]--
		
		local credential = args[1]
		local gpg_id = args[2]
		local password = ''
		local credential_path = BRUCE_VAULT_PATH .. credential
		
		print('Enter the password for ' .. credential .. ': ')
		
		os.execute('stty -echo')
		password = io.read()
		os.execute('stty echo')
		io.flush()
		
		encrypt(password, credential_path, gpg_id)
		return showCredentialStatus(credential_path)
	end
	
	if #args == 3 then
		--[[
			args = {
				[1] = --print, -p or --open-editor, -op,
				[2] = credential,
				[3] = gpg_id
			}		
		]]--

		local option = args[1]
		local credential = args[2]
		local gpg_id = arg[3]
		local credential_path = BRUCE_VAULT_PATH .. credential
		
		if option == '--print' or option == '-p' then
			print('Enter the password for ' .. credential .. ': ')
			
			password = io.read()
			encrypt(password, credential_path, gpg_id)
			return showCredentialStatus(credential_path)
			
		elseif option == '--open-editor' or option == '-op' then
			print(
				'Enter the password for ' 
				.. credential .. 
				': (Ctrl + D when finished)'
			)
			
			data = io.read('*a')
			encrypt(data, credential_path, gpg_id)
			return showCredentialStatus(credential_path)
			
		end
		
		print('Invalid option.')
	end
end

function show(...)
	local credential = ...
	credential = credential[1]
	if credential == nil then
		return print('usage: bruce show <credential>')
	end
	os.execute(string.format('gpg --decrypt %s%s.gpg 2>/dev/null | cat', BRUCE_VAULT_PATH, credential))
end

function ls()
	os.execute('tree -a -C '..BRUCE_VAULT_PATH)
end

function getDirs(path)
	local dirs = {}
	table.insert(dirs, BRUCE_VAULT_PATH)
	for file in lfs.dir(path) do
		if file ~= '.' and file ~= '..' then
			local full_path = path .. file
			if lfs.attributes(full_path, 'mode') == 'directory' then
				table.insert(dirs, full_path..'/')
			end
		end
	end
	return dirs
end

function find(...)
	local credential = ...
	credential = credential[1]
	if credential == nil then
		return print('usage: bruce find <credential>')
	end
	local dirs = getDirs(BRUCE_VAULT_PATH)
	for _, dir in ipairs(dirs) do
		if verifyFile(dir..credential) then
			 return os.execute('ls '..dir..credential..'.gpg')
		end
	end
	print('No such credential')
end

function remove(...)
	local credential = ...
	credential = credential[1]
	if credential == nil then
		return print('usage: bruce remove <credential>')
	end
	local dirs = getDirs(BRUCE_VAULT_PATH)
	for _, dir in ipairs(dirs) do
		if verifyFile(dir..credential) then
			return os.execute('rm '..dir..credential..'.gpg')
		end
	end
	print('No such credential')
end

function help(...)
	print(
	[[
	bruce init -> 
		Initalize the Bruce Vault
	bruce add [--print, -p || --open-editor, -op] <credential || folder/credential> <gpg_id> -> 
		Add or update a credential into bruce vault
	bruce help ->
		Show this help message
	bruce show <credential> ->
		Show the data of a specific credential
	bruce ls ->
		Show all credentials into bruce vault
	bruce find <credential> ->
		Returns the location of the credential inside the bruce vault (always shows the first occurrence)
	bruce remove <credential> ->
		Removes the required credential 
	]]	
	)
end

commands = {
	['init'] = init,
	['help'] = help,
	['add'] = add,
	['show'] = show,
	['ls'] = ls,
	['find'] = find,
	['remove'] = remove,
}

function run(...)
	local command = commands[table.unpack(...)]
	if command then
		local args = ...
		table.remove(args, 1)
		return command(args)
	end
	return commands.ls()
end

run(arg)
