--!strict
--!optimize 2

local Guild = {}
Guild.__index = Guild

local Channel = require("./Channel")

function Guild.new(raw, token)
	local channels = {}
	for i, channel in raw.channels do
		channels[i] = Channel.new(channel, token)
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
		members = raw.members, -- TODO: wrap
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

return Guild
