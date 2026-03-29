{ lib, ... }:
{
  custom.instanceExtra = {
    machine_type = lib.mkForce "e2-medium";
  };

  resource.google_compute_region_backend_service.kanto-lb-https.connection_draining_timeout_sec = 0;
  resource.google_compute_region_backend_service.kanto-lb-chall-https.connection_draining_timeout_sec =
    0;
  resource.google_compute_region_backend_service.kanto-lb-chall-tls.connection_draining_timeout_sec =
    0;
}
