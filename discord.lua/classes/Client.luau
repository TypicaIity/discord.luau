--!strict
--!optimize 2

local Client = {}
Client.__index = Client

local api = require("../API")
local util = require("../util")
local comp = require("../compatability")

local User = require("./User")
local Guild = require("./Guild")
local Message = require("./Message")

export type ClientConfig = {
	selfbot: boolean?,
	intents: number?
}

local PROCESSORS = {
	MESSAGE_CREATE = function(self, data: { [string]: any }): Message
		local message = Message.new(data, self.__auth) :: any
		message.guild = self.cache.guilds[message.guildId]
		return message
	end,
	READY = function(self, data: { [string]: any }): any
		self.user = User.new(data.user, self.__auth)
		return nil
	end,
	GUILD_CREATE = function(self, data: { [string]: any }): any
		local guild = Guild.new(data, self.__auth)
		for _, chan in guild.channels do
			self.cache.channels[chan.id] = chan
		end
		self.cache.guilds[data.id] = guild
		return guild
	end
}

local OP_HEARTBEAT	= 1
local OP_IDENTIFY	= 2
local OP_HELLO		= 10

local function checkconfig(config: ClientConfig): ()
	assert(type(config.selfbot) == "boolean" or config.selfbot == nil, `invalid configuration to '{debug.info(2, "n")}' (.selfbot must be a boolean or nil)`)
	assert(type(config.intents) == "number" or config.intents == nil, `invalid configuration to '{debug.info(2, "n")}' (.intents must be a number or nil)`)
	config.selfbot = if config.selfbot == nil then false else config.selfbot
	config.intents = if config.intents == nil then 53608447 else config.intents
end

function Client.new(config: ClientConfig)
	checkconfig(util.tca(1, config, "table"))

	return setmetatable({
		__auth = nil,
		__config = {
			selfbot = if config.selfbot == nil then false else config.selfbot,
			intents = if config.intents == nil then 53608447 else config.intents
		},
		__handlers = {}
	}, Client)
end

function Client:login(token: string): ()
	util.tca(1, token, "string")

	self.__auth = `{if self.__config.selfbot == true then "" else "Bot "}{token}`
	self.cache = {
		channels = setmetatable({}, { __mode = "v" }),
		guilds = setmetatable({}, { __mode = "v" }),
		users = setmetatable({}, { __mode = "v" })
	}

	local heartbeat = {
		interval = 0,
		seq = nil,
		thread = nil
	}
	local onPacket = self.__handlers["PACKET"]
	
	local ws = comp.ws.connect(api.Gateway:format(api.Version))
	self.ws = ws

	local function wsSend(data)
		if onPacket then
			onPacket(data)
		end
		local clone = table.clone(data)
		clone.type = 1
		ws:Send(comp.jsonencode(clone))
	end

	ws.OnMessage:Connect(function(raw)
		local payload = comp.jsondecode(raw)
		local op, data, seq, ev = payload.op, payload.d, payload.s, payload.t

		if seq then 
			heartbeat.seq = seq
		end

		if onPacket then
			onPacket({
				type = 0,
				payload = payload,
				heartbeat = heartbeat
			})
		end

		if op == OP_HELLO then
			heartbeat.interval = data.heartbeat_interval / 1000
			wsSend({
				op = OP_IDENTIFY,
				d = {
					token = self.__auth,
					intents = self.__config.intents,
					properties = {
						os = "linux",
						browser = "discord",
						device = "discord"
					}
				}
			})
			
			heartbeat.thread = comp.task.spawn(function()
				while comp.task.wait(heartbeat.interval) do
					ws:Send({
						op = OP_HEARTBEAT, -- HEARTBEAT
        				d = heartbeat.seq
					})
				end 
			end)
		end

		if not ev then return end

		local p = PROCESSORS[ev]
		if p then data = p(self, data) end

		local h = self.__handlers[ev]
		if h then
			h(data)
		end
	end)
end

function Client:on(event: string, callback: (...any) -> ()): ()
	util.tca(1, event, "string")
	util.tca(2, callback, "function")
	self.__handlers[event] = callback
end

return Client
