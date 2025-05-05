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
	MESSAGE_CREATE = function(self, data: { [string]: any }): any
		return Message.new(data, self.__auth)
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

function Client.new(config: ClientConfig)
	-- TODO: type check config
	return setmetatable({
		__auth = nil,
		__config = {
			selfbot = if config.selfbot == nil then false else config.selfbot,
			intents = if config.intents == nil then 53608447 else config.intents
		},
		__handlers = {}
	}, Client)
end

function Client:login(token: string)
	util.tce(1, token, "string")

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
	
	local ws = comp.ws.connect(api.Gateway:format(api.Version))
	ws.OnMessage:Connect(function(raw)
		local payload = comp.jsondecode(raw)
		local op, data, seq, ev = payload.op, payload.d, payload.s, payload.t

		if seq then 
			heartbeat.seq = seq
		end 

		if op == 10 then -- HELLO
			heartbeat.interval = data.heartbeat_interval / 1000
			ws:Send(comp.jsonencode({
				op = 2,
				d = {
					token = self.__auth,
					intents = self.__config.intents,
					properties = {
						os = "linux",
						browser = "discord",
						device = "discord"
					}
				}
			}))
			heartbeat.thread = comp.task.spawn(function()
				while comp.task.wait(heartbeat.interval) do
					ws:Send(comp.jsonencode({
						op = 1, -- HEARTBEAT
        				d = heartbeat.seq
					}))
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

function Client:on(event: string, callback: (...any) -> ())
	util.tce(1, event, "string")
	util.tce(2, callback, "function")
	self.__handlers[event] = callback
end

return Client
