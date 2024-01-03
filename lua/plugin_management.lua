local config = require("config") -- Replace with actual path to your config module

local plugin_management = {}

-- Retrieves a list of installed plugins
function plugin_management.get_installed_plugins()
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
					"Failed to list plugins in directory: "
						.. path
						.. " - "
						.. err,
					vim.log.levels.ERROR
				)
			end
		end
	end
	return plugins
end

return plugin_management
