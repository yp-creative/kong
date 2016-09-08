version=0.0.1
name=lua-mcrypt
dist=$(name)-$(version)

LUAJIT_VERSION = 2.1

TARGET = mcrypt.so
OBJS   = mcrypt.o

.PHONE: all clean dist test

INSTALL ?= install
DESTDIR ?= /usr/local/lib/luarocks/rocks/kong/0.8.3-0/lib

RM = rm -f
# CC=gcc

# Gives a nice speedup, but also spoils debugging on x86. Comment out this
# line when debugging.
OMIT_FRAME_POINTER= -fomit-frame-pointer

## If your system doesn't have pkg-config, comment out the previous lines and
## uncomment and change the following ones according to your building
## enviroment.

PREFIX ?= /usr/local/openresty/luajit
LUA_INCLUDE_DIR ?= $(PREFIX)/include/luajit-$(LUAJIT_VERSION)
LUA_LIB_DIR     ?= $(PREFIX)/lib
CFLAGS=-O0 -fPIC -Wall -Werror -I$(LUA_INCLUDE_DIR)

LDFLAGS=-shared -lmcrypt -lluajit-5.1 $(OMIT_FRAME_POINTER)

## Mac OS
# LDFLAGS =-bundle -undefined dynamic_lookup -lmcrypt -lluajit


all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) $< -o $@

install: $(TARGET)
	$(INSTALL) -d $(DESTDIR)
	$(INSTALL) $(TARGET) $(DESTDIR)

clean:
	$(RM) *.so *.o

test: $(TARGET) t/sanity.t
	prove -r t

valtest: $(TARGET) t/sanity.t
	TEST_LUA_USE_VALGRIND=1 prove -r t

dist:
	if [ -d $(dist) ]; then rm -r $(dist); fi
	mkdir $(dist)
	cp -r t/ *.c *.h Makefile README.* $(dist)/
	tar zcvf $(dist).tar.gz $(dist)/

