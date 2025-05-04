--!strict
--!optimize 2

local api = {
	REST = "https://discord.com/api/v%d/%s",
	Gateway = "wss://gateway.discord.gg/?v=%d&encoding=json",
	Version = 10,
}

local util = require("./util")
local comp = require("./compatability")

function api:POST(endpoint, token, body)
	return comp.httppost(self.REST:format(self.Version, endpoint), util.headers(token), body)
end

function api:PUT(endpoint, token)
	return comp.httpput(self.REST:format(self.Version, endpoint), util.headers(token))
end

function api:PATCH(endpoint, token, body)
	return comp.httppatch(self.REST:format(self.Version, endpoint), util.headers(token), body)
end

function api:GET(endpoint, token)
	return comp.httpget(self.REST:format(self.Version, endpoint), util.headers(token))
end

function api:DELETE(endpoint, token)
	return comp.httpdelete(self.REST:format(self.Version, endpoint), util.headers(token))
end

return api
