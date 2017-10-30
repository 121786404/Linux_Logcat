#
#    1.  Base on android-4.3.1_r1
#    2.  Compiled with NDK androideabi gcc 4.8 and platform/android-18
# 
#    platform/system/extras
#    platform/system/core
#    platform/external/libselinux 
#    platform/bionic

CROSS_COMPILE ?= arm-linux-gnueabihf-
GCC ?= $(CROSS_COMPILE)gcc
AR  ?= $(CROSS_COMPILE)ar
GXX ?= $(CROSS_COMPILE)g++
STRIP ?= $(CROSS_COMPILE)strip


BUILD_BIN_DIR = .build/bin
BUILD_LIB_DIR = .build/lib
INSTALL_DIR = AT

#echo "GCC = $(GCC)"

 
CFLAGS := -O2
CFLAGS  += -fPIC -DPIC
CFLAGS  += -DMAIN_LOG_ONLY 
CFLAGS  += -DHAVE_PTHREADS

CXXFLAGS= ${CFLAGS}
CXXFLAGS+= -DADB_HOST=0
CXXFLAGS+= -D_XOPEN_SOURCE
CXXFLAGS+= -D_GNU_SOURCE

LDFLAGS += -O2 -Bdirect -Wl,--hash-style=gnu

LIBS := -ldl -lpthread


LIBCUTILS_SRC_DIR := source/libcutils
LIBLOG_SRC_DIR := source/liblog
BIONIC_SRC_DIR := source/bionic

INCLUDE_DIR := include

C_SRCS := \
	source/at_sys.c
	
C_SRCS += \
	$(LIBCUTILS_SRC_DIR)/properties.c \
	$(LIBCUTILS_SRC_DIR)/socket_local_client.c \
	$(LIBCUTILS_SRC_DIR)/socket_local_server.c \
	$(LIBCUTILS_SRC_DIR)/socket_loopback_client.c \
	$(LIBCUTILS_SRC_DIR)/socket_inaddr_any_server.c \
	$(LIBCUTILS_SRC_DIR)/socket_loopback_server.c \

C_SRCS += \
	$(LIBLOG_SRC_DIR)/event_tag_map.c \
	$(LIBLOG_SRC_DIR)/fake_log_device.c \
	$(LIBLOG_SRC_DIR)/logd_write.c \
	$(LIBLOG_SRC_DIR)/logprint.c \

C_SRCS += \
	$(BIONIC_SRC_DIR)/libc/bionic/system_properties.c \
	
S_SRCS := \
	$(BIONIC_SRC_DIR)/libc/arch-arm/bionic/futex_arm.S \
	
ATBOX_SRC_DIR := toolbox
ATBOX_LDFLAGS := -Wl,--gc-sections


ATBOX_C_SRCS := \
	$(ATBOX_SRC_DIR)/toolbox.c \
	$(ATBOX_SRC_DIR)/setprop.c \
	$(ATBOX_SRC_DIR)/getprop.c \
	$(ATBOX_SRC_DIR)/dynarray.c \
	

C_OBJS := $(patsubst %.c, %.c.o,  $(C_SRCS))
S_OBJS := $(patsubst %.S, %.s.o,  $(S_SRCS))

ATBOX_C_OBJS := $(patsubst %.c, %.c.o,  $(ATBOX_C_SRCS))
ATBOX_S_OBJS := $(patsubst %.c, %.c.o,  $(ATBOX_S_SRCS))

ADB_SRC_DIR := adb
ADB_LDFLAGS := -Wl,--gc-sections

ADB_C_SRCS := \
	$(ADB_SRC_DIR)/adb.c \
	$(ADB_SRC_DIR)/fdevent.c \
	$(ADB_SRC_DIR)/transport.c \
	$(ADB_SRC_DIR)/transport_local.c \
	$(ADB_SRC_DIR)/transport_usb.c \
	$(ADB_SRC_DIR)/sockets.c \
	$(ADB_SRC_DIR)/services.c \
	$(ADB_SRC_DIR)/file_sync_service.c \
	$(ADB_SRC_DIR)/jdwp_service.c \
	$(ADB_SRC_DIR)/framebuffer_service.c \
	$(ADB_SRC_DIR)/remount_service.c \
	$(ADB_SRC_DIR)/usb_linux_client.c \
	$(ADB_SRC_DIR)/log_service.c \
	$(ADB_SRC_DIR)/utils.c \


