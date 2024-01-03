local utils = {}

-- Parses the plugin name from a string
function utils.parse_plugin_name(str)
	if str:find("/") then
		return str:match("([^/]+)/([^/]+)$")
	else
		return str
	end
end

-- Gets the remote URL from the .git/config file
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
