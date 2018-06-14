
all: socket.so rc4.so crypt.so sproto.so

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	LIBFLAG= -g -Wall -Wl,-undefined,dynamic_lookup --shared
else
	LIBFLAG= -g -Wall -Wl,-E -shared -fPIC
endif



socket.so: lib/lsocket.c
	clang $(LIBFLAG) -o $@ $^

rc4.so: lib/rc4.c lib/lrc4.c
	clang $(LIBFLAG) -o $@ $^

crypt.so: lib/lcrypt.c
	clang $(LIBFLAG) -o $@ $^

sproto.so:  sproto/lsproto.c sproto/sproto.c
	clang $(LIBFLAG) -o $@ $^

goscon:
	cd goscon/ && go build


clean:
	-rm -rf *.so


.PHONY: all clean goscon
