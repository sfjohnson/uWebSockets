override CXXFLAGS += -Wpedantic -Wall -Wextra -Wsign-conversion -Wconversion -std=c++2b -Isrc -IuSockets/src

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
