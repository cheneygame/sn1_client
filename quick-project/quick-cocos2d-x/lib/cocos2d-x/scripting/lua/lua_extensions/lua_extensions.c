
#include "lua_extensions.h"

#if __cplusplus
extern "C" {
#endif

// cjson
#include "cjson/lua_cjson.h"

// zlib
#include "zlib/lua_zlib.h"

// lpack
#include "lpack/lpack.h"

// socket
#include "socket/luasocket.h"
#include "socket/mime.h"
#include "socket/socket_scripts.h"

// filesystem
#include "filesystem/lfs.h"
// pbc
#include "pbc/src/pbc-lua.h" //add

//lpeg
#include "lpeg/lpeg.h"
#include "lpeg/lptypes.h"
#include "lpeg/lpcap.h"
#include "lpeg/lpcode.h"
#include "lpeg/lpprint.h"
#include "lpeg/lptree.h"
#include "lpeg/lpvm.h"
 
//sproto
#include "sproto/lsproto.h"

//crypt
#include "crypt/lcrypt.h"

#if CC_SQLITE_ENABLED > 0
// lsqlite3
#include "lsqlite3/lsqlite3.h"
#endif

static luaL_Reg luax_exts[] = {
    {"cjson", luaopen_cjson_safe},
    {"zlib", luaopen_zlib},
    {"pack", luaopen_pack},
    {"socket.core", luaopen_socket_core},
    {"mime.core", luaopen_mime_core},
    {"lfs", luaopen_lfs},
	{"protobuf.c", luaopen_protobuf_c}, // add
	{"lpeg", luaopen_lpeg},
	{"sproto.core", luaopen_sproto_core},
	{ "crypt", luaopen_crypt },

#if CC_SQLITE_ENABLED > 0
    {"lsqlite3", luaopen_lsqlite3},
#endif

    {NULL, NULL}
};

void luaopen_lua_extensions(lua_State *L)
{
    // load extensions
    luaL_Reg* lib = luax_exts;
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");
    for (; lib->func; lib++)
    {
        lua_pushcfunction(L, lib->func);
        lua_setfield(L, -2, lib->name);
    }
    lua_pop(L, 2);

    // load extensions script
    luaopen_socket_scripts(L);
}

#if __cplusplus
} // extern "C"
#endif
