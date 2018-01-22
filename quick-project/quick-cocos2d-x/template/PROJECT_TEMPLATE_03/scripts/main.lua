
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end
-- local sproto = require("sproto")
-- local proto = require("proto")
-- print("proto.c2s",proto.c2s)
-- host = sproto.new(proto.c2s):host "package"
-- send_request = host:attach(sproto.new(proto.c2s))
--str = send_request("set", { what = "hello", value = "world" }) --handshake heartbeat
-- str = send_request("handshake")
-- print("send_request",str)
-- print("123",string.byte(string.sub(str,1,1))
-- ,string.byte(string.sub(str,2,2))
-- ,string.byte(string.sub(str,3,3))
-- )

local crypt = require "crypt"
local token = {
        server = "sample",
        user = "hello",
        pass = "password",
}
local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(token.user), crypt.base64encode(token.server),crypt.base64encode("123") , 10)
print("handshake",handshake)
require("app.MyApp").new():run()
