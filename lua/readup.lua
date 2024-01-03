local M = {}

local config = {
	plugin_manager = "lazy",
	plugin_paths = {},
	float = false, -- default to false; set to true to open readme in a floating window.
	open_in_browser = false, -- default to false
}

-- function to retrieve a list of installed plugins
local function get_installed_plugins()
	local plugins = {}

	for _, path in ipairs(config.plugin_paths) do
		if vim.fn.isdirectory(path) ~= 0 then
			local p, err = io.popen("ls " .. path)
			if p then
				for plugin in p:lines() do
					table.insert(plugins, plugin)
				end
				p:close()
			else
				vim.notify(
					"failed to list plugins in directory: "
						.. path
						.. " - "
						.. err,
					vim.log.levels.error
				)
			end
		end
	end

	return plugins
end

-- function to parse the plugin name from a string
local function parse_plugin_name(str)
	if str:find("/") then
		local _, plugin_name = str:match("([^/]+)/([^/]+)")
		return plugin_name
	else
		return str
	end
end

-- function to get the remote url from the .git/config file
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

local function get_open_command()
	if vim.fn.has("mac") == 1 then
		return "open"
	elseif vim.fn.has("unix") == 1 then
		return "xdg-open"
	elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
		return "start"
	end
	return nil -- In case the OS is not recognized
end

function M.open_readme_in_browser(plugin_name, plugin_path)
	local remote_url = get_git_remote_url(plugin_path)
	if remote_url then
		local browser_url = remote_url:gsub("%.git$", "")
			.. "/blob/master/README.md"
		local open_cmd = get_open_command()
		if open_cmd then
			os.execute(open_cmd .. " " .. browser_url)
		else
			vim.notify("Unsupported OS for opening URLs", vim.log.levels.ERROR)
		end
	else
		vim.notify(
			"Cannot find the remote URL for " .. plugin_name,
			vim.log.levels.ERROR
		)
	end
end

-- function to download the readme file
local function download_readme(plugin_path)
	local remote_url = get_git_remote_url(plugin_path)

	if remote_url then
		local url = remote_url:gsub("%.git$", "") .. "/raw/master/README.md"
		local download_path = plugin_path .. "/README.md"
		vim.fn.system("curl -flo " .. download_path .. " --create-dirs " .. url)
		return vim.fn.filereadable(download_path) == 1
	else
		return false
	end
end

local function open_in_float(readme_path)
	-- logic to open readme in a floating window
	local lines = vim.fn.readfile(readme_path)

	-- create a new buffer for the floating window
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- define the floating window size and position
	local width = math.ceil(vim.o.columns * 0.7)
	local height = math.ceil(vim.o.lines * 0.7)
	local col = math.ceil((vim.o.columns - width) / 2)
	local row = math.ceil((vim.o.lines - height) / 2)

	-- define window options
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}

	-- open the floating window
	vim.api.nvim_open_win(buf, true, opts)
	vim.wo.conceallevel = 3
end

local function find_plugin_path(plugin_name)
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

-- function to open various readme file formats
local function find_readme_path(plugin_name)
	local readme_filenames =
		{ "README.md", "README.markdown", "README.txt", "readme.md" }
	local plugin_path = find_plugin_path(plugin_name)
	if plugin_path == nil then
		return nil
	end
	for _, filename in ipairs(readme_filenames) do
		local readme_path = plugin_path .. "/" .. filename
		if vim.fn.filereadable(readme_path) == 1 then
			return readme_path
		end
	end
	vim.notify("readme not found for " .. plugin_name, vim.log.levels.error)
end

local function open_readme(plugin_name)
	local readme_path = find_readme_path(plugin_name)
	if readme_path then
		if config.open_in_browser then
			M.open_readme_in_browser(plugin_name, readme_path)
		elseif config.float then
			open_in_float(readme_path)
		else
			vim.api.nvim_command("edit " .. readme_path)
			vim.wo.conceallevel = 3
		end
	else
		vim.notify("readme not found for " .. plugin_name, vim.log.levels.error)
	end
end

-- function to handle the readup command
function M.readup(plugin_string)
	local plugin_name = parse_plugin_name(plugin_string)
	open_readme(plugin_name)
end

-- function to handle readup command when invoked from the cursor position
function M.readup_from_cursor()
	local current_line = vim.api.nvim_get_current_line()
	local plugin_name = parse_plugin_name(current_line)
	if plugin_name then
		open_readme(plugin_name)
	else
		vim.notify(
			"no valid plugin name found on the current line",
			vim.log.levels.info
		)
	end
end

-- function for autocompleting plugin names
function M.complete_plugin_names(arg_lead)
	local plugins = get_installed_plugins()
	local matches = {}
	for _, plugin in ipairs(plugins) do
		if plugin:find(arg_lead) == 1 then
			table.insert(matches, plugin)
		end
	end
	return matches
end

function M.setup_commands()
	vim.api.nvim_create_user_command("Readup", function(opts)
		M.readup(opts.args)
	end, {
		nargs = 1,
		complete = M.complete_plugin_names,
	})

	vim.api.nvim_create_user_command("ReadupCursor", M.readup_from_cursor, {})
	vim.api.nvim_create_user_command("ReadupBrowser", function(opts)
		local plugin_name = parse_plugin_name(opts.args)
		local plugin_path = find_plugin_path(plugin_name)
		M.open_readme_in_browser(plugin_name, plugin_path)
	end, {
		nargs = 1,
		complete = M.complete_plugin_names,
	})
end

function M.setup(user_config)
	user_config = user_config or {}
	local manager = user_config.plugin_manager or "lazy" -- default to 'lazy'
	config.float = user_config.float or false

	if manager == "packer" then
		config.plugin_paths = {
			vim.fn.stdpath("data") .. "/site/pack/packer/start/",
			vim.fn.stdpath("data") .. "/site/pack/packer/opt/",
		}
	elseif manager == "lazy" then
		config.plugin_paths = {
			vim.fn.stdpath("data") .. "/lazy",
		}
	end
	M.setup_commands()
end

return M
