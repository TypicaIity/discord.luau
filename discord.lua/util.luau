--!strict
--!optimize 2

local util = {}

function util.tca<T>(n: number, a: T, e: string): T
	assert(typeof(a) == e, `invalid argument #{n} to '{debug.info(2, "n")}' ({typeof(a)} expected, got {e})`, 2)
	return a
end

function util.headers(token)
	return {
		["Content-Type"] = "application/json", ["Authorization"] = token
	}
end

return util
