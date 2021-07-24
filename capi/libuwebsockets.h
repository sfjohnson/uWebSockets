#ifndef LIBUWS_CAPI_HEADER
#define LIBUWS_CAPI_HEADER

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

struct uws_app_s;
struct uws_ws_s;
typedef struct uws_app_s uws_app_t;
typedef struct uws_ws_s uws_ws_t;

uws_app_t *uws_create_app();
void uws_app_ws(uws_app_t *app, const char *pattern, void (*openHandler)(uws_ws_t *), void (*messageHandler)(uws_ws_t *, const char *, size_t, int), void (*closeHandler)(uws_ws_t *, int));
void uws_app_run(uws_app_t *);
void uws_app_listen(uws_app_t *app, int port, void (*handler)(void *));

#ifdef __cplusplus
}
#endif

#endif
