local M = {}

M.plugins_folder = vim.fn.stdpath("data") .. "/lazy"

-- Updated parser function to handle both full and short plugin names
local function parse_plugin_name(str)
	if str:find("/") then
		-- Extracts the plugin name from "author/plugin_name" format
		local _, plugin_name = str:match("([^/]+)/([^/]+)")
		return plugin_name
	else
		-- If only the plugin name is provided
		return str
	end
end

function M.readup_from_cursor()
	local current_line = vim.api.nvim_get_current_line()
	local plugin_name = parse_plugin_name(current_line)
	if plugin_name then
		M.readup(plugin_name)
	else
		vim.notify(
			"No valid plugin name found on the current line",
			vim.log.levels.INFO
		)
	end
end

-- Function to get a list of installed plugins
local function get_installed_plugins()
	local plugins = {}
	local p, err = io.popen("ls " .. M.plugins_folder)
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

M.readup = function(plugin_string)
	local plugin_name = parse_plugin_name(plugin_string)
	local plugin_path = M.plugins_folder .. "/" .. plugin_name
	local readme_path = plugin_path .. "/README.md"

	-- Check if README.md exists
	local f = io.open(readme_path, "r")
	if f ~= nil then
		io.close(f)
		-- Open README.md in a new buffer
		vim.api.nvim_command("edit " .. readme_path)
	else
		vim.notify(
			"README.md not found for " .. plugin_name,
			vim.log.levels.ERROR
		)
	end
end
-- Function to get a list of installed plugins for autocomplete

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

function M.setup_command()
	vim.api.nvim_create_user_command("Readup", function(opts)
		M.readup(opts.args)
	end, {
		nargs = 1,
		complete = M.complete_plugin_names,
	})
	vim.api.nvim_create_user_command("ReadupCursor", M.readup_from_cursor, {})
end

function M.setup()
	M.setup_command()
end

return M
