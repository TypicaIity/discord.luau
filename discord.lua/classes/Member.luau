--!strict
--!optimize 2

local Member = {}
Member.__index = Member

local User = require("./User")

function Member.new(raw, token)
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
		flags = raw.flags
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
