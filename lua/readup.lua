local M = {}

-- Configuration: path to the plugins directory
local plugins_folder = vim.fn.stdpath("data") .. "/lazy"

-- Retrieves a list of installed plugins
local function get_installed_plugins()
	local plugins = {}
	local p, err = io.popen("ls " .. plugins_folder)
	if not p then
		vim.notify(
			"Failed to open plugins directory: " .. err,
			vim.log.levels.ERROR
		)
		return plugins
	end
	for plugin in p:lines() do
		table.insert(plugins, plugin)
	end
	p:close()
	return plugins
end

-- Parses the plugin name from a given string
local function parse_plugin_name(str)
	if str:find("/") then
		local _, plugin_name = str:match("([^/]+)/([^/]+)")
		return plugin_name
	else
		return str
	end
end

-- Opens the README.md file of a given plugin in a new buffer
local function open_readme(plugin_name)
	local readme_path = plugins_folder .. "/" .. plugin_name .. "/README.md"

	local f = io.open(readme_path, "r")
	if f then
		io.close(f)
		vim.api.nvim_command("edit " .. readme_path)
	else
		vim.notify(
			"README.md not found for " .. plugin_name,
			vim.log.levels.ERROR
		)
	end
end

-- Main function to handle the Readup command
function M.readup(plugin_string)
	local plugin_name = parse_plugin_name(plugin_string)
	open_readme(plugin_name)
end

-- Function to handle Readup command when invoked from the current cursor position
function M.readup_from_cursor()
	local current_line = vim.api.nvim_get_current_line()
	local plugin_name = parse_plugin_name(current_line)
	if plugin_name then
		open_readme(plugin_name)
	else
		vim.notify(
			"No valid plugin name found on the current line",
			vim.log.levels.INFO
		)
	end
end

-- Autocompletion function for plugin names
function M.complete_plugin_names(arg_lead, cmd_line, cursor_pos)
	local plugins = get_installed_plugins()
	local matches = {}
	for _, plugin in ipairs(plugins) do
		if plugin:find(arg_lead) == 1 then
			table.insert(matches, plugin)
		end
	end
	return matches
end

-- Setup function to initialize Neovim commands
function M.setup()
	vim.api.nvim_create_user_command("Readup", function(opts)
		M.readup(opts.args)
	end, {
		nargs = 1,
		complete = M.complete_plugin_names,
	})

	vim.api.nvim_create_user_command("ReadupCursor", M.readup_from_cursor, {})
end

return M
