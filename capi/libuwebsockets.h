#ifndef LIBUWS_CAPI_HEADER
#define LIBUWS_CAPI_HEADER

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

#define UWS_OPCODE_TEXT 1
#define UWS_OPCODE_BINARY 2
#define UWS_OPCODE_CLOSE 8
#define UWS_OPCODE_PING 9
#define UWS_OPCODE_PONG 10

struct uws_app_s;
struct uws_ws_s;
typedef struct uws_app_s uws_app_t;
typedef struct uws_ws_s uws_ws_t;

uws_app_t *uws_create_app();
void uws_app_ws(uws_app_t *app, const char *pattern, void (*openHandler)(uws_ws_t *), void (*messageHandler)(uws_ws_t *, const char *, size_t, unsigned char), void (*closeHandler)(uws_ws_t *, int));
void uws_ws_send(uws_ws_t *ws, const char *message, size_t length, unsigned char opCode);
void uws_app_run(uws_app_t *app);
void uws_app_listen(uws_app_t *app, int port, void (*handler)(void *));

#ifdef __cplusplus
}
#endif

#endif
