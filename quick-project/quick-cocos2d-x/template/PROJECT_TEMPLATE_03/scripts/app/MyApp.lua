require("config")
require("CMD")
require("GDef")
print("start framework.init")
require("framework.init")
print("end framework.init")
local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
	print("MyApp:ctor")	
    MyApp.super.ctor(self)
end

function MyApp:run()
	print("MyApp:run")	
    CCFileUtils:sharedFileUtils():addSearchPath("res/")
    self:enterScene("LoginScene")
end

return MyApp
