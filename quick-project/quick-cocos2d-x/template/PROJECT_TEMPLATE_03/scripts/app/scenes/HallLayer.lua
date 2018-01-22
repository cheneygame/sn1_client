
require("app.scenes.messageManager")
require("app.scenes.socketManager")
require "app.scenes.protobuf"

local HallLayer = class("HallLayer", function()
    return display.newNode("HallLayer")
end)

function HallLayer:ctor()
	local function onClicked(tag)  
        print("tag",tag)
        if tag == 300 then
        	local name = "ready"
   			local args = {}
   			socketManager:send_sproto(CMD_READY,name, args)
        else
        	local name = "inroom"
   			local args = {roomid = math.floor(tag/10),idx = tag % 10}
   			socketManager:send_sproto(CMD_INROOM,name, args)
        end
   		
    end  
	local back = display.newSprite("HelloWorld.png")
	--back:setPosition(ccp(display.cx ,display.cy ))
	self.btntags = {}
	local wsize = display.size
	local menu  = ui.newMenu({}) 
	--menu:setAnchorPoint(cc.p(0,0))
	--menu:setPosition(cc.p(-wsize.width/2,-wsize.height/2))
	self:addChild(menu)  
	self.menu = menu	
	for i = 1,6 do	
		for j = 1,2 do
			local stx = 150
			local sty = 5
			local gx = 100
			local gy = 50
			local ttag = i*10 + j
			local item = ui.newTTFLabelMenuItem({  
		  		    text 		= ttag.."",  
		    		size 		= 25,
		   			listener 	= onClicked,  
		   		    x 			= (j - 1)*gx + stx,  
		  			y 			= i*gy + sty,
		  			tag 		= ttag
			}) 

			self.menu:addChild(item)
			table.insert(self.btntags,ttag)
		end

	end

	local item = ui.newTTFLabelMenuItem({  
  		    text 		= "ready",  
    		size 		= 25,
   			listener 	= onClicked,  
   		    x 			= 380,  
  			y 			= 100,
  			tag 		= 300
	}) 
	self.menu:addChild(item)
	-- local menu = ui.newMenu({item})  
	-- self:addChild(menu) 
	
end

local function remove(v,tag)
	if v:getChildByTag(tag) then
		v:removeChildByTag(tag)
	end
end

function HallLayer:updateState(states)
	
	for m,n in pairs(self.btntags) do 
		local btn = self.menu:getChildByTag(n)
		--print("btn",btn,n)
		if btn then
			local found = false
			for k,v in pairs(states.rooms) do 
				--dump(v)
				local tag = v.roomid*10 + v.idx
				--print("v.account",v.account,DataManager.getAccount(),type(DataManager.getAccount()),type(v.account))
				if tag == n then --found
					if DataManager.getAccount() == v.account.."" then
						local spr = cc.Sprite:create("dot_nor.png")
						remove(btn,1)
						btn:addChild(spr,0,1)
						
					else
						local spr = cc.Sprite:create("dot_sel.png")
						remove(btn,2)
						btn:addChild(spr,0,2)

					end
					if v.state == RoomState_Ready then
						local spr = cc.Sprite:create("ok.png")
						remove(btn,3)
						btn:addChild(spr,0,3)	
					else
						remove(btn,3)
					end
					if v.state == RoomState_Ingame then
						local spr = cc.Sprite:create("ingame.png")
						remove(btn,4)
						btn:addChild(spr,0,4)	
					else
						remove(btn,4)
					end
					found = true
					break
				end
			end
			if not found then
				--print("not found",n)
				remove(btn,1)	
				remove(btn,2)	
				remove(btn,3)
				remove(btn,4)
			end
					
			
		else
			print("nil btn",n)
		end
		
	end
end

function HallLayer:updateReady(states)
	if states.code == 0 then
		
	else
		print("error",states.msg)
	end
end

function HallLayer:onEdit(event, editbox)
	 if event == "began" then
	-- 开始输入
	elseif event == "changed" then
	-- 输入框内容发生变化
	elseif event == "ended" then
	-- 输入结束
	elseif event == "return" then
	-- 从输入框返回
	end
end

return HallLayer