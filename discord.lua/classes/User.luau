--!strict
--!optimize 2

local User = {}
User.__index = User

function User.new(raw, token)
	return setmetatable({
		--__raw = raw,
		__auth = token,

		avatar = raw.avatar, -- TODO: wrap
		discriminator = raw.discriminator,
		id = raw.id,
		publicFlags = raw.public_flags,
		username = raw.username,
		bot = if raw.bot == nil then false else raw.bot
	}, User)
end

return User
