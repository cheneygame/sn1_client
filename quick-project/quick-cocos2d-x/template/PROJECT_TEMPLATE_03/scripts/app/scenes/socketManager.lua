
print("socketManager start require ")
require("app.scenes.messageManager")
--require "app.scenes.protobuf"
require("app.scenes.ChatScene")
require("app.scenes.DataManager")
print("socketManager start require Scheduler")
local Scheduler = require("framework.scheduler")
print("socketManager start require net")
local net = require("framework.cc.net.init")
--protobuf.register_file "res/talkbox.pb"
print("socketManager start require ByteArray")
local ByteArray = require("framework.cc.utils.ByteArray")

--192.168.177.131
--"192.168.0.29" ???"192.168.0.29"
local IP = "192.168.0.28" --虚拟机服务器IP:0.0.0.0,不可用127.0.0.1，参考chatOfSkynet/skynet
local port = 8001
local testType = 1 -- 1 :examples/config,2:examples/config.login
if testType == 2 then --先8001，验证后断开,在连接8888
	port = 8001
elseif testType == 1 then 
	port = 8888
end
local token = {
		server = "sample",
		user = "hello",
		pass = "password",
}	

--必须连接启动watchdog agent的服务器
--10101:可行   -》server:skynetServer/config ,client:this cocos client
--8001:可行   -》testType = 1,server:examples/config ,client:this cocos client
--8001 + 8888: 可行 -》server:examples/config.login, client:examples/client.lua or this cocos client
--config.login必须先连接8001验证密匙后，断开socket再连接8888
--服务器网络：8001:走socket.lua,8888:走snax的gateServer
--examples/config.login的客户端部分已经做到cocos和自带demo一致


local sproto = require("sproto")
local proto = require("proto")
local session = 0
local fd = nil
local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s))

socketManager = {}

self = socketManager
local nextScene = nil 
function socketManager:initSocket() 
	if not self._socket then
		print("*********socketManager:initSocket*****",IP, port)
        self._socket = net.SocketTCP.new(IP, port, false)
        self._socket:addEventListener(net.SocketTCP.EVENT_CONNECTED, handler(self, self.onStatus))
        self._socket:addEventListener(net.SocketTCP.EVENT_CLOSE, handler(self,self.onStatus))
        self._socket:addEventListener(net.SocketTCP.EVENT_CLOSED, handler(self,self.onStatus))
        self._socket:addEventListener(net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onStatus))
        self._socket:addEventListener(net.SocketTCP.EVENT_DATA, handler(self,self.onData))
		print("*********SocketTCP.new finish*****")
    end
	--print("*********self._socket:connect start*****")
	--dump(net.SocketTCP)
    --self._socket:connect()
	self._socket:connect(IP, port, false)
	self._socket:test()
    --print("*********self._socket:connect finish*****")
end

function socketManager:sendMessage(msg)
	print("socketManager:sendMessage",msg)
    self._socket:send(msg:getPack())
end



