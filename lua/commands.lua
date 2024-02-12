local readme_handling = require("readme_handling")
local utils = require("utils")

local commands = {}

function commands.setup_commands()
	vim.api.nvim_create_user_command("Readup", function(opts)
		local plugin_name = utils.parse_plugin_name(opts.args)
		readme_handling.open_readme(plugin_name)
	end, { nargs = 1, complete = utils.complete_plugin_names })

	vim.api.nvim_create_user_command("ReadupCursor", function()
		local current_line = vim.api.nvim_get_current_line()
		print("current_line:")
		print(current_line)
		local plugin_name = utils.parse_plugin_name(current_line)
		readme_handling.open_readme(plugin_name)
	end, {})

	vim.api.nvim_create_user_command("ReadupBrowser", function(opts)
		local plugin_name = utils.parse_plugin_name(opts.args)
		local readme_path = readme_handling.find_readme_path(plugin_name)
		if readme_path then
			readme_handling.open_readme_in_browser(plugin_name)
		end
	end, { nargs = 1, complete = utils.complete_plugin_names })
end

return commands
