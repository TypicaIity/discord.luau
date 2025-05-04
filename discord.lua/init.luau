--!strict
--!optimize 2

local discord = {}

local Client = require("./classes/Client")

function discord.Client(config: Client.ClientConfig)
	return Client.new(config)
end

return discord
