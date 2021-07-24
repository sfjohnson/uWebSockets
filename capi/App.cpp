#include "libuwebsockets.h"
#include "App.h"

#define MAX_PAYLOAD_LENGTH 16 * 1024

extern "C" {

struct PerSocketData {
  // int messageLength;
  // char *messageData;
  int nothing;
};

uws_app_t *uws_create_app() {
  return (uws_app_t *) new uWS::App();
}

void uws_app_ws(uws_app_t *app, const char *pattern, void (*openHandler)(uws_ws_t *), void (*messageHandler)(uws_ws_t *, const char *, size_t, int), void (*closeHandler)(uws_ws_t *, int)) {
  uWS::App *uwsApp = (uWS::App *)app;

  uwsApp->ws<PerSocketData>(pattern, {
    .maxPayloadLength = MAX_PAYLOAD_LENGTH,
    .idleTimeout = 16,
    .maxBackpressure = 64 * 1024,
    .closeOnBackpressureLimit = false,
    .resetIdleTimeoutOnSend = false,
    .sendPingsAutomatically = true,
    /* Handlers */
    .upgrade = nullptr,
    .open = [openHandler](auto *ws) {
      openHandler((uws_ws_t *)ws);
      // ws->getUserData()->messageData = (char *)malloc(MAX_PAYLOAD_LENGTH);
    },
    .message = [messageHandler](auto *ws, std::string_view message, uWS::OpCode opCode) {
      messageHandler((uws_ws_t *)ws, message.data(), message.length(), opCode);
    },
    .close = [closeHandler](auto *ws, int code, std::string_view) {
      closeHandler((uws_ws_t *)ws, code);
      // free(ws->getUserData()->messageData);
    }
  });
}

void uws_app_run(uws_app_t *app) {
  uWS::App *uwsApp = (uWS::App *) app;
  uwsApp->run();
}

void uws_app_listen(uws_app_t *app, int port, void (*handler)(void *)) {
  uWS::App *uwsApp = (uWS::App *) app;
  uwsApp->listen(port, [handler](struct us_listen_socket_t *listen_socket) {
    handler((void *) listen_socket);
  });
}

}
