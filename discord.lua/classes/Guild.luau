--!strict
--!optimize 2

local Guild = {}
Guild.__index = Guild

local api = require("../API")

local Member = require("./Member")
local Channel = require("./Channel")

function Guild.new(raw, token)
	local channels = {}
	for i, channel in raw.channels do
		channels[i] = Channel.new(channel, token)
	end
	local members = {}
	for i, member in raw.members do
		members[i] = Member.new(member, token)
	end
	return setmetatable({
		--__raw = raw,
		__auth = token,

		afkTimeout = raw.afk_timeout,
		channels = channels,
		notifications = raw.default_message_notifications,
		emojis = raw.emojis, -- TODO: wrap
		filter = raw.explicit_content_filter,
		id = raw.id,
		joinedAt = raw.joined_at,
		large = raw.large,
		lazy = raw.lazy,
		maxMembers = raw.max_members,
		memberCount = raw.member_count,
		members = members,
		name = raw.name,
		nsfw = raw.nsfw,
		nsfwLevel = raw.nsfw_level,
		ownerId = raw.owner_id,
		locale = raw.preferred_locale,
		roles = raw.roles, -- TODO: wrap
		stickers = raw.stickers, -- TODO: wrap
		systemChannelId = raw.system_channel_id,
		unavailable = raw.unavailable,
		verification = raw.verification_level,
		version = raw.version
	}, Guild)
end

function Guild:fetchMember(id: string)
	return Member.new(api:GET(`guilds/{self.id}/members/{id}`, self.__auth), self.__auth)
end

function Guild:ban(id: string)
	return api:PUT(`guilds/{self.id}/bans/{id}`, self.__auth).message
end

return Guild
