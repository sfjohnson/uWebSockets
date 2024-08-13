override CXXFLAGS += -I/opt/homebrew/opt/llvm/include -fPIC -Wpedantic -Wall -Wextra -Wsign-conversion -Wconversion -std=c++20 -Isrc -IuSockets/src

LLVM_PATH := $(shell brew --prefix llvm@15)
override CXX = $(LLVM_PATH)/bin/clang
override AR = $(LLVM_PATH)/bin/llvm-ar

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
	$(MAKE) -C uSockets -f macos.mk
	$(CXX) -flto -O3 $(CXXFLAGS) -c capi/App.cpp -o capi.o $(LDFLAGS)
	$(AR) rvs libuwebsockets.a capi.o uSockets/*.o

all:
	$(MAKE) capi
