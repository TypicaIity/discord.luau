local User = require("User") -- assuming User class is in a separate file

local Member = {}
Member.__index = Member

function Member.new(raw, guildId, token)
	local user = raw.user and User.new(raw.user, token)
	
	return setmetatable({
		__auth = token,
		
		user = user,
		id = user.id,
		nick = raw.nick,
		avatar = raw.avatar, -- TODO: wrap
		roles = raw.roles,	-- TODO:wrap
		joinedAt = raw.joined_at,
		boostingSince = raw.premium_since,
		deaf = raw.deaf,
		mute = raw.mute,
		pending = raw.pending,
		permissions = raw.permissions,
		communicationDisabledUntil = raw.communication_disabled_until,
		flags = raw.flags,
		guildId = guildId
	}, Member)
end

function Member:getDisplayName()
	return self.nick or self.user.username
end

function Member:hasRole(roleId)
	for _, id in self.roles do
		if id == roleId then
			return true
		end
	end
	return false
end

return Member
