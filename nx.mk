DEVKITPRO = /opt/devkitpro
include $(DEVKITPRO)/libnx/switch_rules

LIBDIRS = $(PORTLIBS) $(LIBNX)

ARCH = -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -fPIE

override CFLAGS += -Wall -O2 -ffunction-sections -D__SWITCH__ $(INCLUDE) $(ARCH) $(DEFINES)

override LDFLAGS += -specs=$(DEVKITPRO)/libnx/switch.specs -g $(ARCH)

override CXXFLAGS += -Wpedantic \
-O2 \
-ffunction-sections \
$(ARCH) \
-fno-rtti \
-fno-exceptions \
-Wall \
-Wextra \
-Wsign-conversion \
-Wconversion \
-std=c++2a \
-Isrc \
-IuSockets/src

export INCLUDE :=  $(foreach dir,$(LIBDIRS),-I$(dir)/include)
export LIBPATHS := $(foreach dir,$(LIBDIRS),-L$(dir)/lib)

.PHONY: capi
capi:
	$(MAKE) -C uSockets -f nx.mk
	$(CXX) -O3 $(CXXFLAGS) -c capi/App.cpp -o capi.o $(LDFLAGS) $(LIBPATHS)
	$(AR) rvs libuwebsockets-nx.a capi.o uSockets/*.o

all:
	$(MAKE) capi

clean:
	$(MAKE) -C uSockets -f nx.mk clean
	rm -f *.o