function socketManager:onData(__event)
	print("***socketManager:onData",#__event.data)
	local str = clone(__event.data)
	-- for i=1,#__event.data do
		-- print("__event.data",i,string.byte(string.sub(str,i,i)))
	-- end
	
    local maxLen,version,messageId,msg = messageManager:unpackMessage(__event.data)

    --print("maxLen,version,messageId,msg",maxLen,version,messageId,msg)
    if messageId == 0 then 
        
    	print("socket receive raw data:", msg)
        if nextScene~=nil then 
            nextScene:getChatLayer():createText(msg)
        end

    elseif messageId == 1000 then 
        local stringbuffer = protobuf.decode("talkbox.talk_result",msg)

        print("stringbuffer.id",stringbuffer.id)

        if stringbuffer.id==10 then
            print("创建用户成功")
            nextScene = require("app.scenes.ChatScene"):new()
            local kEffect = {"splitCols","splitRows"}
            print("self.nextScene",nextScene)
            local transtion = display.wrapSceneWithTransition(nextScene,kEffect[math.random(1,table.nums(kEffect))],.5)
            display.replaceScene(transtion)
            --self.nextScene:getChatLayer():createText("新用户进来")
            --self.nextScene:getChatLayer():getChatList()

        elseif stringbuffer.id==1 then 
            print("服务端解析请求创建用户的protocbuf失败")
        elseif stringbuffer.id==2 then
            print("创建用户失败，名字已经存在")

        elseif  stringbuffer.id==3 then
            print("服务端解析请求发送内容的protocbuf失败")
        end

    elseif messageId == 1002 then 
        local stringbuffer = protobuf.decode("talkbox.talk_users",msg)

        for k , v in pairs(stringbuffer.users) do
            print("vvvvvvvvvvv",v.userid,v.name)
        end
        
        nextScene:getChatLayer():updateChatList(stringbuffer.users)

    elseif messageId == 1010 then 

      
        local stringbuffer = protobuf.decode("talkbox.talk_message",msg)

        print("stringbufferstringbuffer",stringbuffer.msg,nextScene)

        nextScene:getChatLayer():createText(stringbuffer.msg)

    elseif messageId ==1008 then 
    	local stringbuffer = protobuf.decode("talkbox.talk_create",msg)
       

    	print("socket receive raw data:", maxLen,version,messageId,stringbuffer.userid,stringbuffer.name)
	else
		
		if testType == 1 then
			local function msgdispatch(v,last)
				if v then
					--print("v,last",#(v),#(last),v,last)
					local typ,session,p1,p2,p3 = host:dispatch(v)
					--print("typ,session,p1,p2,p3",typ,session,p1,p2,p3)
					if type(p1) == "table" then
						--dump(p1,"p1")
					end
					--print("p1.msg",p1.msg)
					if typ == "RESPONSE" then
						if session == CMD_LOGIN and tonumber(p1.code) == 0 then
							local scene = display.getRunningScene()
							local hall_layer_ = require("app.scenes.HallLayer"):new()
							scene:removeChildByTag(Tag_Login)
	    					scene:addChild(hall_layer_,0,Tag_Hall)
	    				elseif session == CMD_LOGIN then
	    					print("CMD_LOGIN return")
	    				elseif session == CMD_READY then
	    					print("CMD_READY return")
	    					local scene = display.getRunningScene()
	    					local hall = scene:getChildByTag(Tag_Hall)
	    					if hall then
	    						hall:updateReady(p1)
	    					end	
						end
					elseif typ == "REQUEST" then
						--print("session",session, session == "intogame")
						if session == "room_info" then
	    					print("CMD_ROOMINFO return")
	    					local scene = display.getRunningScene()
	    					local hall = scene:getChildByTag(Tag_Hall)
	    					if hall then
	    						hall:updateState(p1)
	    					end	
	    				elseif session == "intogame" then
	    					print("CMD_INTOGAME return")
	    					local scene = display.getRunningScene()
	    					local dlayer = require("app.scenes.DrawLayer"):new()
	    					scene:removeChildByTag(Tag_Draw)
	    					scene:addChild(dlayer,0,Tag_Draw)
	    				elseif session == "matedraw" then
	    					--print("CMD_MATEDRAW return")
	    					local scene = display.getRunningScene()
	    					local dl = scene:getChildByTag(Tag_Draw)
	    					if dl then
	    						dl:todraw(p1.x,p1.y)
	    					end	
	    				elseif session == "matedrawbegan" then
	    					print("CMD_MATEDRAWBEGAN return")
	    					local scene = display.getRunningScene()
	    					local dl = scene:getChildByTag(Tag_Draw)
	    					if dl then
	    						dl:todraw(p1.x,p1.y,true)
	    					end	
						end	
					end
				end	
			end
			local v,last = messageManager:unpackMessageToPatch(__event.data,msgdispatch)
		elseif testType == 2 then --config.path
			local function writeline(fd, pack)
				-- local package = string.pack(">s2", pack)
				-- socket.send(fd, package)
				local message = messageManager:gets2package(pack.. "\n")
				socketManager:sendMessage(message)	
			end
			self.readlineNum = self.readlineNum or 1
			
			print("self.readlineNum ==",self.readlineNum)
			--翻译自skynet
			if self.readlineNum == 1 then
				local v,last = messageManager:unpackMessageToStrByLine(__event.data)
				self.challenge = crypt.base64decode(v)
				print("self.challenge",self.challenge)
				self.clientkey = crypt.randomkey()
				print("self.clientkey",self.clientkey)
				writeline(fd, crypt.base64encode(crypt.dhexchange(self.clientkey)))
			elseif self.readlineNum == 2 then
				local v,last = messageManager:unpackMessageToStrByLine(__event.data)
				local secret_readline = v
				self.secret = crypt.dhsecret(crypt.base64decode(secret_readline), self.clientkey)
				print("sceret is ", crypt.hexencode(self.secret))
				local hmac = crypt.hmac64(self.challenge, self.secret)
				writeline(fd, crypt.base64encode(hmac))
				

				local function encode_token(token)
						return string.format("%s@%s:%s",
								crypt.base64encode(token.user),
								crypt.base64encode(token.server),
								crypt.base64encode(token.pass))
				end

				local etoken = crypt.desencode(self.secret, encode_token(token))
				local b = crypt.base64encode(etoken)
				writeline(fd, crypt.base64encode(etoken))

			elseif self.readlineNum == 3 then
				local v,last = messageManager:unpackMessageToStrByLine(__event.data)
				local result = v
				print("code_readline",result)
				local code = tonumber(string.sub(result, 1, 3))
				assert(code == 200)
				--socket.close(fd)
				self.subid = crypt.base64decode(string.sub(result, 5))

				print("login ok, self.subid=", self.subid)
				
				--reconnect 8888
				port = 8888
				self._socket:close()
				self._socket = nil
				self:initSocket() 
				
			elseif self.readlineNum == 4 then
				local v,last = messageManager:unpackMessageToStr(__event.data)
				--v,last == 200,OK
				--全部结束，必须放到回包里面
				self._socket:close()
				self._socket = nil
			else
			
				print("unknow readlineNum",self.readlineNum)
			end
			self.readlineNum = self.readlineNum + 1
		end
		
		
    end


end

function socketManager:onStatus(__event)
    print("socket status: %s", __event.name)
    -- local stringbuffer = protobuf.encode("talkbox.talk_create",
    --                 {
    --                   userid = 13,
    --                   name = "2",
                     
    --                 })
    -- local message = messageManager.getProcessMessage (1,1003,stringbuffer)
    -- self._socket:send(message:getPack())
	if __event.name == "SOCKET_TCP_CONNECTED" then
		--
		if testType == 1 then
			--self:test_example_config() --测试通讯
		elseif testType == 2 then
			if self.readlineNum == 4 then --reconnect 8888
				print("reconnect 8888")
				
				local text = "echo"
				local index = 1
				last = ""

				local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(token.user), crypt.base64encode(token.server),crypt.base64encode(self.subid) , index)
				print("token",crypt.base64encode(token.user), crypt.base64encode(token.server),self.subid, index)
				print("handshake,secret",handshake,self.secret)
				local hmac = crypt.hmac64(crypt.hashkey(handshake), self.secret)
				local hmac_base64encode = crypt.base64encode(hmac)
				print("hmac_base64encode",hmac_base64encode,hmac_base64encode:len())
				print("hmac",hmac,hmac_base64encode,crypt.base64decode(hmac_base64encode))
				self:send_package(fd, handshake ..":" ..hmac_base64encode)
				--发送之后没有回包？？？ skynet有特殊协议结构？
				-- gateserver register_protocol type	0	0	nil	open	7	192.168.177.1:16011
				-- gateserver register_protocol type	0	0	nil	nil
				-- gateserver register_protocol type	0	0	userdata: 0x7f31a7434268	nil
				-- gateserver register_protocol type	0	0	userdata: 0x7f31a7434268	close	7
				--可以看到 第三条的 类型丢失，本应该为data类型
				--已经解决：gets2package 内末尾多了个0导致长度+1
				
				
				local function send_request(v, session)
					local size = #v + 4
					-- local package = string.pack(">I2", size)..v..string.pack(">I4", session)
					-- socket.send(fd, package)
					-- return v, session
					local packA = string.pack(">hzi",size,v,session)
					--去掉末尾可能多余的0
					if string.byte(string.sub(packA,packA:len(),packA:len())) == 0 then
						packA = string.sub(packA,1,packA:len() - 1)
					end
					
					local byteArrayA = ByteArray.new()
					byteArrayA:writeBuf(packA)
					
					self:sendMessage(byteArrayA)
					local packAlen = byteArrayA:getLen()
					print("v len",v,packAlen)
				end

				--这2个发送完成后在onData readlineNum == 4 里面关闭socket
				send_request("fake",0)
				send_request("again",1)
				
				
			end
		end
	elseif __event.name == "SOCKET_TCP_CLOSED" then
		local scene = display.getRunningScene()
		if scene then
			scene:removeAllChildren()
			login_layer_ = require("app.scenes.LoginLayer"):new()
   			scene:addChild(login_layer_,0,Tag_Login)
		end	
		
	end
end

function socketManager:send_package(fd, pack)
	--print("send_package",pack,"|",pack:len())
        -- local package = string.pack(">s2", pack)
        -- socket.send(fd, package)
	local message = messageManager:gets2package(pack)
	self:sendMessage(message)	
end

	
--测试 examples/config,使用sproto协议
function socketManager:test_example_config()
	

	local function send_request(name, args)
        session = session + 1
        local str = request(name, args, session)
        self:send_package(fd, str)
        print("Request:", session,str)
	end
	send_request("handshake")
	--str = send_request("set", { what = "hello", value = "world" }) --handshake heartbeat
	str = send_request("login", { user = token.user, pass = token.pass,server = token.server })
end

--发送sproto消息
function socketManager:send_sproto(session,name, args)

	local function send_request(session,name, args)
        --session = session + 1
        local str = request(name, args, session)
        self:send_package(fd, str)
        --print("Request:", name, args, session)
        --dump(args)
	end
	str = send_request(session,name, args)
end

--测试 examples/config.login
function test_example_config_login()

end