function add()
	print('add')
end

function addf()
	print("addf")
end

function help()
	print("help*")
end

commands = {
	['help'] = help,
	['add'] = add,
	['addf'] = addf
}

function run(...)
	command = commands[table.unpack(...)]
	if command then
		return command()
	end
	return commands.help()
end

run(arg)
