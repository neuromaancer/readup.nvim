local M = {}

-- Configuration: path to the plugins directory
local plugins_folder = vim.fn.stdpath("data") .. "/lazy"

-- Function to retrieve a list of installed plugins
local function get_installed_plugins()
	local plugins = {}
	local command = "ls " .. plugins_folder
	local p, err = io.popen(command)
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

-- Function to parse the plugin name from a string
local function parse_plugin_name(str)
	if str:find("/") then
		local _, plugin_name = str:match("([^/]+)/([^/]+)")
		return plugin_name
	else
		return str
	end
end

-- Function to get the remote URL from the .git/config file
local function get_git_remote_url(plugin_path)
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

-- Function to download the README file
local function download_readme(plugin_path)
	local remote_url = get_git_remote_url(plugin_path)

	if remote_url then
		local url = remote_url:gsub("%.git$", "") .. "/raw/master/README.md"
		local download_path = plugin_path .. "/README.md"
		vim.fn.system("curl -fLo " .. download_path .. " --create-dirs " .. url)
		return vim.fn.filereadable(download_path) == 1
	else
		return false
	end
end

-- Function to open various README file formats
local function open_readme(plugin_name)
	local plugin_path = plugins_folder .. "/" .. plugin_name
	local readme_filenames =
		{ "README.md", "README.markdown", "README.txt", "readme.md" }

	for _, filename in ipairs(readme_filenames) do
		local readme_path = plugin_path .. "/" .. filename
		if vim.fn.filereadable(readme_path) == 1 then
			vim.api.nvim_command("edit " .. readme_path)
			return
		end
	end

	if download_readme(plugin_path) then
		vim.api.nvim_command("edit " .. plugin_path .. "/README.md")
	else
		vim.notify(
			"README not found and could not be downloaded for " .. plugin_name,
			vim.log.levels.ERROR
		)
	end
end

-- Function to handle the Readup command
function M.readup(plugin_string)
	local plugin_name = parse_plugin_name(plugin_string)
	open_readme(plugin_name)
end

-- Function to handle Readup command when invoked from the cursor position
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

-- Function for autocompleting plugin names
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

-- Function to set up Neovim commands
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
