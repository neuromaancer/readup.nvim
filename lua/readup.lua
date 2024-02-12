local config = require("config")
local commands = require("commands")

local M = {}

function M.setup(user_config)
	user_config = config.setup(user_config) or {}
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
	commands.setup_commands()
end

return M
