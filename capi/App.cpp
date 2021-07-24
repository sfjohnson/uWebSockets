#include "libuwebsockets.h"
#include "App.h"

#define UWS_MAX_PAYLOAD_LENGTH 16 * 1024
#define UWS_USE_SSL false

extern "C" {

struct PerSocketData {
  int nothing;
};

typedef uWS::WebSocket<UWS_USE_SSL, true, PerSocketData> uws_cpp_ws_t;

uws_app_t *uws_createApp() {
  return (uws_app_t *) new uWS::App();
}

void uws_appWs(uws_app_t *app, const char *pattern, void (*openHandler)(uws_ws_t *), void (*messageHandler)(uws_ws_t *, const char *, size_t, unsigned char), void (*closeHandler)(uws_ws_t *, int)) {
  uWS::App *uwsApp = (uWS::App *)app;

  uwsApp->ws<PerSocketData>(pattern, {
    .maxPayloadLength = UWS_MAX_PAYLOAD_LENGTH,
    .idleTimeout = 16,
    .maxBackpressure = 64 * 1024,
    .closeOnBackpressureLimit = false,
    .resetIdleTimeoutOnSend = false,
    .sendPingsAutomatically = true,
    /* Handlers */
    .upgrade = nullptr,
    .open = [openHandler](auto *ws) {
      openHandler((uws_ws_t *)ws);
    },
    .message = [messageHandler](auto *ws, std::string_view message, uWS::OpCode opCode) {
      messageHandler((uws_ws_t *)ws, message.data(), message.length(), opCode);
    },
    .close = [closeHandler](auto *ws, int code, std::string_view) {
      closeHandler((uws_ws_t *)ws, code);
    }
  });
}

int uws_wsSend(uws_ws_t *ws, const char *message, size_t length, unsigned char opCode) {
  uws_cpp_ws_t *uwsWs = (uws_cpp_ws_t *)ws;
  std::string_view view(message, length);
  auto status = uwsWs->send(view, static_cast<uWS::OpCode>(opCode), false); // no compression
  switch (status) {
    case uws_cpp_ws_t::SendStatus::SUCCESS: return 0;
    case uws_cpp_ws_t::SendStatus::BACKPRESSURE: return -1;
    case uws_cpp_ws_t::SendStatus::DROPPED: return -2;
  }
}

void uws_appRun(uws_app_t *app) {
  uWS::App *uwsApp = (uWS::App *) app;
  uwsApp->run();
}

void uws_appListen(uws_app_t *app, int port, void (*handler)(void *)) {
  uWS::App *uwsApp = (uWS::App *) app;
  uwsApp->listen(port, [handler](struct us_listen_socket_t *listen_socket) {
    handler((void *) listen_socket);
  });
}

}
