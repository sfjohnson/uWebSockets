EXAMPLE_FILES := Broadcast HelloWorld ServerName EchoServer BroadcastingEchoServer UpgradeSync UpgradeAsync
THREADED_EXAMPLE_FILES := HelloWorldThreaded EchoServerThreaded
override CXXFLAGS += -lpthread -Wpedantic -Wall -Wextra -Wsign-conversion -Wconversion -std=c++2a -Isrc -IuSockets/src -I/usr/local/opt/openssl/include
override LDFLAGS += -lz -L/usr/local/opt/openssl/lib

DESTDIR ?=
prefix ?= /usr/local

# WITH_PROXY enables PROXY Protocol v2 support
ifeq ($(WITH_PROXY),1)
	override CXXFLAGS += -DUWS_WITH_PROXY
endif

# WITH_LIBDEFLATE=1 enables fast paths for SHARED_COMPRESSOR and inflation
ifeq ($(WITH_LIBDEFLATE),1)
	override CXXFLAGS += -I libdeflate -DUWS_USE_LIBDEFLATE
	override LDFLAGS += libdeflate/libdeflate.a
endif

# WITH_OPENSSL=1 enables OpenSSL 1.1+ support
ifeq ($(WITH_OPENSSL),1)
	# With problems on macOS, make sure to pass needed LDFLAGS required to find these
	override LDFLAGS += -lssl -lcrypto
else
	# WITH_WOLFSSL=1 enables WolfSSL 4.2.0 support (mutually exclusive with OpenSSL)
	ifeq ($(WITH_WOLFSSL),1)
		override LDFLAGS += -L/usr/local/lib -lwolfssl
	endif
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
