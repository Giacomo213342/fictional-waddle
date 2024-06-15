#ifndef FLUTTER_POLYCULE_CLIENT_H_
#define FLUTTER_POLYCULE_CLIENT_H_

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(PolyculeClient, polycule_client, POLYCULE, CLIENT,
                     GtkApplication)

/**
 * polycule_client_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #PolyculeClient.
 */
PolyculeClient* polycule_client_new();

#endif  // FLUTTER_POLYCULE_CLIENT_H_
