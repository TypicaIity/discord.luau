--!strict
--!optimize 2

local Message = {}
Message.__index = Message

local api = require("../API")
local comp = require("../compatability")

local User = require("./User")

function Message.new(raw, token)
	print(raw)
	return setmetatable({
		--__raw = raw,
		__auth = token,

		id = raw.id,
		content = raw.content,
		channelId = raw.channel_id,
		timestamp = raw.timestamp,
		embeds = raw.embeds, -- TODO: wrap
		attachments = raw.attachments, -- TODO: wrap
		author = User.new(raw.author, token),
		reference = (raw.referenced_message and Message.new(raw.referenced_message, token)) or raw.message_reference,
		pinned = raw.pinned,
		mentions = raw.mentions, -- TODO: wrap
		guildId = raw.guild_id
	}, Message)
end

function Message:reply(message: string)
	return Message.new(api:POST(`channels/{self.channelId}/messages`, self.__auth, {
		content = message,
		message_reference = {
			message_id = self.id,
			channel_id = self.channelId
		}
	}), self.__auth)
end

function Message:react(emoji: string)
	api:PUT(`channels/{self.channelId}/messages/{self.id}/reactions/{comp.urlencode(emoji)}/@me`, self.__auth)
	return self
end

function Message:edit(content: string)
	api:PATCH(`channels/{self.channelId}/messages/{self.id}`, self.__auth, {
		content = content
	})
	return self
end

function Message:delete()
	api:DELETE(`channels/{self.channelId}/messages/{self.id}`, self.__auth)
	return self
end

return Message
