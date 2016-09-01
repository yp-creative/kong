#define DDEBUG 0
#include "ddebug.h"

#include <lua.h>
#include <lauxlib.h>

#include <mcrypt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


//m.bf_cfb_en(k, iv, '<<in>>')
static int
bf_cfb(lua_State *L, int enc) {
    char           *k;
    size_t          klen;
    char           *iv;
    char           *value;
    size_t          len;
    char           *p;
    MCRYPT          td;
    int             i;

    if (lua_gettop(L) != 3) {
        return luaL_error(L, "must give 3 arguments");
    }

    p = (char *) luaL_checklstring(L, 1, &len);

    if (len < 8 || len > 128) {
        return luaL_error(L, "error k len");
    }

    k = p;
    klen = len;

    p = (char *) luaL_checklstring(L, 2, &len);

    if (len != 8) {
        return luaL_error(L, "error iv len");
    }

    iv = p;

    p = (char *) luaL_checklstring(L, 3, &len);

    if (len == 0) {
        return 1;
    }

    value = p;

    td = mcrypt_module_open("blowfish", NULL, "cfb", NULL);
    if (td == MCRYPT_FAILED) {
        return luaL_error(L, "mcrypt module open error");
    }

    i = mcrypt_generic_init(td, k, klen, iv);
    if (i < 0) {
        return luaL_error(L, "mcrypt init fail");
    }

    if (enc) {
        mcrypt_generic(td, value, len);
    } else {
        mdecrypt_generic(td, value, len);
    }

    mcrypt_generic_end(td);

    lua_pushlstring(L, (char *) value, len);

    return 1;
}


int
bf_cfb_en(lua_State *L) {
    return bf_cfb((lua_State *) L, 1);
}


int
bf_cfb_de(lua_State *L) {
    return bf_cfb((lua_State *) L, 0);
}


static const struct luaL_Reg mcrypt[] = {
    {"bf_cfb_en", bf_cfb_en},
    {"bf_cfb_de", bf_cfb_de},
    {NULL, NULL}
};


int
luaopen_mcrypt(lua_State *L)
{
    luaL_register(L, "mcrypt", mcrypt);
    return 1;
}

