override CXXFLAGS += -Wpedantic -Wall -Wextra -Wsign-conversion -Wconversion -std=c++20 -Isrc -IuSockets/src

ifeq ($(WITH_HOMEBREW_LLVM),1)
	override CXXFLAGS += -I/opt/homebrew/opt/llvm/include
	override CXX = /opt/homebrew/opt/llvm/bin/clang
	override AR = /opt/homebrew/opt/llvm/bin/llvm-ar
endif

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
	$(MAKE) -C uSockets
	$(CXX) -flto -O3 $(CXXFLAGS) -c capi/App.cpp -o capi.o $(LDFLAGS)
	$(AR) rvs libuwebsockets.a capi.o uSockets/*.o

all:
	$(MAKE) capi
