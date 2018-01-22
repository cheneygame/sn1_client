DataManager={}

local name = nil
local id = nil 

function DataManager.setAccount(flag)
	name=flag 

end
function DataManager.getAccount()
	return name 
end

function DataManager.setId(flag)
	id=flag 
end
function DataManager.getId()
	return id 
end




