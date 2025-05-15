#include "polycule_client.h"

int main(int argc, char** argv) {
  g_autoptr(PolyculeClient) app = polycule_client_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
