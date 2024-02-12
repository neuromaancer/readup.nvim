local utils = require("utils")
local config = require("config")

local readme_handling = {}

function readme_handling.find_readme_path(plugin_name)
	local readme_filenames = {
		"README.md",
		"README.markdown",
		"README.txt",
		"readme.md",
		"readme.markdown",
		"readme.txt",
		"README",
		"readme",
	}
	for _, base_path in ipairs(config.plugin_paths) do
		local plugin_path = base_path .. "/" .. plugin_name
		for _, filename in ipairs(readme_filenames) do
			local readme_path = plugin_path .. "/" .. filename
			if vim.fn.filereadable(readme_path) == 1 then
				return readme_path
			end
		end
	end
	vim.notify("README not found for " .. plugin_name, vim.log.levels.ERROR)
	return nil
end

function readme_handling.open_in_float(readme_path)
	local lines = vim.fn.readfile(readme_path)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	local width = math.ceil(vim.o.columns * 0.7)
	local height = math.ceil(vim.o.lines * 0.7)
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = math.ceil((vim.o.columns - width) / 2),
		row = math.ceil((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
	}
	vim.api.nvim_open_win(buf, true, opts)
	vim.wo.conceallevel = 3
end

function readme_handling.open_readme_in_browser(plugin_name, readme_path)
	local open_cmd = utils.get_open_command()
	if open_cmd then
		local browser_url = utils
			.get_git_remote_url(readme_path)
			:gsub("%.git$", "") .. "/blob/master/README.md"
		os.execute(open_cmd .. " " .. browser_url)
	else
		vim.notify("Unsupported OS for opening URLs", vim.log.levels.ERROR)
	end
end

function readme_handling.open_readme(plugin_name)
	local readme_path = readme_handling.find_readme_path(plugin_name)
	if readme_path then
		if config.open_in_browser then
			readme_handling.open_readme_in_browser(plugin_name, readme_path)
		elseif config.float then
			readme_handling.open_in_float(readme_path)
		else
			vim.api.nvim_command("edit " .. readme_path)
			vim.wo.conceallevel = 3
		end
	else
		vim.notify("readme not found for " .. plugin_name, vim.log.levels.error)
	end
end

return readme_handling
