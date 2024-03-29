local pl_manager = require("plugin_management")
local config = require("config")
local utils = {}

-- Parses the plugin name from a string
function utils.parse_plugin_name(str)
	local plugin_name = str:match("\".-/(.-)\"")
	return plugin_name
end

function utils.find_plugin_path(plugin_name)
	for _, base_path in ipairs(config.plugin_paths) do
		local plugin_path = base_path .. "/" .. plugin_name
		if vim.fn.isdirectory(plugin_path) ~= 0 then
			return plugin_path
		end
	end
	vim.notify(
		"plugin folder not found for " .. plugin_name,
		vim.log.levels.error
	)
	return nil
end

-- function to get the remote url from the .git/config file
function utils.get_git_remote_url(plugin_path)
	local git_config_path = plugin_path .. "/.git/config"
	local git_config = io.open(git_config_path, "r")

	if git_config then
		local is_remote_origin_section = false
		for line in git_config:lines() do
			if line:match("%[remote \"origin\"%]") then
				is_remote_origin_section = true
			elseif is_remote_origin_section and line:match("url =") then
				git_config:close()
				return line:match("url = (.+)")
			elseif line:match("%[") then
				is_remote_origin_section = false
			end
		end
		git_config:close()
	end

	return nil
end

-- function for autocompleting plugin names
function utils.complete_plugin_names(arg_lead)
	local plugins = pl_manager.get_installed_plugins()
	local matches = {}
	for _, plugin in ipairs(plugins) do
		if plugin:find(arg_lead) == 1 then
			table.insert(matches, plugin)
		end
	end
	return matches
end

-- Determines the OS-specific command to open URLs
function utils.get_open_command()
	if vim.fn.has("mac") == 1 then
		return "open"
	elseif vim.fn.has("unix") == 1 then
		return "xdg-open"
	elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
		return "start"
	end
	return nil -- In case the OS is not recognized
end

return utils
