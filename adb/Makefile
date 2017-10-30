# adbd

export TOOLCHAIN=arm-linux-gnueabihf-

SRCS+=adb.c
SRCS+=fdevent.c
SRCS+=transport.c
SRCS+=transport_local.c
SRCS+=transport_usb.c
SRCS+=sockets.c
SRCS+=services.c
SRCS+=file_sync_service.c
SRCS+=jdwp_service.c
SRCS+=framebuffer_service.c
SRCS+=remount_service.c
SRCS+=usb_linux_client.c
SRCS+=log_service.c
SRCS+=utils.c

VPATH+= ../libcutils
SRCS+= array.c
SRCS+= hashmap.c
SRCS+= properties.c
SRCS+= threads.c
SRCS+= socket_inaddr_any_server.c
SRCS+= socket_local_client.c
SRCS+= socket_local_server.c
SRCS+= socket_loopback_client.c
SRCS+= socket_loopback_server.c
SRCS+= socket_network_client.c
SRCS+= load_file.c

CPPFLAGS+= -DADB_HOST=0
CPPFLAGS+= -DHAVE_PTHREADS
CPPFLAGS+= -D_XOPEN_SOURCE -D_GNU_SOURCE
CPPFLAGS+= -fPIC
CPPFLAGS+= -I .
CPPFLAGS+= -I ../include
CPPFLAGS+= -I ../zlib


CFLAGS+= -O2 -Wall -Wno-unused-parameter
LDFLAGS= -static
LIBS= -lrt -lpthread -ldl 

CC=$(TOOLCHAIN)gcc
LD=$(TOOLCHAIN)gcc
STRIP=$(TOOLCHAIN)strip

OBJS= $(SRCS:.c=.o)
 
all: adbd
 
adbd: $(OBJS)
	$(LD) -o $@ $(LDFLAGS) $(OBJS) $(LIBS)
	$(STRIP) adbd
 
clean:
	rm -rf $(OBJS)
