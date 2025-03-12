-- gpg --decrypt /tmp/.bruce-vault/credential.gpg | cat

local BRUCE_VAULT_PATH = '/tmp/.bruce-vault/'
local GPG_IDS_FILE 	= BRUCE_VAULT_PATH .. '.gpg-history'

function init()
	if os.execute('ls ' .. BRUCE_VAULT_PATH) == nil then
		os.execute('mkdir ' .. BRUCE_VAULT_PATH)
		print('Bruce Vault created')
		return 
	end
	
	print('Bruce Vault already exists.')
end

function add(...)
	local args = ...
	
	if #args ~= 3 and #args ~= 4 then
		--[[
			args = {
				[1] = add
				or
				[1] = add,
				[2] = credential
				or
				[1] = add,
				[2] = credential,
				[3] = gpg_id,
				[4] = bla,
				[5] = bla
				et cetera
			}
		]]--
		return
	end
	
	if #args == 3 then
		--[[
			args = {
				[1] = add,
				[2] = credential,
				[3] = gpg_id
			}
		]]--
		
		local credential = args[2]
		local gpg_id = args[3]
		local password = ''
		local credential_path = BRUCE_VAULT_PATH .. credential
		
		io.write('Enter the password for ' .. credential .. ': ')
		password = io.read()
		
		os.execute('echo ' .. password .. ' > ' .. credential_path)
		os.execute(string.format(
			'gpg --yes --output %s.gpg -r %s -e %s', 
			credential_path, gpg_id, credential_path)
		)
		os.execute('rm ' .. credential_path)
		
		print('Credential added successfully')
		return
	end
	
	if #args == 4 then
		--[[
			args = {
				[1] = add,
				[2] = --print, -p or --open-editor, -op,
				[3] = password,
				[4] = gpg_id
			}		
		]]--
	end
end

function addf(...)
	print("addf")
end

function help(...)
	print("help*")
end

commands = {
	['init'] = init,
	['help'] = help,
	['add'] = add,
	['addf'] = addf
}

function run(...)
	local command = commands[table.unpack(...)]
	if command then
		return command(...)
	end
	return commands.help()
end

run(arg)
