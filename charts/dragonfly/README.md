# Dragonfly Helm Chart

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/dragonfly)](https://artifacthub.io/packages/search?repo=dragonfly)

Delivers efficient, stable, and secure data distribution and acceleration powered by P2P technology.

## TL;DR

```shell
helm repo add dragonfly https://dragonflyoss.github.io/helm-charts/
helm install --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly
```

## Introduction

Delivers efficient, stable, and secure data distribution and acceleration powered by P2P technology,
with an optional content‑addressable filesystem that accelerates OCI container launch.
It aims to provide a best‑practice, standards‑based solution for cloud‑native architectures,
improving large‑scale delivery of files, container images, OCI artifacts, AI/ML models, caches,
logs, dependencies, etc.

## Prerequisites

- Kubernetes cluster 1.20+
- Helm v3.8.0+

## Installation Guide

When use Dragonfly in Kubernetes, a container runtime must be configured. These work can be done by init script in this charts.

For more detail about installation is available in [Kubernetes with Dragonfly](https://d7y.io/docs/getting-started/quick-start/kubernetes/)

We recommend read the details about [Kubernetes with Dragonfly](https://d7y.io/docs/getting-started/quick-start/kubernetes/) before install.

> **We did not recommend to using dragonfly with docker in Kubernetes** due to many reasons: 1. no fallback image pulling policy. 2. deprecated in Kubernetes.

## Installation

### Install with custom configuration

Create the `values.yaml` configuration file. It is recommended to use external redis and mysql instead of containers. This example uses external mysql and redis.

```yaml
mysql:
  enable: false

externalMysql:
  migrate: true
  host: mysql-host
  username: dragonfly
  password: dragonfly
  database: manager
  port: 3306

redis:
  enable: false

externalRedis:
  addrs:
    - redis.example.com:6379
  password: dragonfly
```

Install dragonfly chart with release name `dragonfly`:

```shell
helm repo add dragonfly https://dragonflyoss.github.io/helm-charts/
helm install --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly -f values.yaml
```

### Install with an existing manager

Create the `values.yaml` configuration file. Need to configure the scheduler cluster id associated with scheduler and seed peer. This example is to deploy a cluster using the existing manager and redis.

```yaml
scheduler:
  config:
    manager:
      schedulerClusterID: 1

seedClient:
  config:
    host:
      schedulerClusterID: 1
    seedPeer:
      enable: true
      type: super

manager:
  enable: false

externalManager:
  enable: true
  host: "dragonfly-manager.dragonfly-system.svc.cluster.local"
  restPort: 8080
  grpcPort: 65003

redis:
  enable: false

externalRedis:
  addrs:
    - redis.example.com:6379
  password: dragonfly

mysql:
  enable: false
```

Install dragonfly chart with release name `dragonfly`:

```shell
helm repo add dragonfly https://dragonflyoss.github.io/helm-charts/
helm install --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly -f values.yaml
```

## Uninstall

Uninstall the `dragonfly` deployment:

```shell
helm delete dragonfly --namespace dragonfly-system
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| client.affinity | object | `{}` | Pod affinity. |
| client.config.backend.cacheTemporaryRedirectTTL | string | `"600s"` | TTL of cached 307 redirect targets. |
| client.config.backend.enableCacheTemporaryRedirect | bool | `true` | Cache the target of HTTP 307 redirects, so that the piece requests of one URL do not each resolve the same redirect again. |
| client.config.backend.maxRetries | int | `1` | Maximum retries of a failed chunk request to the backend before the request fails. |
| client.config.backend.putChunkSize | string | `"8MiB"` | Chunk size for uploads to the backend. Larger chunks mean fewer requests and more buffering memory. |
| client.config.backend.putConcurrentChunkCount | int | `16` | Number of chunks uploaded in parallel to the backend. Higher values raise throughput, memory use and backend load. |
| client.config.backend.putTimeout | string | `"900s"` | Timeout for uploading a single object, including all of its chunks, to the backend. |
| client.config.backend.requestHeader | object | `{}` | Extra request headers sent to the origin server. |
| client.config.console | bool | `true` | Print logs to the console instead of the log files. |
| client.config.download.backToSourceBandwidthLimit | string | `"50GB"` | Bandwidth limit for downloads from the source, in GB, MB or KB per second. |
| client.config.download.backToSourceConcurrentPieceCount | int | `8` | Number of pieces downloaded concurrently from the source. |
| client.config.download.bandwidthLimit | string | `"50GB"` | Download bandwidth limit, in GB, MB or KB per second. |
| client.config.download.collectedPieceTimeout | string | `"360s"` | Timeout for collecting one piece from the parent stream. |
| client.config.download.concurrentPieceCount | int | `8` | Number of pieces downloaded concurrently. |
| client.config.download.pieceTimeout | string | `"360s"` | Timeout for downloading a piece from the source. |
| client.config.download.protocol | string | `"tcp"` | Protocol peers use to download pieces, tcp or quic. A parent announces it so that downstream peers use the same one. QUIC suits high-bandwidth, long-RTT or lossy networks, TCP suits low-RTT LAN environments. |
| client.config.download.server.requestRateLimit | int | `50` | Maximum requests per second on the download gRPC server, across all connections. |
| client.config.download.server.requestbufferSize | int | `20` | Capacity of the request queue of the download gRPC server. When it is full, new requests fail with RESOURCE_EXHAUSTED. |
| client.config.download.server.socketPath | string | `"/var/run/dragonfly/dfdaemon.sock"` | Unix socket path of the download gRPC server. |
| client.config.dynconfig.refreshInterval | string | `"5m"` | Interval at which the dynamic configuration is refreshed from the manager. |
| client.config.gc.interval | string | `"900s"` | Interval between garbage collections. |
| client.config.gc.policy.diskHighThresholdPercent | int | `90` | Disk usage percentage above which garbage collection starts. |
| client.config.gc.policy.diskLowThresholdPercent | int | `70` | Disk usage percentage below which garbage collection stops. |
| client.config.gc.policy.persistentCacheTaskTTL | string | `"24h"` | Default TTL of persistent cache tasks whose DownloadPersistentTask request sets none. |
| client.config.gc.policy.persistentTaskTTL | string | `"24h"` | Default TTL of persistent tasks whose DownloadPersistentTask request sets none. |
| client.config.gc.policy.taskTTL | string | `"720h"` | Time a task is kept after its last access. |
| client.config.health.server.port | int | `4003` | Port of the health server. |
| client.config.host | object | `{"idc":"","location":"","schedulerClusterID":1}` | Host information announced to the scheduler. |
| client.config.host.idc | string | `""` | IDC of the host. |
| client.config.host.location | string | `""` | Location of the host. |
| client.config.host.schedulerClusterID | int | `1` | ID of the scheduler cluster to join. When set, idc, location, hostname and ip are ignored when listing schedulers from the manager. The manager creates a cluster with ID 1 by default. |
| client.config.log.level | string | `"info"` | Log level, one of trace, debug, info, warn or error. |
| client.config.metrics.server.port | int | `4002` | Port of the metrics server. |
| client.config.network.enableIPv6 | bool | `false` | Enable IPv6 networking. |
| client.config.proxy.disableBackToSource | bool | `false` | Do not fall back to the source when a proxied download fails. |
| client.config.proxy.prefetch | bool | `true` | Prefetch the whole file when a range request is proxied. The X-Dragonfly-Prefetch request header overrides it per request. |
| client.config.proxy.prefetchBandwidthLimit | string | `"10GB"` | Bandwidth limit for prefetching, in GB, MB or KB per second. Prefetching has lower priority, so the limit keeps it from starving other downloads. |
| client.config.proxy.readBufferSize | int | `2097152` | Buffer size for reading pieces from disk. |
| client.config.proxy.registryMirror.addr | string | `"https://index.docker.io"` | Default upstream registry of the registry mirror served by the proxy. A client selects another registry per request with the X-Dragonfly-Registry header. |
| client.config.proxy.registryMirror.enableTaskIDBasedBlobDigest | bool | `true` | Derive the task ID of OCI blob URLs (/v2/<name>/blobs/sha256:<digest>) from the blob digest instead of the full URL, so that the same blob pulled from different registries shares one task and is downloaded and stored once. |
| client.config.proxy.rules | list | `[{"regex":"blobs/sha256.*","schedulingPolicy":"auto"},{"regex":"manifests/sha256.*","schedulingPolicy":"always"}]` | Proxy rules, the first rule whose regex matches the request URL applies. regex is matched against the URL. useTLS connects to the backend over TLS. redirect rewrites the URL. filteredQueryParams are ignored when computing the task ID, so that e.g. presigned S3, GCS, OSS, OBS and COS URLs that differ only in Signature and Expires share one task. schedulingPolicy is auto or always, auto downloads files no larger than one piece straight from the source, always goes through the scheduler so that even small artifacts such as OCI manifests are shared between peers. Per request, the X-Dragonfly-Use-P2P header forces P2P for URLs that match no rule and X-Dragonfly-Scheduling-Policy overrides the matched schedulingPolicy. |
| client.config.proxy.server.port | int | `4001` | Port of the HTTP proxy server. |
| client.config.proxy.server.requestRateLimit | int | `50` | Maximum requests per second on the HTTP proxy. |
| client.config.scheduler.announceInterval | string | `"5m"` | Interval at which the peer announces itself to the scheduler, including CPU, memory and other host information used for scheduling. |
| client.config.scheduler.enableBackToSource | bool | `true` | Download from the source when scheduling fails. |
| client.config.scheduler.maxScheduleCount | int | `5` | Maximum number of scheduling rounds per download. |
| client.config.scheduler.scheduleTimeout | string | `"3h"` | Timeout for a scheduling interaction with the scheduler. It covers the scheduler response and the pieces the peer downloads and reports back during scheduling. On timeout dfdaemon downloads from the source when enableBackToSource is true, otherwise the download fails. Set it above the longest expected interaction, or TokioStreamElapsed errors appear even though the scheduler is healthy. |
| client.config.server.adaptiveRateLimit | object | `{"bucketCount":50,"bucketInterval":"200ms","collectInterval":"3s","cpuThreshold":100,"memoryThreshold":90,"shedCooldown":"5s"}` | BBR-inspired adaptive rate limiter for the download and upload gRPC servers. When CPU or memory usage exceeds the thresholds, capacity is estimated as max_pass × min_rt × bucket_count / 1000 and requests beyond the in-flight estimate are shed, with a cooldown against oscillation. |
| client.config.server.adaptiveRateLimit.bucketCount | int | `50` | Number of time buckets in the rolling window. |
| client.config.server.adaptiveRateLimit.bucketInterval | string | `"200ms"` | Duration of each time bucket. |
| client.config.server.adaptiveRateLimit.collectInterval | string | `"3s"` | Interval at which CPU and memory usage is sampled. |
| client.config.server.adaptiveRateLimit.cpuThreshold | int | `100` | CPU usage percentage above which the system counts as overloaded. 100 ignores CPU usage. |
| client.config.server.adaptiveRateLimit.memoryThreshold | int | `90` | Memory usage percentage above which the system counts as overloaded. 100 ignores memory usage. |
| client.config.server.adaptiveRateLimit.shedCooldown | string | `"5s"` | Duration to keep shedding requests after the first drop, preventing oscillation. |
| client.config.server.pluginDir | string | `"/usr/local/lib/dragonfly/plugins/dfdaemon/"` | Directory to store plugins. |
| client.config.stats.server.port | int | `4004` | Port of the stats server. |
| client.config.storage.dir | string | `"/var/lib/dragonfly/"` | Directory for task metadata and content. |
| client.config.storage.keep | bool | `true` | Keep task metadata and content across dfdaemon restarts. |
| client.config.storage.readBufferSize | int | `2097152` | Buffer size for reading pieces from disk. |
| client.config.storage.server.quicPort | int | `4006` | Port of the QUIC storage server, which serves pieces to other peers. |
| client.config.storage.server.tcpPort | int | `4005` | Port of the TCP storage server, which serves pieces to other peers. |
| client.config.storage.writeBufferSize | int | `2097152` | Buffer size for writing pieces to disk. |
| client.config.storage.writePieceTimeout | string | `"360s"` | Timeout for writing a piece to storage. |
| client.config.storage.writebackMode | string | `"async"` | How written piece ranges are written back to disk. sync calls sync_file_range per piece, async queues the ranges to a background task, off leaves writeback to the kernel. |
| client.config.tracing.protocol | string | `""` | Protocol used to export traces, one of http, https or grpc. Empty disables tracing. |
| client.config.upload.bandwidthLimit | string | `"50GB"` | Upload bandwidth limit, in GB, MB or KB per second. |
| client.config.upload.disableShared | bool | `false` | Do not share downloaded data with other peers. |
| client.config.upload.server.port | int | `4000` | Port of the upload gRPC server, which serves pieces to other peers. |
| client.config.upload.server.requestRateLimit | int | `200` | Maximum requests per second on the upload gRPC server, across all connections. |
| client.config.upload.server.requestbufferSize | int | `1000` | Capacity of the request queue of the upload gRPC server. When it is full, new requests fail with RESOURCE_EXHAUSTED. |
| client.daemonsetAnnotations | object | `{}` | DaemonSet annotations. |
| client.dfinit.config.console | bool | `true` | Print logs to the console instead of the log files. |
| client.dfinit.config.containerRuntime.containerd.configPath | string | `"/etc/containerd/config.toml"` | configPath is the path of containerd configuration file. When registry.config_path is set in it, as on AKS and EKS, dfinit only writes hosts.toml under that directory, which containerd reloads without a restart. Otherwise dfinit sets config_path to /etc/containerd/certs.d in this file and containerd is restarted once. |
| client.dfinit.config.containerRuntime.containerd.proxyAllRegistries | bool | `true` | Write a catch-all _default/hosts.toml so that registries not listed in registries are also proxied through dfdaemon, which infers the upstream registry from the ns= query parameter containerd appends. Listed registries keep their own hosts.toml and take precedence. |
| client.dfinit.config.containerRuntime.containerd.registries | list | `[{"capabilities":["pull","resolve"],"hostNamespace":"docker.io","serverAddr":"https://index.docker.io","skipVerify":true},{"capabilities":["pull","resolve"],"hostNamespace":"ghcr.io","serverAddr":"https://ghcr.io","skipVerify":true}]` | Registries proxied through dfdaemon, each written as hosts.toml under config_path. hostNamespace is the registry host, e.g. docker.io or ghcr.io, and serverAddr its default server. capabilities, skipVerify and ca map to the containerd hosts.toml fields, refer to https://github.com/containerd/containerd/blob/main/docs/hosts.md. |
| client.dfinit.config.log.level | string | `"info"` | Log level, one of trace, debug, info, warn or error. |
| client.dfinit.config.proxy.addr | string | `"http://127.0.0.1:4001"` | Address of the dfdaemon proxy the container runtime is pointed at. |
| client.dfinit.enable | bool | `false` | Enable dfinit to configure the container runtime of the node to pull images through dfdaemon. |
| client.dfinit.image.digest | string | `""` | Image digest. |
| client.dfinit.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| client.dfinit.image.registry | string | `"docker.io"` | Image registry. |
| client.dfinit.image.repository | string | `"dragonflyoss/dfinit"` | Image repository. |
| client.dfinit.image.tag | string | `"v1.5.10"` | Image tag. |
| client.dynconfig | object | `{"clientConfig":{},"scheduler":{"addr":"","addrs":[]},"seedClientConfig":{}}` | Local dynamic configuration (dynconfig.yaml), delivered as a ConfigMap next to dfdaemon.yaml. It is used only without a manager, that is when manager.enable is false and externalManager.host is empty, and refreshed every client.config.dynconfig.refreshInterval. |
| client.dynconfig.clientConfig | object | `{}` | Block list for normal peers, e.g. { blockList: { task: { download: { applications: [], urls: [], tags: [], priorities: [] } } } }. |
| client.dynconfig.scheduler.addr | string | `""` | Scheduler headless Service address with port, resolved via DNS to every scheduler IP. Empty defaults to the scheduler Service of this chart. |
| client.dynconfig.scheduler.addrs | list | `[]` | Static scheduler addresses with port, e.g. ['192.168.1.10:8002']. They take precedence over addr when set. |
| client.dynconfig.seedClientConfig | object | `{}` | Block list for seed peers, with the same shape as clientConfig. |
| client.enable | bool | `true` | Deploy the client, a dfdaemon DaemonSet that serves downloads and the proxy on every node. |
| client.extraEnvVars | list | `[]` | Extra environment variables for the container. |
| client.extraInitContainers | list | `[]` | Extra init containers for the client pod(s), evaluated as a template and rendered after the chart's built-in init containers. |
| client.extraVolumeMounts | list | `[{"mountPath":"/var/lib/dragonfly/","name":"storage"},{"mountPath":"/var/log/dragonfly/dfdaemon/","name":"logs"}]` | Extra volume mounts for the dfdaemon container. |
| client.extraVolumes | list | `[{"emptyDir":{},"name":"storage"},{"emptyDir":{},"name":"logs"}]` | Extra volumes for the client Pod. |
| client.fullnameOverride | string | `""` | Override the client fully qualified name. |
| client.hostAliases | list | `[]` | Pod hostAliases, extra entries for /etc/hosts. |
| client.hostIPC | bool | `true` | Share the host IPC namespace. |
| client.hostNetwork | bool | `true` | Use the host network namespace. |
| client.hostPID | bool | `true` | Share the host PID namespace. |
| client.image.digest | string | `""` | Image digest. |
| client.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| client.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| client.image.registry | string | `"docker.io"` | Image registry. |
| client.image.repository | string | `"dragonflyoss/client"` | Image repository. |
| client.image.tag | string | `"v1.5.10"` | Image tag. |
| client.initContainer.image.digest | string | `""` | Image digest. |
| client.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| client.initContainer.image.registry | string | `"docker.io"` | Image registry. |
| client.initContainer.image.repository | string | `"busybox"` | Image repository. |
| client.initContainer.image.tag | string | `"latest"` | Image tag. |
| client.initContainer.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Container resource requests and limits. |
| client.maxProcs | string | `""` | Value of the GOMAXPROCS environment variable, the maximum number of OS threads running Go code at once. Empty keeps the runtime default, refer to https://pkg.go.dev/runtime. |
| client.metrics.enable | bool | `true` | Expose Prometheus metrics. |
| client.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels, e.g. to match the Prometheus selector. |
| client.metrics.prometheusRule.enable | bool | `false` | Create a Prometheus Operator PrometheusRule, refer to https://github.com/prometheus-operator/prometheus-operator. |
| client.metrics.prometheusRule.rules | list | `[{"alert":"ClientDown","annotations":{"message":"Client instance {{ \"{{ $labels.instance }}\" }} is down","summary":"Client instance is down"},"expr":"sum(dragonfly_client_version{container=\"client\"}) == 0","for":"5m","labels":{"severity":"critical"}},{"alert":"ClientHighNumberOfFailedDownloadTask","annotations":{"message":"Client has a high number of failed download task","summary":"Client has a high number of failed download task"},"expr":"sum(irate(dragonfly_client_download_task_failure_total{container=\"client\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"ClientSuccessRateOfDownloadingTask","annotations":{"message":"Client's success rate of downloading task is low","summary":"Client's success rate of downloading task is low"},"expr":"(sum(rate(dragonfly_client_download_task_total{container=\"client\"}[1m])) - sum(rate(dragonfly_client_download_task_failure_total{container=\"client\"}[1m]))) / sum(rate(dragonfly_client_download_task_total{container=\"client\"}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}}]` | Prometheus alerting and recording rules. |
| client.metrics.service.annotations | object | `{}` | Service annotations. |
| client.metrics.service.clusterIP | string | `""` | Service cluster IP. |
| client.metrics.service.labels | object | `{}` | Service labels. |
| client.metrics.service.type | string | `"ClusterIP"` | Service type. |
| client.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels, e.g. to match the Prometheus selector. |
| client.metrics.serviceMonitor.enable | bool | `false` | Create a Prometheus Operator ServiceMonitor, refer to https://github.com/prometheus-operator/prometheus-operator. |
| client.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped. |
| client.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended. |
| client.name | string | `"client"` | Component name used in resource names and labels. |
| client.nameOverride | string | `""` | Override the client name. |
| client.nodeSelector | object | `{}` | Node labels for pod assignment. |
| client.podAnnotations | object | `{}` | Pod annotations. |
| client.podLabels | object | `{}` | Pod labels. |
| client.priorityClassName | string | `""` | Pod priority class name. |
| client.resources | object | `{"limits":{"cpu":"4","memory":"8Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Container resource requests and limits. |
| client.sysctlInit.enable | bool | `false` | Enable a privileged init container that sets host sysctls, as the Elasticsearch and OpenSearch charts do. Host-wide network sysctls require hostNetwork, and privileged containers are rejected in PodSecurity restricted namespaces. |
| client.sysctlInit.sysctls | object | `{"net.core.rmem_max":"16777216","net.core.wmem_max":"16777216"}` | Sysctls to set, sized for the socket buffers by default. |
| client.terminationGracePeriodSeconds | string | `nil` | Seconds the Pod is given to terminate gracefully. |
| client.tolerations | list | `[]` | List of node taints to tolerate. |
| client.updateStrategy | object | `{"rollingUpdate":{"maxSurge":0,"maxUnavailable":20},"type":"RollingUpdate"}` | DaemonSet update strategy. |
| clusterDomain | string | `"cluster.local"` | Kubernetes cluster domain used to build in-cluster service addresses. |
| externalManager.grpcPort | int | `65003` | gRPC API port of the external manager. |
| externalManager.host | string | `""` | Hostname of an external manager, used instead of deploying one. |
| externalManager.restPort | int | `8080` | REST API port of the external manager. |
| externalMysql.database | string | `"manager"` | Database name of the external MySQL. |
| externalMysql.host | string | `nil` | Hostname of the external MySQL. |
| externalMysql.migrate | bool | `true` | Run the GORM schema migration on manager startup. |
| externalMysql.password | string | `"dragonfly"` | Password of the external MySQL. |
| externalMysql.port | int | `3306` | Port of the external MySQL. |
| externalMysql.username | string | `"dragonfly"` | Username of the external MySQL. |
| externalPostgres.database | string | `"manager"` | Database name of the external PostgreSQL. |
| externalPostgres.enable | bool | `false` | Use an external PostgreSQL instead of MySQL. |
| externalPostgres.host | string | `nil` | Hostname of the external PostgreSQL. |
| externalPostgres.migrate | bool | `true` | Run the GORM schema migration on manager startup. |
| externalPostgres.password | string | `"dragonfly"` | Password of the external PostgreSQL. |
| externalPostgres.port | int | `5432` | Port of the external PostgreSQL. |
| externalPostgres.sslMode | string | `"disable"` | SSL mode of the external PostgreSQL connection. |
| externalPostgres.timezone | string | `"UTC"` | Timezone of the external PostgreSQL. |
| externalPostgres.username | string | `"dragonfly"` | Username of the external PostgreSQL. |
| externalRedis.addrs | list | `[]` | Addresses of the external redis, e.g. ['redis.example.com:6379'], required when the manager is deployed and redis.enable is false. Empty runs the scheduler without redis and disables the features that need it, such as jobs. |
| externalRedis.backendDB | int | `2` | Redis database index used as the job result backend. |
| externalRedis.brokerDB | int | `1` | Redis database index used as the job broker. |
| externalRedis.db | int | `0` | Redis database index used for caching. |
| externalRedis.masterName | string | `""` | Sentinel master name of the external redis. |
| externalRedis.password | string | `""` | Password of the external redis. |
| externalRedis.sentinelPassword | string | `""` | Sentinel password of the external redis. |
| externalRedis.sentinelUsername | string | `""` | Sentinel username of the external redis. |
| externalRedis.tls | object | `{"caCert":"","cert":"","insecureSkipVerify":false,"key":""}` | TLS client configuration for the external redis connection. |
| externalRedis.tls.caCert | string | `""` | CA certificate file path for the redis TLS handshake. |
| externalRedis.tls.cert | string | `""` | Client certificate file path for the redis TLS handshake. |
| externalRedis.tls.insecureSkipVerify | bool | `false` | Skip verification of the redis server certificate chain and hostname. |
| externalRedis.tls.key | string | `""` | Client key file path for the redis TLS handshake. |
| externalRedis.username | string | `""` | Username of the external redis. |
| fullnameOverride | string | `""` | Override the fully qualified release name used in resource names. |
| global.imagePullSecrets | list | `[]` | Global image pull secrets, as a list of secret names. |
| global.imageRegistry | string | `""` | Global image registry, used by every component image that does not set its own. |
| global.nodeSelector | object | `{}` | Global node selector, used by components that do not set their own. |
| global.storageClass | string | `""` | Global StorageClass for persistent volumes. |
| injector.affinity | object | `{}` | Pod affinity. |
| injector.certManager | object | `{"enable":true,"issuer":{"create":true,"kind":"Issuer","name":""}}` | cert-manager integration for the webhook TLS certificate. cert-manager must be installed. |
| injector.certManager.enable | bool | `true` | Let cert-manager issue and rotate the webhook certificate. |
| injector.certManager.issuer | object | `{"create":true,"kind":"Issuer","name":""}` | Issuer used for the webhook certificate. |
| injector.certManager.issuer.create | bool | `true` | Create a self-signed issuer. When false, an existing issuer must be provided. |
| injector.certManager.issuer.kind | string | `"Issuer"` | Issuer kind, Issuer or ClusterIssuer. |
| injector.certManager.issuer.name | string | `""` | Issuer name. Empty uses the self-signed issuer created by the chart. |
| injector.deploymentAnnotations | object | `{}` | Deployment annotations. |
| injector.enable | bool | `false` | Deploy the injector, a mutating admission webhook that injects a Dragonfly init container into the selected Pods. |
| injector.extraEnvVars | list | `[]` | Extra environment variables for the container. |
| injector.extraInitContainers | list | `[]` | Extra init containers for the injector pod(s), evaluated as a template and rendered after the chart's built-in init containers. |
| injector.extraVolumeMounts | list | `[]` | Extra volume mounts for the injector container. |
| injector.extraVolumes | list | `[]` | Extra volumes for the injector Pod. |
| injector.image.digest | string | `""` | Image digest. |
| injector.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| injector.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| injector.image.registry | string | `"docker.io"` | Image registry. |
| injector.image.repository | string | `"dragonflyoss/injector"` | Image repository. |
| injector.image.tag | string | `"v0.1.0"` | Image tag. |
| injector.initContainerImage | object | `{"digest":"","pullPolicy":"IfNotPresent","pullSecrets":[],"registry":"docker.io","repository":"dragonflyoss/client","tag":"v1.5.10"}` | Image of the init container injected into the target Pods. |
| injector.initContainerImage.digest | string | `""` | Image digest. |
| injector.initContainerImage.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| injector.initContainerImage.pullSecrets | list | `[]` | Image pull secrets. |
| injector.initContainerImage.registry | string | `"docker.io"` | Image registry. |
| injector.initContainerImage.repository | string | `"dragonflyoss/client"` | Image repository. |
| injector.initContainerImage.tag | string | `"v1.5.10"` | Image tag, keep it aligned with the client and seed client version. |
| injector.metrics.enable | bool | `false` | Expose Prometheus metrics. |
| injector.metrics.service.port | int | `8443` | Metrics Service port. |
| injector.nodeSelector | object | `{}` | Node labels for pod assignment. |
| injector.podAnnotations | object | `{}` | Pod annotations. |
| injector.podLabels | object | `{}` | Pod labels. |
| injector.priorityClassName | string | `""` | Pod priority class name. |
| injector.replicas | int | `2` | Number of replicas. |
| injector.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Container resource requests and limits. |
| injector.terminationGracePeriodSeconds | int | `10` | Seconds the Pod is given to terminate gracefully. |
| injector.tolerations | list | `[]` | List of node taints to tolerate. |
| injector.webhook.failurePolicy | string | `"Ignore"` | How webhook errors and timeouts are handled, Ignore or Fail. |
| injector.webhook.namespaceSelector | object | `{"matchExpressions":[{"key":"kubernetes.io/metadata.name","operator":"NotIn","values":["kube-system","cert-manager"]}]}` | Namespaces the webhook applies to. |
| livenessProbe.enable | bool | `true` | Enable liveness probe. |
| livenessProbe.failureThreshold | int | `2` | Failure threshold before the container is restarted. Total time before restart = initialDelaySeconds + (periodSeconds * failureThreshold). |
| livenessProbe.initialDelaySeconds | int | `15` | Initial delay before the first probe. |
| livenessProbe.periodSeconds | int | `10` | Period (in seconds) between probe attempts. |
| livenessProbe.successThreshold | int | `1` | Success threshold for liveness probe. Must be 1 for liveness probes. |
| livenessProbe.timeoutSeconds | int | `3` | Probe timeout (in seconds). |
| manager.config.auth.jwt.key | string | `"ZHJhZ29uZmx5Cg=="` | Secret key used to sign JWT tokens. Change it in production. |
| manager.config.auth.jwt.maxRefresh | string | `"48h"` | Duration during which a client may refresh its JWT token. |
| manager.config.auth.jwt.realm | string | `"Dragonfly"` | Realm name shown to the user. |
| manager.config.auth.jwt.timeout | string | `"48h"` | Duration a JWT token stays valid. |
| manager.config.cache.local.size | int | `30000` | Maximum number of entries in the local LFU cache. |
| manager.config.cache.local.ttl | string | `"3m"` | TTL of entries in the local cache. |
| manager.config.cache.redis.ttl | string | `"5m"` | TTL of entries in the redis cache. |
| manager.config.console | bool | `true` | Print logs to the console. |
| manager.config.job.gc | object | `{"interval":"3h","ttl":"6h"}` | Garbage collection of finished jobs. |
| manager.config.job.gc.interval | string | `"3h"` | Interval between job garbage collections. |
| manager.config.job.gc.ttl | string | `"6h"` | Time a finished job is kept before it is garbage collected. |
| manager.config.job.preheat | object | `{"registryTimeout":"1m","tls":{"insecureSkipVerify":false}}` | Preheat jobs, which download images and files into seed peers ahead of time. |
| manager.config.job.preheat.registryTimeout | string | `"1m"` | Timeout for requesting the token and manifest from the registry. |
| manager.config.job.preheat.tls.insecureSkipVerify | bool | `false` | Skip verification of the registry certificate chain and hostname. |
| manager.config.job.rateLimit | object | `{"capacity":10,"fillInterval":"1m","quantum":10}` | Token bucket rate limit for job requests. |
| manager.config.job.rateLimit.capacity | int | `10` | Maximum number of requests consumed within one fillInterval. |
| manager.config.job.rateLimit.fillInterval | string | `"1m"` | Interval at which the bucket is refilled. |
| manager.config.job.rateLimit.quantum | int | `10` | Number of tokens taken from the bucket per request. |
| manager.config.job.syncPeers | object | `{"interval":"24h","timeout":"10m"}` | Periodic sync of peer information from the schedulers into the manager console. |
| manager.config.job.syncPeers.interval | string | `"24h"` | Interval between syncs of all peer information from the schedulers. |
| manager.config.job.syncPeers.timeout | string | `"10m"` | Timeout for syncing peer information from a single scheduler. |
| manager.config.network.enableIPv6 | bool | `false` | Enable IPv6 networking. |
| manager.config.pprofPort | int | `-1` | Port of the pprof server, -1 disables it. |
| manager.config.server.cacheDir | string | `""` | Directory for the dynamic configuration cache. |
| manager.config.server.grpc.advertiseIP | string | `""` | IP address advertised to schedulers and peers for the gRPC server. |
| manager.config.server.grpc.requestRateLimit | int | `4000` | Maximum number of requests per second accepted by the gRPC server, counting both unary requests and new stream connections. |
| manager.config.server.logDir | string | `""` | Log directory. |
| manager.config.server.logLevel | string | `"info"` | Log level, one of debug, info, warn, error, panic or fatal. |
| manager.config.server.pluginDir | string | `""` | Plugin directory. |
| manager.config.server.rest.tls.cert | string | `""` | TLS certificate file path of the REST server. |
| manager.config.server.rest.tls.key | string | `""` | TLS private key file path of the REST server. |
| manager.config.server.workHome | string | `""` | Work directory. |
| manager.config.tracing.protocol | string | `"grpc"` | Protocol used to export traces, one of http, https or grpc. Empty disables tracing. |
| manager.deploymentAnnotations | object | `{}` | Deployment annotations. |
| manager.enable | bool | `false` | Deploy the manager, which serves the console and the REST and gRPC APIs and stores the cluster, scheduler, seed peer and job state. |
| manager.extraEnvVars | list | `[]` | Extra environment variables for the container. |
| manager.extraInitContainers | list | `[]` | Extra init containers for the manager pod(s), evaluated as a template and rendered after the chart's built-in init containers. |
| manager.extraVolumeMounts | list | `[{"mountPath":"/var/log/dragonfly/manager","name":"logs"}]` | Extra volume mounts for the manager container. |
| manager.extraVolumes | list | `[{"emptyDir":{},"name":"logs"}]` | Extra volumes for the manager Pod. |
| manager.fullnameOverride | string | `""` | Override the manager fully qualified name. |
| manager.grpcPort | int | `65003` | Port of the gRPC API on the Service. |
| manager.hostAliases | list | `[]` | Pod hostAliases, extra entries for /etc/hosts. |
| manager.hostNetwork | bool | `false` | Use the host network namespace. |
| manager.image.digest | string | `""` | Image digest. |
| manager.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| manager.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| manager.image.registry | string | `"docker.io"` | Image registry. |
| manager.image.repository | string | `"dragonflyoss/manager"` | Image repository. |
| manager.image.tag | string | `"v2.5.3-rc.1"` | Image tag. |
| manager.ingress.annotations | object | `{}` | Ingress annotations. |
| manager.ingress.className | string | `""` | Ingress class name, requires Kubernetes 1.18 or later. |
| manager.ingress.enable | bool | `false` | Enable ingress. |
| manager.ingress.hosts | list | `[]` | Ingress hosts. |
| manager.ingress.path | string | `"/"` | Ingress path. |
| manager.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type, requires Kubernetes 1.18 or later. |
| manager.ingress.tls | list | `[]` | Ingress TLS configuration. |
| manager.initContainer.image.digest | string | `""` | Image digest. |
| manager.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| manager.initContainer.image.registry | string | `"docker.io"` | Image registry. |
| manager.initContainer.image.repository | string | `"busybox"` | Image repository. |
| manager.initContainer.image.tag | string | `"latest"` | Image tag. |
| manager.initContainer.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Container resource requests and limits. |
| manager.maxProcs | string | `""` | Value of the GOMAXPROCS environment variable, the maximum number of OS threads running Go code at once. Empty keeps the runtime default, refer to https://pkg.go.dev/runtime. |
| manager.metrics.enable | bool | `true` | Expose Prometheus metrics. |
| manager.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels, e.g. to match the Prometheus selector. |
| manager.metrics.prometheusRule.enable | bool | `false` | Create a Prometheus Operator PrometheusRule, refer to https://github.com/prometheus-operator/prometheus-operator. |
| manager.metrics.prometheusRule.rules | list | `[{"alert":"ManagerDown","annotations":{"message":"Manager instance {{ \"{{ $labels.instance }}\" }} is down","summary":"Manager instance is down"},"expr":"sum(dragonfly_manager_version{}) == 0","for":"5m","labels":{"severity":"critical"}},{"alert":"ManagerHighNumberOfFailedGRPCRequest","annotations":{"message":"Manager has a high number of failed grpc request","summary":"Manager has a high number of failed grpc request"},"expr":"sum(rate(grpc_server_started_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\"}[1m])) - sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"OK\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"NotFound\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"PermissionDenied\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"InvalidArgument\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"ManagerSuccessRateOfGRPCRequest","annotations":{"message":"Manager's success rate of grpc request is low","summary":"Manager's success rate of grpc request is low"},"expr":"(sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"OK\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"NotFound\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"PermissionDenied\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"InvalidArgument\"}[1m]))) / sum(rate(grpc_server_started_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\"}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"ManagerHighNumberOfFailedRESTRequest","annotations":{"message":"Manager has a high number of failed rest request","summary":"Manager has a high number of failed rest request"},"expr":"sum(rate(dragonfly_manager_requests_total{}[1m])) - sum(rate(dragonfly_manager_requests_total{code=~\"[12]..\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"ManagerSuccessRateOfRESTRequest","annotations":{"message":"Manager's success rate of rest request is low","summary":"Manager's success rate of rest request is low"},"expr":"sum(rate(dragonfly_manager_requests_total{code=~\"[12]..\"}[1m])) / sum(rate(dragonfly_manager_requests_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}}]` | Prometheus alerting and recording rules. |
| manager.metrics.service.annotations | object | `{}` | Service annotations. |
| manager.metrics.service.clusterIP | string | `""` | Service cluster IP. |
| manager.metrics.service.labels | object | `{}` | Service labels. |
| manager.metrics.service.type | string | `"ClusterIP"` | Service type. |
| manager.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels, e.g. to match the Prometheus selector. |
| manager.metrics.serviceMonitor.enable | bool | `false` | Create a Prometheus Operator ServiceMonitor, refer to https://github.com/prometheus-operator/prometheus-operator. |
| manager.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped. |
| manager.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended. |
| manager.name | string | `"manager"` | Component name used in resource names and labels. |
| manager.nameOverride | string | `""` | Override the manager name. |
| manager.nodeSelector | object | `{}` | Node labels for pod assignment. |
| manager.podAnnotations | object | `{}` | Pod annotations. |
| manager.podLabels | object | `{}` | Pod labels. |
| manager.priorityClassName | string | `""` | Pod priority class name. |
| manager.replicas | int | `3` | Number of replicas. |
| manager.resources | object | `{"limits":{"cpu":"8","memory":"16Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Container resource requests and limits. |
| manager.restPort | int | `8080` | Port of the REST API on the Service. |
| manager.service.annotations | object | `{}` | Service annotations. |
| manager.service.clusterIP | string | `""` | Service cluster IP. |
| manager.service.labels | object | `{}` | Service labels. |
| manager.service.nodePort | string | `""` | Service node port. |
| manager.service.type | string | `"ClusterIP"` | Service type. |
| manager.terminationGracePeriodSeconds | string | `nil` | Seconds the Pod is given to terminate gracefully. |
| manager.tolerations | list | `[]` | List of node taints to tolerate. |
| manager.updateStrategy | object | `{"type":"RollingUpdate"}` | Deployment update strategy. |
| mysql.auth.database | string | `"manager"` | MySQL database name. |
| mysql.auth.host | string | `""` | MySQL hostname. |
| mysql.auth.password | string | `"dragonfly"` | MySQL password. |
| mysql.auth.rootPassword | string | `"dragonfly-root"` | MySQL root password. |
| mysql.auth.username | string | `"dragonfly"` | MySQL username. |
| mysql.clusterDomain | string | `"cluster.local"` | Cluster domain passed to the subchart. |
| mysql.enable | bool | `false` | Deploy the Bitnami MySQL subchart, only used when the manager is deployed. |
| mysql.image.repository | string | `"bitnamilegacy/mysql"` |  |
| mysql.migrate | bool | `true` | Run the GORM schema migration on manager startup. |
| mysql.primary.service.port | int | `3306` | MySQL port. |
| nameOverride | string | `""` | Override the chart name used in resource names. |
| namespaceOverride | string | `""` | Override the namespace the resources are installed into. |
| readinessProbe.enable | bool | `true` | Enable readiness probe. |
| readinessProbe.failureThreshold | int | `2` | Failure threshold before the container is marked as not ready. Total time before marked not ready = initialDelaySeconds + (periodSeconds * failureThreshold). |
| readinessProbe.initialDelaySeconds | int | `10` | Initial delay before the first probe. |
| readinessProbe.periodSeconds | int | `10` | Period (in seconds) between probe attempts. |
| readinessProbe.successThreshold | int | `1` | Success threshold for readiness probe. The container will be marked as ready after this many consecutive successes. |
| readinessProbe.timeoutSeconds | int | `3` | Probe timeout (in seconds). |
| redis.auth.enabled | bool | `true` | Require password authentication. |
| redis.auth.password | string | `"dragonfly"` | Redis password. |
| redis.clusterDomain | string | `"cluster.local"` | Cluster domain passed to the subchart. |
| redis.enable | bool | `false` | Deploy the Bitnami Redis subchart, only used when the manager is deployed. |
| redis.image.repository | string | `"bitnamilegacy/redis"` |  |
| redis.master.service.ports.redis | int | `6379` | Redis master Service port. |
| scheduler.config.console | bool | `true` | Print logs to the console. |
| scheduler.config.dynconfig.refreshInterval | string | `"1m"` | Interval at which the dynamic configuration is refreshed from the manager. |
| scheduler.config.host.idc | string | `""` | IDC the scheduler runs in. |
| scheduler.config.host.location | string | `""` | Location the scheduler runs in. |
| scheduler.config.manager.keepAlive.interval | string | `"5s"` | Interval between keepalive messages to the manager. |
| scheduler.config.manager.schedulerClusterID | int | `1` | ID of the scheduler cluster in the manager that this scheduler joins. |
| scheduler.config.network.enableIPv6 | bool | `false` | Enable IPv6 networking. |
| scheduler.config.pprofPort | int | `-1` | Port of the pprof server, -1 disables it. |
| scheduler.config.scheduler.algorithm | string | `"default"` | Scheduling algorithm. default uses the built-in evaluator. plugin loads the compiled d7y-scheduler-plugin-evaluator.so from the plugins folder of the working directory. |
| scheduler.config.scheduler.backToSourceCount | int | `200` | Number of peers per task allowed to download from the source. |
| scheduler.config.scheduler.gc.hostGCInterval | string | `"5m"` | Interval between host garbage collections. |
| scheduler.config.scheduler.gc.hostTTL | string | `"1h"` | Time a host is kept without announcing itself to the scheduler. It is reset on every announcement. |
| scheduler.config.scheduler.gc.peerGCInterval | string | `"5m"` | Interval between peer garbage collections. |
| scheduler.config.scheduler.gc.peerTTL | string | `"720h"` | Time a peer is kept without activity. It is reset whenever another peer downloads from it. |
| scheduler.config.scheduler.gc.pieceDownloadTimeout | string | `"30m"` | Timeout for downloading a piece. |
| scheduler.config.scheduler.gc.taskGCInterval | string | `"30m"` | Interval between task garbage collections. A task is reclaimed once all of its peers are. |
| scheduler.config.scheduler.retryBackToSourceLimit | int | `3` | Number of failed scheduling attempts after which the peer downloads from the source. |
| scheduler.config.scheduler.retryInterval | string | `"1s"` | Interval between scheduling attempts. |
| scheduler.config.scheduler.retryLimit | int | `5` | Number of scheduling attempts after which scheduling fails. |
| scheduler.config.seedPeer | string | `nil` |  |
| scheduler.config.server.advertiseIP | string | `""` | IP address advertised to peers and the manager. |
| scheduler.config.server.advertisePort | int | `8002` | Port advertised to peers and the manager. |
| scheduler.config.server.cacheDir | string | `""` | Directory for the dynamic configuration cache. |
| scheduler.config.server.dataDir | string | `""` | Directory for scheduler data. |
| scheduler.config.server.listenIP | string | `"0.0.0.0"` | IP address the gRPC server listens on. |
| scheduler.config.server.logDir | string | `""` | Log directory. |
| scheduler.config.server.logLevel | string | `"info"` | Log level, one of debug, info, warn, error, panic or fatal. |
| scheduler.config.server.pluginDir | string | `""` | Plugin directory. |
| scheduler.config.server.port | int | `8002` | Port the gRPC server listens on. |
| scheduler.config.server.requestRateLimit | int | `4000` | Maximum number of requests per second accepted by the gRPC server, counting both unary requests and new stream connections. |
| scheduler.config.server.workHome | string | `""` | Work directory. |
| scheduler.config.tracing.protocol | string | `""` | Protocol used to export traces, one of http, https or grpc. Empty disables tracing. |
| scheduler.containerPort | int | `8002` | Container port of the gRPC server. |
| scheduler.dynconfig | object | `{"applications":[],"schedulerClusterClientConfig":{"loadLimit":200},"schedulerClusterConfig":{"candidateParentLimit":3,"filterParentLimit":15},"seedPeerClusterConfig":{"loadLimit":2000}}` | Local dynamic configuration (dynconfig.yaml), delivered as a ConfigMap next to scheduler.yaml. It is used only without a manager, that is when manager.enable is false and externalManager.host is empty, and refreshed every scheduler.config.dynconfig.refreshInterval. |
| scheduler.dynconfig.applications | list | `[]` | Applications known to the scheduler and their download priorities. |
| scheduler.dynconfig.schedulerClusterClientConfig | object | `{"loadLimit":200}` | Client configuration pushed to the peers of this cluster. |
| scheduler.dynconfig.schedulerClusterClientConfig.loadLimit | int | `200` | Maximum number of concurrent uploads per peer. |
| scheduler.dynconfig.schedulerClusterConfig | object | `{"candidateParentLimit":3,"filterParentLimit":15}` | Scheduler cluster configuration. |
| scheduler.dynconfig.schedulerClusterConfig.candidateParentLimit | int | `3` | Maximum number of candidate parents returned to a peer per scheduling. |
| scheduler.dynconfig.schedulerClusterConfig.filterParentLimit | int | `15` | Maximum number of parents considered when filtering candidates. |
| scheduler.dynconfig.seedPeerClusterConfig | object | `{"loadLimit":2000}` | Seed peer cluster configuration. |
| scheduler.dynconfig.seedPeerClusterConfig.loadLimit | int | `2000` | Maximum number of concurrent uploads per seed peer. |
| scheduler.enable | bool | `true` | Deploy the scheduler, which picks parent peers for every download and tracks the peer, task and host state. |
| scheduler.extraEnvVars | list | `[]` | Extra environment variables for the container. |
| scheduler.extraInitContainers | list | `[]` | Extra init containers for the scheduler pod(s), evaluated as a template and rendered after the chart's built-in init containers. |
| scheduler.extraVolumeMounts | list | `[{"mountPath":"/var/log/dragonfly/scheduler","name":"logs"}]` | Extra volume mounts for the scheduler container. |
| scheduler.extraVolumes | list | `[{"emptyDir":{},"name":"logs"}]` | Extra volumes for the scheduler Pod. |
| scheduler.fullnameOverride | string | `""` | Override the scheduler fully qualified name. |
| scheduler.hostAliases | list | `[]` | Pod hostAliases, extra entries for /etc/hosts. |
| scheduler.hostNetwork | bool | `false` | Use the host network namespace. |
| scheduler.image.digest | string | `""` | Image digest. |
| scheduler.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| scheduler.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| scheduler.image.registry | string | `"docker.io"` | Image registry. |
| scheduler.image.repository | string | `"dragonflyoss/scheduler"` | Image repository. |
| scheduler.image.tag | string | `"v2.5.3-rc.1"` | Image tag. |
| scheduler.initContainer.image.digest | string | `""` | Image digest. |
| scheduler.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| scheduler.initContainer.image.registry | string | `"docker.io"` | Image registry. |
| scheduler.initContainer.image.repository | string | `"busybox"` | Image repository. |
| scheduler.initContainer.image.tag | string | `"latest"` | Image tag. |
| scheduler.initContainer.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Container resource requests and limits. |
| scheduler.maxProcs | string | `""` | Value of the GOMAXPROCS environment variable, the maximum number of OS threads running Go code at once. Empty keeps the runtime default, refer to https://pkg.go.dev/runtime. |
| scheduler.metrics.enable | bool | `true` | Expose Prometheus metrics. |
| scheduler.metrics.enableHost | bool | `false` | Expose per-host metrics. |
| scheduler.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels, e.g. to match the Prometheus selector. |
| scheduler.metrics.prometheusRule.enable | bool | `false` | Create a Prometheus Operator PrometheusRule, refer to https://github.com/prometheus-operator/prometheus-operator. |
| scheduler.metrics.prometheusRule.rules | list | `[{"alert":"SchedulerDown","annotations":{"message":"Scheduler instance {{ \"{{ $labels.instance }}\" }} is down","summary":"Scheduler instance is down"},"expr":"sum(dragonfly_scheduler_version{}) == 0","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedDownloadPeer","annotations":{"message":"Scheduler has a high number of failed download peer","summary":"Scheduler has a high number of failed download peer"},"expr":"sum(irate(dragonfly_scheduler_download_peer_finished_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfDownloadingPeer","annotations":{"message":"Scheduler's success rate of downloading peer is low","summary":"Scheduler's success rate of downloading peer is low"},"expr":"(sum(rate(dragonfly_scheduler_download_peer_finished_total{}[1m])) - sum(rate(dragonfly_scheduler_download_peer_finished_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_download_peer_finished_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedRegisterPeer","annotations":{"message":"Scheduler has a high number of failed register peer","summary":"Scheduler has a high number of failed register peer"},"expr":"sum(irate(dragonfly_scheduler_register_peer_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfRegisterTask","annotations":{"message":"Scheduler's success rate of register peer is low","summary":"Scheduler's success rate of register peer is low"},"expr":"(sum(rate(dragonfly_scheduler_register_peer_total{}[1m])) - sum(rate(dragonfly_scheduler_register_peer_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_register_peer_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedLeavePeer","annotations":{"message":"Scheduler has a high number of failed leave peer","summary":"Scheduler has a high number of failed leave peer"},"expr":"sum(irate(dragonfly_scheduler_leave_peer_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfLeavingPeer","annotations":{"message":"Scheduler's success rate of leaving peer is low","summary":"Scheduler's success rate of leaving peer is low"},"expr":"(sum(rate(dragonfly_scheduler_leave_peer_total{}[1m])) - sum(rate(dragonfly_scheduler_leave_peer_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_leave_peer_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedStatTask","annotations":{"message":"Scheduler has a high number of failed stat task","summary":"Scheduler has a high number of failed stat task"},"expr":"sum(irate(dragonfly_scheduler_stat_task_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfStatTask","annotations":{"message":"Scheduler's success rate of stat task is low","summary":"Scheduler's success rate of stat task is low"},"expr":"(sum(rate(dragonfly_scheduler_stat_task_total{}[1m])) - sum(rate(dragonfly_scheduler_stat_task_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_stat_task_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedAnnouncePeer","annotations":{"message":"Scheduler has a high number of failed announce peer","summary":"Scheduler has a high number of failed announce peer"},"expr":"sum(irate(dragonfly_scheduler_announce_peer_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfAnnouncingPeer","annotations":{"message":"Scheduler's success rate of announcing peer is low","summary":"Scheduler's success rate of announcing peer is low"},"expr":"(sum(rate(dragonfly_scheduler_announce_peer_total{}[1m])) - sum(rate(dragonfly_scheduler_announce_peer_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_announce_peer_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedLeaveHost","annotations":{"message":"Scheduler has a high number of failed leave host","summary":"Scheduler has a high number of failed leave host"},"expr":"sum(irate(dragonfly_scheduler_leave_host_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfLeavingHost","annotations":{"message":"Scheduler's success rate of leaving host is low","summary":"Scheduler's success rate of leaving host is low"},"expr":"(sum(rate(dragonfly_scheduler_leave_host_total{}[1m])) - sum(rate(dragonfly_scheduler_leave_host_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_leave_host_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedAnnounceHost","annotations":{"message":"Scheduler has a high number of failed annoucne host","summary":"Scheduler has a high number of failed annoucne host"},"expr":"sum(irate(dragonfly_scheduler_announce_host_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfAnnouncingHost","annotations":{"message":"Scheduler's success rate of announcing host is low","summary":"Scheduler's success rate of announcing host is low"},"expr":"(sum(rate(dragonfly_scheduler_announce_host_total{}[1m])) - sum(rate(dragonfly_scheduler_announce_host_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_announce_host_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedGRPCRequest","annotations":{"message":"Scheduler has a high number of failed grpc request","summary":"Scheduler has a high number of failed grpc request"},"expr":"sum(rate(grpc_server_started_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\"}[1m])) - sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"OK\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"NotFound\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"PermissionDenied\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"InvalidArgument\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfGRPCRequest","annotations":{"message":"Scheduler's success rate of grpc request is low","summary":"Scheduler's success rate of grpc request is low"},"expr":"(sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"OK\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"NotFound\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"PermissionDenied\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"InvalidArgument\"}[1m]))) / sum(rate(grpc_server_started_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\"}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}}]` | Prometheus alerting and recording rules. |
| scheduler.metrics.service.annotations | object | `{}` | Service annotations. |
| scheduler.metrics.service.clusterIP | string | `""` | Service cluster IP. |
| scheduler.metrics.service.labels | object | `{}` | Service labels. |
| scheduler.metrics.service.type | string | `"ClusterIP"` | Service type. |
| scheduler.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels, e.g. to match the Prometheus selector. |
| scheduler.metrics.serviceMonitor.enable | bool | `false` | Create a Prometheus Operator ServiceMonitor, refer to https://github.com/prometheus-operator/prometheus-operator. |
| scheduler.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped. |
| scheduler.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended. |
| scheduler.name | string | `"scheduler"` | Component name used in resource names and labels. |
| scheduler.nameOverride | string | `""` | Override the scheduler name. |
| scheduler.nodeSelector | object | `{}` | Node labels for pod assignment. |
| scheduler.podAnnotations | object | `{}` | Pod annotations. |
| scheduler.podLabels | object | `{}` | Pod labels. |
| scheduler.priorityClassName | string | `""` | Pod priority class name. |
| scheduler.replicas | int | `3` | Number of replicas. |
| scheduler.resources | object | `{"limits":{"cpu":"8","memory":"16Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Container resource requests and limits. |
| scheduler.service | object | `{"annotations":{},"labels":{}}` | Headless Service of the scheduler, so that clients discover every scheduler IP via DNS. |
| scheduler.service.annotations | object | `{}` | Service annotations. |
| scheduler.service.labels | object | `{}` | Service labels. |
| scheduler.statefulsetAnnotations | object | `{}` | StatefulSet annotations. |
| scheduler.terminationGracePeriodSeconds | string | `nil` | Seconds the Pod is given to terminate gracefully. |
| scheduler.tolerations | list | `[]` | List of node taints to tolerate. |
| scheduler.updateStrategy | object | `{}` | StatefulSet update strategy. |
| seedClient.affinity | object | `{}` | Pod affinity. |
| seedClient.config.backend.cacheTemporaryRedirectTTL | string | `"600s"` | TTL of cached 307 redirect targets. |
| seedClient.config.backend.enableCacheTemporaryRedirect | bool | `true` | Cache the target of HTTP 307 redirects, so that the piece requests of one URL do not each resolve the same redirect again. |
| seedClient.config.backend.maxRetries | int | `1` | Maximum retries of a failed chunk request to the backend before the request fails. |
| seedClient.config.backend.putChunkSize | string | `"8MiB"` | Chunk size for uploads to the backend. Larger chunks mean fewer requests and more buffering memory. |
| seedClient.config.backend.putConcurrentChunkCount | int | `16` | Number of chunks uploaded in parallel to the backend. Higher values raise throughput, memory use and backend load. |
| seedClient.config.backend.putTimeout | string | `"900s"` | Timeout for uploading a single object, including all of its chunks, to the backend. |
| seedClient.config.backend.requestHeader | object | `{}` | Extra request headers sent to the origin server. |
| seedClient.config.console | bool | `true` | Print logs to the console instead of the log files. |
| seedClient.config.download.backToSourceBandwidthLimit | string | `"50GB"` | Bandwidth limit for downloads from the source, in GB, MB or KB per second. |
| seedClient.config.download.backToSourceConcurrentPieceCount | int | `8` | Number of pieces downloaded concurrently from the source. |
| seedClient.config.download.bandwidthLimit | string | `"50GB"` | Download bandwidth limit, in GB, MB or KB per second. |
| seedClient.config.download.collectedPieceTimeout | string | `"5s"` | Timeout for collecting one piece from the parent stream. |
| seedClient.config.download.concurrentPieceCount | int | `8` | Number of pieces downloaded concurrently. |
| seedClient.config.download.pieceTimeout | string | `"40s"` | Timeout for downloading a piece from the source. |
| seedClient.config.download.protocol | string | `"tcp"` | Protocol peers use to download pieces, tcp or quic. A parent announces it so that downstream peers use the same one. QUIC suits high-bandwidth, long-RTT or lossy networks, TCP suits low-RTT LAN environments. |
| seedClient.config.download.server.requestRateLimit | int | `400` | Maximum requests per second on the download gRPC server, across all connections. |
| seedClient.config.download.server.requestbufferSize | int | `50` | Capacity of the request queue of the download gRPC server. When it is full, new requests fail with RESOURCE_EXHAUSTED. |
| seedClient.config.download.server.socketPath | string | `"/var/run/dragonfly/dfdaemon.sock"` | Unix socket path of the download gRPC server. |
| seedClient.config.dynconfig.refreshInterval | string | `"1m"` | Interval at which the dynamic configuration is refreshed from the manager. |
| seedClient.config.gc.interval | string | `"900s"` | Interval between garbage collections. |
| seedClient.config.gc.policy.diskHighThresholdPercent | int | `90` | Disk usage percentage above which garbage collection starts. |
| seedClient.config.gc.policy.diskLowThresholdPercent | int | `70` | Disk usage percentage below which garbage collection stops. |
| seedClient.config.gc.policy.persistentCacheTaskTTL | string | `"24h"` | Default TTL of persistent cache tasks whose DownloadPersistentTask request sets none. |
| seedClient.config.gc.policy.persistentTaskTTL | string | `"24h"` | Default TTL of persistent tasks whose DownloadPersistentTask request sets none. |
| seedClient.config.gc.policy.taskTTL | string | `"720h"` | Time a task is kept after its last access. |
| seedClient.config.health.server.port | int | `4003` | Port of the health server. |
| seedClient.config.host | object | `{"idc":"","location":"","schedulerClusterID":1}` | Host information announced to the scheduler. |
| seedClient.config.host.idc | string | `""` | IDC of the host. |
| seedClient.config.host.location | string | `""` | Location of the host. |
| seedClient.config.host.schedulerClusterID | int | `1` | ID of the scheduler cluster to join. When set, idc, location, hostname and ip are ignored when listing schedulers from the manager. The manager creates a cluster with ID 1 by default. |
| seedClient.config.log.level | string | `"info"` | Log level, one of trace, debug, info, warn or error. |
| seedClient.config.metrics.server.port | int | `4002` | Port of the metrics server. |
| seedClient.config.network.enableIPv6 | bool | `false` | Enable IPv6 networking. |
| seedClient.config.proxy.disableBackToSource | bool | `false` | Do not fall back to the source when a proxied download fails. |
| seedClient.config.proxy.prefetch | bool | `true` | Prefetch the whole file when a range request is proxied. The X-Dragonfly-Prefetch request header overrides it per request. |
| seedClient.config.proxy.prefetchBandwidthLimit | string | `"10GB"` | Bandwidth limit for prefetching, in GB, MB or KB per second. Prefetching has lower priority, so the limit keeps it from starving other downloads. |
| seedClient.config.proxy.readBufferSize | int | `2097152` | Buffer size for reading pieces from disk. |
| seedClient.config.proxy.registryMirror.addr | string | `"https://index.docker.io"` | Default upstream registry of the registry mirror served by the proxy. A client selects another registry per request with the X-Dragonfly-Registry header. |
| seedClient.config.proxy.registryMirror.enableTaskIDBasedBlobDigest | bool | `true` | Derive the task ID of OCI blob URLs (/v2/<name>/blobs/sha256:<digest>) from the blob digest instead of the full URL, so that the same blob pulled from different registries shares one task and is downloaded and stored once. |
| seedClient.config.proxy.rules | list | `[{"regex":"blobs/sha256.*","schedulingPolicy":"auto"},{"regex":"manifests/sha256.*","schedulingPolicy":"auto"}]` | Proxy rules, the first rule whose regex matches the request URL applies. regex is matched against the URL. useTLS connects to the backend over TLS. redirect rewrites the URL. filteredQueryParams are ignored when computing the task ID, so that e.g. presigned S3, GCS, OSS, OBS and COS URLs that differ only in Signature and Expires share one task. schedulingPolicy is auto or always, auto downloads files no larger than one piece straight from the source, always goes through the scheduler so that even small artifacts such as OCI manifests are shared between peers. Per request, the X-Dragonfly-Use-P2P header forces P2P for URLs that match no rule and X-Dragonfly-Scheduling-Policy overrides the matched schedulingPolicy. |
| seedClient.config.proxy.server.port | int | `4001` | Port of the HTTP proxy server. |
| seedClient.config.proxy.server.requestRateLimit | int | `400` | Maximum requests per second on the HTTP proxy. |
| seedClient.config.scheduler.announceInterval | string | `"1m"` | Interval at which the peer announces itself to the scheduler, including CPU, memory and other host information used for scheduling. |
| seedClient.config.scheduler.maxScheduleCount | int | `5` | Maximum number of scheduling rounds per download. |
| seedClient.config.scheduler.scheduleTimeout | string | `"3h"` | Timeout for a scheduling interaction with the scheduler. It covers the scheduler response and the pieces the peer downloads and reports back during scheduling. On timeout dfdaemon downloads from the source when enableBackToSource is true, otherwise the download fails. Set it above the longest expected interaction, or TokioStreamElapsed errors appear even though the scheduler is healthy. |
| seedClient.config.seedPeer.enable | bool | `true` | Register this dfdaemon as a seed peer. |
| seedClient.config.seedPeer.type | string | `"super"` | Seed peer type, one of super, strong or weak. |
| seedClient.config.server.adaptiveRateLimit | object | `{"bucketCount":50,"bucketInterval":"200ms","collectInterval":"3s","cpuThreshold":100,"memoryThreshold":90,"shedCooldown":"5s"}` | BBR-inspired adaptive rate limiter for the download and upload gRPC servers. When CPU or memory usage exceeds the thresholds, capacity is estimated as max_pass × min_rt × bucket_count / 1000 and requests beyond the in-flight estimate are shed, with a cooldown against oscillation. |
| seedClient.config.server.adaptiveRateLimit.bucketCount | int | `50` | Number of time buckets in the rolling window. |
| seedClient.config.server.adaptiveRateLimit.bucketInterval | string | `"200ms"` | Duration of each time bucket. |
| seedClient.config.server.adaptiveRateLimit.collectInterval | string | `"3s"` | Interval at which CPU and memory usage is sampled. |
| seedClient.config.server.adaptiveRateLimit.cpuThreshold | int | `100` | CPU usage percentage above which the system counts as overloaded. 100 ignores CPU usage. |
| seedClient.config.server.adaptiveRateLimit.memoryThreshold | int | `90` | Memory usage percentage above which the system counts as overloaded. 100 ignores memory usage. |
| seedClient.config.server.adaptiveRateLimit.shedCooldown | string | `"5s"` | Duration to keep shedding requests after the first drop, preventing oscillation. |
| seedClient.config.server.pluginDir | string | `"/usr/local/lib/dragonfly/plugins/dfdaemon/"` | Directory to store plugins. |
| seedClient.config.stats.server.port | int | `4004` | Port of the stats server. |
| seedClient.config.storage.dir | string | `"/var/lib/dragonfly/"` | Directory for task metadata and content. |
| seedClient.config.storage.keep | bool | `true` | Keep task metadata and content across dfdaemon restarts. |
| seedClient.config.storage.readBufferSize | int | `2097152` | Buffer size for reading pieces from disk. |
| seedClient.config.storage.server.quicPort | int | `4006` | Port of the QUIC storage server, which serves pieces to other peers. |
| seedClient.config.storage.server.tcpPort | int | `4005` | Port of the TCP storage server, which serves pieces to other peers. |
| seedClient.config.storage.writeBufferSize | int | `2097152` | Buffer size for writing pieces to disk. |
| seedClient.config.storage.writePieceTimeout | string | `"360s"` | Timeout for writing a piece to storage. |
| seedClient.config.storage.writebackMode | string | `"async"` | How written piece ranges are written back to disk. sync calls sync_file_range per piece, async queues the ranges to a background task, off leaves writeback to the kernel. |
| seedClient.config.tracing.protocol | string | `""` | Protocol used to export traces, one of http, https or grpc. Empty disables tracing. |
| seedClient.config.upload.bandwidthLimit | string | `"50GB"` | Upload bandwidth limit, in GB, MB or KB per second. |
| seedClient.config.upload.server.port | int | `4000` | Port of the upload gRPC server, which serves pieces to other peers. |
| seedClient.config.upload.server.requestRateLimit | int | `400` | Maximum requests per second on the upload gRPC server, across all connections. |
| seedClient.config.upload.server.requestbufferSize | int | `50` | Capacity of the request queue of the upload gRPC server. When it is full, new requests fail with RESOURCE_EXHAUSTED. |
| seedClient.dynconfig | object | `{"clientConfig":{},"scheduler":{"addr":"","addrs":[]},"seedClientConfig":{}}` | Local dynamic configuration (dynconfig.yaml), delivered as a ConfigMap next to dfdaemon.yaml. It is used only without a manager, that is when manager.enable is false and externalManager.host is empty, and refreshed every seedClient.config.dynconfig.refreshInterval. |
| seedClient.dynconfig.clientConfig | object | `{}` | Block list for normal peers, e.g. { blockList: { task: { download: { applications: [], urls: [], tags: [], priorities: [] } } } }. |
| seedClient.dynconfig.scheduler.addr | string | `""` | Scheduler headless Service address with port, resolved via DNS to every scheduler IP. Empty defaults to the scheduler Service of this chart. |
| seedClient.dynconfig.scheduler.addrs | list | `[]` | Static scheduler addresses with port, e.g. ['192.168.1.10:8002']. They take precedence over addr when set. |
| seedClient.dynconfig.seedClientConfig | object | `{}` | Block list for seed peers, with the same shape as clientConfig. |
| seedClient.enable | bool | `true` | Deploy the seed client, a dfdaemon StatefulSet that downloads from the source first and seeds the other peers. |
| seedClient.extraEnvVars | list | `[]` | Extra environment variables for the container. |
| seedClient.extraInitContainers | list | `[]` | Extra init containers for the seed client pod(s), evaluated as a template and rendered after the chart's built-in init containers. |
| seedClient.extraVolumeMounts | list | `[{"mountPath":"/var/log/dragonfly/dfdaemon/","name":"logs"}]` | Extra volume mounts for the dfdaemon container. |
| seedClient.extraVolumes | list | `[{"emptyDir":{},"name":"logs"}]` | Extra volumes for the seed client Pod. |
| seedClient.fullnameOverride | string | `""` | Override the seed client fully qualified name. |
| seedClient.hostAliases | list | `[]` | Pod hostAliases, extra entries for /etc/hosts. |
| seedClient.hostNetwork | bool | `false` | Use the host network namespace. |
| seedClient.image.digest | string | `""` | Image digest. |
| seedClient.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| seedClient.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| seedClient.image.registry | string | `"docker.io"` | Image registry. |
| seedClient.image.repository | string | `"dragonflyoss/client"` | Image repository. |
| seedClient.image.tag | string | `"v1.5.10"` | Image tag. |
| seedClient.initContainer.image.digest | string | `""` | Image digest. |
| seedClient.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| seedClient.initContainer.image.registry | string | `"docker.io"` | Image registry. |
| seedClient.initContainer.image.repository | string | `"busybox"` | Image repository. |
| seedClient.initContainer.image.tag | string | `"latest"` | Image tag. |
| seedClient.initContainer.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Container resource requests and limits. |
| seedClient.maxProcs | string | `""` | Value of the GOMAXPROCS environment variable, the maximum number of OS threads running Go code at once. Empty keeps the runtime default, refer to https://pkg.go.dev/runtime. |
| seedClient.metrics.enable | bool | `true` | Expose Prometheus metrics. |
| seedClient.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels, e.g. to match the Prometheus selector. |
| seedClient.metrics.prometheusRule.enable | bool | `false` | Create a Prometheus Operator PrometheusRule, refer to https://github.com/prometheus-operator/prometheus-operator. |
| seedClient.metrics.prometheusRule.rules | list | `[{"alert":"SeedClientDown","annotations":{"message":"Seed client instance {{ \"{{ $labels.instance }}\" }} is down","summary":"Seed client instance is down"},"expr":"sum(dragonfly_client_version{container=\"seed-client\"}) == 0","for":"5m","labels":{"severity":"critical"}},{"alert":"SeedClientHighNumberOfFailedDownloadTask","annotations":{"message":"Seed client has a high number of failed download task","summary":"Seed client has a high number of failed download task"},"expr":"sum(irate(dragonfly_client_download_task_failure_total{container=\"seed-client\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SeedClientSuccessRateOfDownloadingTask","annotations":{"message":"Seed client's success rate of downloading task is low","summary":"Seed client's success rate of downloading task is low"},"expr":"(sum(rate(dragonfly_client_download_task_total{container=\"seed-client\"}[1m])) - sum(rate(dragonfly_client_download_task_failure_total{container=\"seed-client\"}[1m]))) / sum(rate(dragonfly_client_download_task_total{container=\"seed-client\"}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}}]` | Prometheus alerting and recording rules. |
| seedClient.metrics.service.annotations | object | `{}` | Service annotations. |
| seedClient.metrics.service.clusterIP | string | `""` | Service cluster IP. |
| seedClient.metrics.service.labels | object | `{}` | Service labels. |
| seedClient.metrics.service.type | string | `"ClusterIP"` | Service type. |
| seedClient.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels, e.g. to match the Prometheus selector. |
| seedClient.metrics.serviceMonitor.enable | bool | `false` | Create a Prometheus Operator ServiceMonitor, refer to https://github.com/prometheus-operator/prometheus-operator. |
| seedClient.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped. |
| seedClient.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended. |
| seedClient.name | string | `"seed-client"` | Component name used in resource names and labels. |
| seedClient.nameOverride | string | `""` | Override the seed client name. |
| seedClient.nodeSelector | object | `{}` | Node labels for pod assignment. |
| seedClient.persistence.accessModes | list | `["ReadWriteOnce"]` | PersistentVolumeClaim access modes. |
| seedClient.persistence.annotations | object | `{}` | PersistentVolumeClaim annotations. |
| seedClient.persistence.enable | bool | `true` | Persist the storage directory on a volume instead of an emptyDir. |
| seedClient.persistence.hostPath | object | `{}` | Use a hostPath volume for the storage directory. When set, size, accessModes and storageClass are ignored. |
| seedClient.persistence.size | string | `"100Gi"` | PersistentVolumeClaim size. |
| seedClient.persistence.storageClass | string | `""` | StorageClass of the PersistentVolumeClaim. Empty uses the cluster default and "-" disables dynamic provisioning. global.storageClass takes precedence when set. |
| seedClient.podAnnotations | object | `{}` | Pod annotations. |
| seedClient.podLabels | object | `{}` | Pod labels. |
| seedClient.priorityClassName | string | `""` | Pod priority class name. |
| seedClient.replicas | int | `3` | Number of replicas. |
| seedClient.resources | object | `{"limits":{"cpu":"8","memory":"16Gi"},"requests":{"cpu":"8","memory":"16Gi"}}` | Container resource requests and limits. |
| seedClient.service.annotations | object | `{}` | Service annotations. |
| seedClient.service.clusterIP | string | `""` | Service cluster IP. |
| seedClient.service.labels | object | `{}` | Service labels. |
| seedClient.service.nodePort | string | `""` | Service node port. |
| seedClient.service.type | string | `"ClusterIP"` | Service type. |
| seedClient.statefulsetAnnotations | object | `{}` | StatefulSet annotations. |
| seedClient.sysctlInit.enable | bool | `false` | Enable a privileged init container that sets host sysctls, as the Elasticsearch and OpenSearch charts do. Network sysctls apply to the Pod network namespace unless hostNetwork is enabled, and privileged containers are rejected in PodSecurity restricted namespaces. |
| seedClient.sysctlInit.sysctls | object | `{"net.core.rmem_max":"16777216","net.core.wmem_max":"16777216"}` | Sysctls to set, sized for the QUIC socket buffers by default. |
| seedClient.terminationGracePeriodSeconds | string | `nil` | Seconds the Pod is given to terminate gracefully. |
| seedClient.tolerations | list | `[]` | List of node taints to tolerate. |
| seedClient.updateStrategy | object | `{}` | StatefulSet update strategy. |
| startupProbe.enable | bool | `false` | Enable startup probe. |
| startupProbe.failureThreshold | int | `60` | Failure threshold before the container is restarted. Total startup budget = periodSeconds * failureThreshold. |
| startupProbe.initialDelaySeconds | int | `0` | Initial delay before the first probe. |
| startupProbe.periodSeconds | int | `5` | Period (in seconds) between probe attempts. |
| startupProbe.successThreshold | int | `1` | Success threshold for startup probe. Must be 1 for startup probes. |
| startupProbe.timeoutSeconds | int | `3` | Probe timeout (in seconds). |

## Chart dependencies

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | mysql | 11.1.20 |
| https://charts.bitnami.com/bitnami | redis | 19.5.5 |
