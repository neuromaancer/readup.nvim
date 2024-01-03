local config = {
	plugin_manager = "lazy", -- Default plugin manager
	plugin_paths = {}, -- Paths to plugins
	float = false, -- Open readme in floating window
	open_in_browser = false, -- Open readme in browser
}

function config.setup(user_config)
	user_config = user_config or {}
	for key, value in pairs(user_config) do
		if config[key] ~= nil then
			config[key] = value
		end
	end
end

return config
