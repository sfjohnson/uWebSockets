AR = $(HOME)/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf-ar
CXX = $(HOME)/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf-g++
override CXXFLAGS += -ffunction-sections \
-fdata-sections \
-D__arm__ \
--sysroot="$(HOME)/arm-rpi-linux-gnueabihf/arm-rpi-linux-gnueabihf/sysroot" \
-B"$(HOME)/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf-" \
-fPIC \
-Wpedantic \
-Wall \
-Wextra \
-Wsign-conversion \
-Wconversion \
-std=c++2a \
-Isrc \
-IuSockets/src

# WITH_LIBUV=1 builds with libuv as event-loop
ifeq ($(WITH_LIBUV),1)
	override LDFLAGS += -luv
endif

# WITH_ASAN builds with sanitizers
ifeq ($(WITH_ASAN),1)
	override CXXFLAGS += -fsanitize=address -g
	override LDFLAGS += -lasan
endif

.PHONY: capi
capi:
	$(MAKE) -C uSockets -f rpi.mk
	$(CXX) -O3 $(CXXFLAGS) -c capi/App.cpp -o capi.o $(LDFLAGS)
	$(AR) rvs libuwebsockets-rpi.a capi.o uSockets/*.o

all:
	$(MAKE) capi

clean:
	$(MAKE) -C uSockets -f rpi.mk clean
	rm -f *.o

