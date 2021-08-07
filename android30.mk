# Android
AR = $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-ar
CXX = $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang
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
