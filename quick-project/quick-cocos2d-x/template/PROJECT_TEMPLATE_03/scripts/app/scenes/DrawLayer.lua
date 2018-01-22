
require("app.scenes.messageManager")
require("app.scenes.socketManager")
require "app.scenes.protobuf"

local DrawLayer = class("DrawLayer", function()
    return display.newNode("DrawLayer")
end)

function DrawLayer:ctor()
	-- handling touch events   
    --下面就是单点触摸的用法
	self:setTouchEnabled(true)  						--设置这个精灵是否能触摸
	self:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)		--触摸模式。我们传进单点触摸模式进去
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)    --关键，这边就是传事件类型和回调函数，在回调函数中处理消息
		local x, y, prevX, prevY = event.x, event.y, event.prevX, event.prevY 
			print(event.name,x, y, prevX, prevY)
		    if event.name == "began" then
			--self:setScale(0.9)
				self:drawbegan(x, y, prevX, prevY)
		    elseif event.name == "moved" then
		       -- self:setPosition(cc.p(x,y))	
		       self:draw(x, y, prevX, prevY)	       	
		    elseif event.name == "ended" then
		        --self:setScale(1)  
		        
		    end
		    
	    return true
	end)
	

    local function onClicked(tag)  
        print("tag",tag)
        if tag == 300 then
        	socketManager:send_sproto(CMD_CLOSEDRAW,"closedraw", args)
        	self:removeFromParent()
        end
   		
    end 
	local wsize = display.size
	local menu  = ui.newMenu({}) 
	--menu:setAnchorPoint(cc.p(0,0))
	--menu:setPosition(cc.p(-wsize.width/2,-wsize.height/2))
	self:addChild(menu)  
	self.menu = menu	

	local item = ui.newTTFLabelMenuItem({  
  		    text 		= "close",  
    		size 		= 25,
   			listener 	= onClicked,  
   		    x 			= wsize.width - 50,  
  			y 			= wsize.height - 50,
  			tag 		= 300
	}) 
	self.menu:addChild(item)
end

function DrawLayer:draw(px, py,prevX, prevY)
	if false then
		if not self.drawNode then
			self.drawNode = cc.DrawNode:create()
			self:addChild(self.drawNode,0,1)
		end	
		self.drawNode:drawLine(cc.p(px, py), cc.p(prevX, prevY), 1,cc.c4f(0,1,0,1))
		return
	end
	px = math.floor(px)
	py = math.floor(py)
	--send
   	local args = {x = px, y = py}
    socketManager:send_sproto(CMD_DRAW,"draw", args)
	self:todraw(px, py)
end

function DrawLayer:drawbegan(px, py,prevX, prevY)
	px = math.floor(px)
	py = math.floor(py)
	--send
   	local args = {x = px, y = py}
    socketManager:send_sproto(CMD_DRAWBEGAN,"drawbegan", args)
	self:todraw(px, py,true)
end

function DrawLayer:todraw(x, y,began)
	if type(began) ~= "boolean" then began = false end
	--print("todraw",self.drawNode, self.prevx,x,y)
	if not self.drawNode then
		self.drawNode = cc.DrawNode:create()
		self:addChild(self.drawNode,0,1)
	end
	if not self.prevx or began then
		self.prevx = x
		self.prevy = y
		return
	end
	
	--print("todraw",x, y)
	self.drawNode:drawLine(cc.p(self.prevx, self.prevy), cc.p(x, y), 1,cc.c4f(0,1,0,1))
	self.prevx = x
	self.prevy = y
end


return DrawLayer