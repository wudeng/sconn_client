CLUALIB=socket rc4 crypt sproto lkcp
CLUALIB_TARGET=$(patsubst %, %.so, $(CLUALIB))

all: $(CLUALIB_TARGET)

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	LIBFLAG= -g -Wall -Wl,-undefined,dynamic_lookup --shared
	CC=clang
else
	LIBFLAG= -g -Wall -Wl,-E -shared -fPIC
	CC=gcc
endif

all: ./bin/goscon

./bin/goscon:
	go build -o $@ github.com/ejoy/goscon

socket.so: lib/lsocket.c
	$(CC) $(LIBFLAG) -o $@ $^

rc4.so: lib/rc4.c lib/lrc4.c
	$(CC) $(LIBFLAG) -o $@ $^

crypt.so: lib/lcrypt.c
	$(CC) $(LIBFLAG) -o $@ $^

sproto.so:  sproto/lsproto.c sproto/sproto.c
	$(CC) $(LIBFLAG) -o $@ $^

lkcp.so: lkcp/lkcp.c lkcp/ikcp.c
	$(CC) $(LIBFLAG) -o $@ $^

clean:
	-rm -rf *.so

.PHONY: all clean goscon
