--!strict
--!optimize 2

local Client = {}
Client.__index = Client

local api = require("../API")
local util = require("../util")
local comp = require("../compatability")

local Message = require("./Message")

export type ClientConfig = {
	selfbot: boolean?,
	intents: number?
}

local PROCESSORS = {
	MESSAGE_CREATE = function(self, data: { [string]: any }): any
		return Message.new(data, self.__auth)
	end
}

function Client.new(config: ClientConfig)
	-- TODO: type check config
	return setmetatable({
		__auth = nil,
		__config = config,
		__handlers = {},
		intents = config.intents or 53608447
	}, Client)
end

function Client:login(token: string)
	util.tce(1, token, "string")
	self.__auth = `{if self.__config.selfbot == true then "" else "Bot "}{token}`

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
					intents = self.intents,
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

		if ev == "READY" then
			self.user = data.user
		end

		if self.__handlers[ev] then
			local p = PROCESSORS[ev]
			if p then data = p(self, data) end
			self.__handlers[ev](data)
		end
	end)
end

function Client:on(event: string, callback: (...any) -> ())
	util.tce(1, event, "string")
	util.tce(2, callback, "function")
	self.__handlers[event] = callback
end

return Client