ADB_C_OBJS := $(patsubst %.c, %.c.o,  $(ADB_C_SRCS))
ADB_S_OBJS := $(patsubst %.c, %.c.o,  $(ADB_S_SRCS))

INCLUDES := -Iinclude 
INCLUDES += -Isource/bionic/libc/include
INCLUDES += -Isource/libcutils 

INCLUDES += -Isource/bionic/libc/arch-arm/include
INCLUDES += -Iadb 


.PHONY: all clean install

all: $(BUILD_LIB_DIR)/libat.so $(BUILD_BIN_DIR)/atbox $(BUILD_BIN_DIR)/logcat $(BUILD_BIN_DIR)/adbd   

clean:
	@rm -Rf $(C_OBJS)
	@rm -Rf $(S_OBJS)
	@rm -Rf $(ATBOX_C_OBJS)
	@rm -Rf $(ATBOX_S_OBJS)
	@rm -Rf $(ADB_C_OBJS)
	@rm -Rf $(ADB_S_OBJS)
	@rm -Rf $(BUILD_BIN_DIR)
	@rm -Rf $(BUILD_LIB_DIR)
	@rm -Rf $(INSTALL_DIR)

$(BUILD_BIN_DIR)/atbox: $(BUILD_LIB_DIR)/libat.so $(ATBOX_C_OBJS) $(ATBOX_S_OBJS) 
	@echo "BIN     $@"
	@mkdir -p $(dir $@)
	@$(GCC) $(ATBOX_LDFLAGS) -o $@ $(ATBOX_C_OBJS) $(ATBOX_S_OBJS) -L$(BUILD_LIB_DIR) ${LIBS} -lat
	
$(BUILD_BIN_DIR)/adbd: $(BUILD_LIB_DIR)/libat.so $(ADB_C_OBJS) $(ADB_S_OBJS) 
	@echo "BIN     $@"
	@mkdir -p $(dir $@)
	@$(GCC) $(ADB_LDFLAGS) -o $@ $(ADB_C_OBJS) $(ADB_S_OBJS) -L$(BUILD_LIB_DIR) ${LIBS} -lat

$(BUILD_LIB_DIR)/libat.so: $(C_OBJS) $(S_OBJS)
	@echo "LIB     $@"
	@mkdir -p $(dir $@)
	@$(GCC) -shared $(LDFLAGS) -o $@ $(C_OBJS) $(S_OBJS) ${LIBS}
	@$(AR) rcs $(BUILD_LIB_DIR)/libat.a $(C_OBJS) $(S_OBJS)

%.c.o : %.c
	@mkdir -p $(dir $@)
	@echo "CC      $<"
	@$(GCC) $(CFLAGS) $(INCLUDES) -c $< -o $@
	
%.s.o : %.S
	@mkdir -p $(dir $@)
	@echo "AS      $<"
	@$(GCC) $(CFLAGS) $(INCLUDES) -c $< -o $@	
	
$(BUILD_BIN_DIR)/logcat : $(BUILD_LIB_DIR)/libat.so logcat/logcat.cpp
	@echo "BIN     $@"
	@mkdir -p $(dir $@)
	@$(GXX) $(CXXFLAGS) $(INCLUDES) -o $@ logcat/logcat.cpp -L$(BUILD_LIB_DIR) ${LIBS} -lat -lgcc_s
	
install:
	@echo "INSTALL $(INSTALL_DIR)"
	@rm -Rf $(INSTALL_DIR)
	@mkdir -p $(INSTALL_DIR)/lib
	@mkdir -p $(INSTALL_DIR)/bin
	@mkdir -p $(INSTALL_DIR)/include
	@cp -Rf $(BUILD_LIB_DIR)/* $(INSTALL_DIR)/lib
	@cp -Rf $(BUILD_BIN_DIR)/* $(INSTALL_DIR)/bin
	@cp -Rf $(INCLUDE_DIR)/* $(INSTALL_DIR)/include
	@cd ${INSTALL_DIR}/bin && ln -fs atbox setprop
	@cd ${INSTALL_DIR}/bin && ln -fs atbox getprop
	@tar -Jcf AT.tar.xz AT
	
