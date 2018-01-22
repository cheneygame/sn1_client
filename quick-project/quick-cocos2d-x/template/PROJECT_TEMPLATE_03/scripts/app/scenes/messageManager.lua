--lpack use:
-- #define OP_ZSTRING  'z'     //空字符串
-- #define OP_BSTRING  'p'     //长度小于2^8的字符串
-- #define OP_WSTRING  'P'     //长度小于2^16的字符串
-- #define OP_SSTRING  'a'     //长度小于2^32/64的字符串*/
-- #define OP_STRING   'A'     //指定长度字符串
-- #define OP_FLOAT    'f'     /* float */
-- #define OP_DOUBLE   'd'     /* double */
-- #define OP_NUMBER   'n'     /* Lua number */
-- #define OP_CHAR     'c'     /* char */
-- #define OP_BYTE     'b'     /* byte = unsigned char */
-- #define OP_SHORT    'h'     /* short */
-- #define OP_USHORT   'H'     /* unsigned short */
-- #define OP_INT      'i'     /* int */
-- #define OP_UINT     'I'     /* unsigned int */
-- #define OP_LONG     'l'     /* long */
-- #define OP_ULONG    'L'     /* unsigned long */

-- #define OP_LITTLEENDIAN '<'     /* little endian */
-- #define OP_BIGENDIAN    '>'     /* big endian */
-- #define OP_NATIVE       '='     /* native endian */
	
cc.utils                = require("framework.cc.utils.init")
cc.net                  = require("framework.cc.net.init")

local ByteArray = require("framework.cc.utils.ByteArray")

messageManager = {}

function messageManager:getProcessMessage(version,messageId,protobufMessage)
    local packA = string.pack(">hiz",version,messageId,protobufMessage)
    local byteArrayA = ByteArray.new()
    byteArrayA:writeBuf(packA)
    local packAlen = byteArrayA:getLen()

    local packB = string.pack(">hhiz",packAlen,version,messageId,protobufMessage)
    local byteArrayB = ByteArray.new()
    byteArrayB:writeBuf(packB)
    return byteArrayB
end

function messageManager:gets2package(pack)
	--末尾可能多余一个0
    local packA = string.pack(">z",pack)
	--去掉末尾可能多余的0
	if string.byte(string.sub(packA,packA:len(),packA:len())) == 0 then
		packA = string.sub(packA,1,packA:len() - 1)
	end
    local byteArrayA = ByteArray.new()
    byteArrayA:writeBuf(packA)
    local packAlen = byteArrayA:getLen()
	--print("gets2package packAlen len",byteArrayA:getLen())
    local packB = string.pack(">hz",packAlen,pack)
	--去掉末尾可能多余的0
	if string.byte(string.sub(packB,packB:len(),packB:len())) == 0 then
		packB = string.sub(packB,1,packB:len() - 1)
	end
    local byteArrayB = ByteArray.new()
    byteArrayB:writeBuf(packB)
	--print("gets2package byteArrayB len",byteArrayB:getLen())
    return byteArrayB
end

-- #define OP_ZSTRING  'z'     /* zero-terminated string */
-- #define OP_BSTRING  'p'     /* string preceded by length byte */
-- #define OP_WSTRING  'P'     /* string preceded by length word */
-- #define OP_SSTRING  'a'     /* string preceded by length size_t */
-- #define OP_STRING   'A'     /* string */
function messageManager:unpackMessage(message)
    local nextPos1,maxLen    = string.unpack(message,">h")
    local nextPos2,version   = string.unpack(message,">h",nextPos1)
    local nextPos3,messageId = string.unpack(message,">i",nextPos2)
    local nextPos4,msg       = string.unpack(message,">z",nextPos3,maxLen)

    return maxLen,version,messageId,msg

end


function messageManager:unpackMessage(message)
    local nextPos1,maxLen    = string.unpack(message,">h")
    local nextPos2,version   = string.unpack(message,">h",nextPos1)
    local nextPos3,messageId = string.unpack(message,">i",nextPos2)
    local nextPos4,msg       = string.unpack(message,">z",nextPos3,maxLen)

    return maxLen,version,messageId,msg

end

function messageManager:unpackMessageToStr(message)
	print("unpackMessageToStr",type(message),#message)
	for i=1,#message do
		--print("i",i,string.byte(string.sub(message,i,i)))
	end
	local function unpack_package(text)
		local size = #text
		if size < 2 then
				return nil, text
		end
		local s = text:byte(1) * 256 + text:byte(2)
		if size < s+2 then
				return nil, text
		end

		return text:sub(3,2+s), text:sub(3+s)
	end
	--local nextPos1,maxLen    = string.unpack(message,">h")
	--print("maxLen",maxLen)
	--local nextPos4,msg       = string.unpack(message,">z",1,#message)
	--print("msg",msg)
	local v,last = unpack_package(message)
	print("v,last",v,last)
	return v,last
	--print("dispatch",host:dispatch(v))
	--result, last = unpack_package(msg)
	--print("maxLen,msg",maxLen,msg,unpack_package(msg))
end

local last = ""
function messageManager:unpackMessageToPatch(message,callback)
	print("unpackMessageToPatch",type(message),#message)
	local function unpack_package(text)
		local size = #text
		if size < 2 then
				return nil, text
		end
		local s = text:byte(1) * 256 + text:byte(2)
		if size < s+2 then
				return nil, text
		end

		return text:sub(3,2+s), text:sub(3+s)
	end
	local tret,leftstr = unpack_package(last..message)
	last = leftstr  --save the left text
	if tret then
		callback(tret,leftstr)
		self:unpackMessageToPatch("",callback) --粘包
	end
end


function messageManager:unpackMessageToStrByLine(message)
	print("unpackMessageToStrByLine",type(message),#message)
	local function unpack_line(text)
        local from = text:find("\n", 1, true)
        if from then
                return text:sub(1, from-1), text:sub(from+1)
        end
        return nil, text
	end
	--local nextPos1,maxLen    = string.unpack(message,">h")
	--print("maxLen",maxLen)
	--local nextPos4,msg       = string.unpack(message,">z",1,#message)
	--print("msg",msg)
	local line, text = unpack_line(message)
	print("unpack_line",line, text)
	return line,last
	--print("dispatch",host:dispatch(v))
	--result, last = unpack_package(msg)
	--print("maxLen,msg",maxLen,msg,unpack_package(msg))
end






