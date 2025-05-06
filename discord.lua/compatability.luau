--!strict
--!optimize 2

local comp = {}

local isLune, libs = pcall(function()
	return {
		net = (require)("@lune/net"),
		serde = (require)("@lune/serde"),
		task = (require)("@lune/task")
	}
end)
comp.isLune = isLune

-- this has to be used for the sake of type checks
local _ENV = if isLune then (getfenv)(0) else getfenv().getgenv()

if isLune then
	comp.ws = {
		connect = function(url: string)
			local ws = libs.net.socket(url)
			local self = {}

			self.OnMessage = {}
			function self.OnMessage:Connect(cb)
				libs.task.spawn(function()
					while true do
						local message = ws:next()
						if message then
							cb(message)
						else
							print("WebSocket connection closed.")
							break
						end
					end
				end)
			end

			function self:Send(message)
				return ws:send(message)
			end

			function self:Close()
				return ws:close()
			end

			return table.freeze(self)
		end, 
	}

	function comp.jsondecode(data: string): { [string]: any }
		return libs.serde.decode("json", data)
	end

	function comp.jsonencode(data: { [string]: any }): string
		return libs.serde.encode("json", data)
	end

	comp.task = libs.task

	function comp.httppost(url, headers, body)
		return comp.jsondecode(libs.net.request({
			url = url,
			method = "POST",
			headers = headers,
			body = comp.jsonencode(body)
		}).body)
	end

	function comp.httpput(url, headers, body: { [string]: any }?)
		return comp.jsondecode(libs.net.request({
			url = url,
			method = "PUT",
			headers = headers,
			body = body or "{}"
		}).body)
	end

	function comp.urlencode(data)
		return libs.net.urlEncode(data)
	end
	
	function comp.httppatch(url, headers, body)
		return comp.jsondecode(libs.net.request({
			url = url,
			method = "PATCH",
			headers = headers,
			body = comp.jsonencode(body)
		}).body)
	end

	function comp.httpget(url, headers)
		return comp.jsondecode(libs.net.request({
			url = url,
			method = "GET",
			headers = headers
		}).body)
	end

	function comp.httpdelete(url, headers)
		libs.net.request({
			url = url,
			method = "DELETE",
			headers = headers
		})
	end
else
	comp.ws = _ENV.WebSocket
	comp.task = task
end

return comp
