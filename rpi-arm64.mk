AR = $(HOME)/aarch64-rpi4-linux-gnu/bin/aarch64-rpi4-linux-gnu-ar
CXX = $(HOME)/aarch64-rpi4-linux-gnu/bin/aarch64-rpi4-linux-gnu-g++
override CXXFLAGS += -ffunction-sections \
-fdata-sections \
-DUWS_NO_ZLIB \
-D__aarch64__ \
--sysroot="$(HOME)/aarch64-rpi4-linux-gnu/aarch64-rpi4-linux-gnu/sysroot" \
-B"$(HOME)/aarch64-rpi4-linux-gnu/bin/aarch64-rpi4-linux-gnu-" \
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
	$(MAKE) -C uSockets -f rpi-arm64.mk
	$(CXX) -O3 $(CXXFLAGS) -c capi/App.cpp -o capi.o $(LDFLAGS)
	$(AR) rvs libuwebsockets-rpi-arm64.a capi.o uSockets/*.o

all:
	$(MAKE) capi

clean:
	$(MAKE) -C uSockets -f rpi-arm64.mk clean
	rm -f *.o
