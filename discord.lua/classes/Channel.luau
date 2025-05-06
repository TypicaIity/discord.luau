--!strict
--!optimize 2

local Channel = {
	type = {
		[0] = "TEXT",
		[2] = "VOICE",
		[4] = "CATEGORY"
	}
}
Channel.__index = Channel

local api = require("../API")
local Message = require("./Message")

function Channel.new(raw, token)
	return setmetatable({
		--__raw = raw,
		__auth = token,

		flags = raw.flags,
		id = raw.id,
		name = raw.name,
		permissions = raw.permission_overwrites,
		position = raw.position,
		type = Channel.type[raw.type],
		version = raw.version,
		parentId = raw.parentId,
		lastMessageId = raw.last_message_id,
		rateLimit = raw.rate_limit_per_user
	}, Channel)
end

function Channel:send(message: string)
	return Message.new(api:POST(`channels/{self.id}/messages`, self.__auth, {
		content = message
	}))
end

function Channel:fetchMessages(limit: number?)
	local wrapped = {}
	for i, raw in api:GET(`channels/{self.id}/messages{if limit then "?limit="..tostring(limit) else ""}`, self.__auth) do
		wrapped[i] = Message.new(raw, self.__auth)
	end
	return wrapped
end

return Channel
