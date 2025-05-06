--!strict
--!optimize 2

local discord = {}

local api = require("./API")
local Client = require("./classes/Client")

function discord.Client(config: Client.ClientConfig)
	return Client.new(config)
end

discord.REST = api

return discord
