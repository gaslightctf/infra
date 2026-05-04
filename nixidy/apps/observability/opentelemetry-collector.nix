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
              exporters."otlp_http/openobserve" = {
                endpoint = "http://openobserve-openobserve-standalone.openobserve.svc.cluster.local:5080/api/default";

                headers.Authorization = "Basic \${env:OPENOBSERVE_TOKEN}";
              };

              service.pipelines =
                let
                  pipeline = {
                    processors = [
                      "k8sattributes"
                      "attributes/hostname"
                      "memory_limiter"
                      "batch"
                    ];
                    exporters = [ "otlp_http/openobserve" ];
                  };
                in
                {
                  logs = pipeline;
                  metrics = pipeline;
                  traces = pipeline;
                };

              processors = {
                "attributes/hostname".actions = [
                  {
                    key = "host.name";
                    action = "insert";
                    from_attribute = "k8s.node.name";
                  }
                  {
                    key = "host.name";
                    action = "insert";
                    value = "\${OTEL_K8S_NODE_NAME}";
                  }
                ];
              };

              receivers = {
                filelog.exclude = [
                  "/var/log/pods/opentelemetry_opentelemetry-collector*_*/opentelemetry-collector/*.log"
                  "/var/log/pods/openobserve_openobserve-openobserve-standalone*/openobserve-standalone/*.log"

                  # berg submits its own logs through OTLP
                  "/var/log/pods/berg_berg-api*/berg-api/*.log"
                ];

                kubeletstats = {
                  metric_groups = [
                    "pod"
                    "container"
                    "volume"
                  ];
                  metrics = {
                    "k8s.pod.cpu_limit_utilization".enabled = true;
                    "k8s.pod.cpu_request_utilization".enabled = true;
                    "k8s.pod.memory_limit_utilization".enabled = true;
                    "k8s.pod.memory_request_utilization".enabled = true;
                    "k8s.pod.cpu.node.utilization".enabled = true;
                    "k8s.pod.memory.node.utilization".enabled = true;
                  };

                  node = "\${env:OTEL_K8S_NODE_NAME}";
                  k8s_api_config.auth_type = "serviceAccount";
                };

                hostmetrics = {
                  scrapers = {
                    cpu.metrics = {
                      "system.cpu.utilization".enabled = true;
                    };

                    load = { };
                    memory = { };
                    network = { };
                    system = { };
                  };
                };

                journald = {
                  root_path = "/host";
                  journalctl_path = "/run/current-system/sw/bin/journalctl";
                };
              };

            };

            clusterRole.rules = [
              {
                apiGroups = [ "" ];
                resources = [
                  "nodes/stats"
                  "nodes/poxy"
                  "nodes/pods"
                  "nodes/metrics"
                ];
                verbs = [
                  "get"
                  "list"
                  "watch"
                ];
              }
            ];

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
