let
  chartAttrs = {
    repo = "oci://ghcr.io/open-telemetry/opentelemetry-helm-charts";
    chart = "opentelemetry-collector";
    version = "0.153.0";
    chartHash = "sha256-oNKv6FAqnJG7YDsQnaS2AfJdzOqQ1fKJfw9oFmGvdew=";
  };
in
{
  flake.modules.nixidy.observability =
    { lib, ... }:
    {
      applications.opentelemetry = {
        helm.releases.opentelemetry-collector = {
          chart = lib.helm.downloadHelmChart chartAttrs;

          values = {
            image.repository = "ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-k8s";

            mode = "daemonset";
            presets = {
              logsCollection.enabled = true;
              kubernetesAttributes.enabled = true;
              kubeletMetrics.enabled = true;
              clusterMetrics.enabled = true;
              kubernetesEvents.enabled = true;
              hostMetrics.enabled = true;
            };

            config = {
              exporters.otlp_http = {
                endpoint = "http://openobserve-openobserve-standalone.openobserve.svc.cluster.local:5080/api/default";

                headers.Authorization = "Basic \${env:OPENOBSERVE_TOKEN}";
              };

              service.pipelines = {
                logs.exporters = [ "otlp_http" ];
                metrics.exporters = [ "otlp_http" ];
                traces.exporters = [ "otlp_http" ];
              };

              receivers.file_log.exclude = [
                "/var/log/pods/*/openobserve-standalone/*.log"
              ];
            };

            extraEnvs = [
              {
                name = "OPENOBSERVE_TOKEN";
                valueFrom.secretKeyRef = {
                  name = "otel-openobserve-auth";
                  key = "token";
                };
              }
            ];
          };
        };
      };
    };
}
