HOST_OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
HOST_ARCH := $(shell uname -m)

AR = $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/$(HOST_OS)-$(HOST_ARCH)/bin/llvm-ar
CXX = $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/$(HOST_OS)-$(HOST_ARCH)/bin/aarch64-linux-android30-clang
override CXXFLAGS += -ffunction-sections \
-fdata-sections \
-DANDROID \
-fPIC \
-DANDROIDVERSION=30 \
-m64 \
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
	$(MAKE) -C uSockets -f android.mk
	$(CXX) -O3 $(CXXFLAGS) -c capi/App.cpp -o capi.o $(LDFLAGS)
	$(AR) rvs libuwebsockets-android30.a capi.o uSockets/*.o

all:
	$(MAKE) capi

clean:
	$(MAKE) -C uSockets -f android30.mk clean
	rm -f *.o
