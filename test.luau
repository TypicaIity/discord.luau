--!strict
--!optimize 2

local fs = (require)("@lune/fs")
local task = (require)("@lune/task")
local serde = (require)("@lune/serde")

local discord = require("./discord.lua/init")

local bot = discord.Client({
	selfbot = false
}) :: any

local config = serde.decode("json", fs.readFile("config.json"))

bot:on("READY", function()
	print(`logged in as {bot.user.username}`)
end)

bot:on("MESSAGE_CREATE", function(message)
	if message.author.bot then return end

	print(message.__raw)
end)

bot:login(config.token)
