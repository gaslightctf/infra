{ lib, ... }:
{
  custom.instanceExtra = {
    boot_disk.initialize_params.size = lib.mkForce 25;
    machine_type = lib.mkForce "e2-standard-2";
  };

  resource.google_compute_region_backend_service.kanto-backend-https.connection_draining_timeout_sec =
    0;
  resource.google_compute_region_backend_service.kanto-backend-chall-https.connection_draining_timeout_sec =
    0;
  resource.google_compute_region_backend_service.kanto-backend-chall-tls.connection_draining_timeout_sec =
    0;
}
