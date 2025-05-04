--!strict
--!optimize 2

local User = {}
User.__index = User

function User.new(raw, token)
	return setmetatable({
		__raw = raw,
		__auth = token,

		avatar = raw.avatar, -- TODO: wrap
		discriminator = "0",
		id = raw.id,
		publicFlags = raw.public_flags,
		name = raw.username
	}, User)
end

return User
