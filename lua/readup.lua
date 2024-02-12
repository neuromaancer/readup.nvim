local config = require("config")
local commands = require("commands")

local M = {}

function M.setup(user_config)
	config.setup(user_config)
	commands.setup_commands()
end

return M
