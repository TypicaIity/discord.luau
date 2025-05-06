--!strict
--!optimize 2

local fs = (require)("@lune/fs")
local serde = (require)("@lune/serde")

local discord = require("./discord.lua/init")

local client = discord.Client({
	selfclient = false
}) :: any

local config = serde.decode("json", fs.readFile("config.json"))

client:on("READY", function()
	print(`logged in as {client.user.username}`)
end)

client:on("MESSAGE_CREATE", function(message)
	if message.author.client then return end
	
	print(client.cache.channels["1092181486217728173"]:fetchMessages(5))
end)

client:login(config.token)
