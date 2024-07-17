# Dragonfly Helm Chart

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/dragonfly)](https://artifacthub.io/packages/search?repo=dragonfly)

Provide efficient, stable, secure, low-cost file and image distribution services to be the best practice and standard solution in the related Cloud-Native area.

## TL;DR

```shell
helm repo add dragonfly https://dragonflyoss.github.io/helm-charts/
helm install --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly
```

## Introduction

Dragonfly is an open source intelligent P2P based image and file distribution system. Its goal is to tackle all distribution problems in cloud native scenarios. Currently Dragonfly focuses on being:

- Simple: well-defined user-facing API (HTTP), non-invasive to all container engines;
- Efficient: Seed peer support, P2P based file distribution to save enterprise bandwidth;
- Intelligent: host level speed limit, intelligent flow control due to host detection;
- Secure: block transmission encryption, HTTPS connection support.

Dragonfly is now hosted by the Cloud Native Computing Foundation (CNCF) as an Incubating Level Project. Originally it was born to solve all kinds of distribution at very large scales, such as application distribution, cache distribution, log distribution, image distribution, and so on.

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

Create the `values.yaml` configuration file. Need to configure the cluster id associated with scheduler and seed peer. This example is to deploy a cluster using the existing manager and redis.

```yaml
scheduler:
  config:
    manager:
      schedulerClusterID: 1

seedClient:
  config:
    seedPeer:
      enable: true
      type: super
      clusterID: 1

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
| client.config.download.concurrentPieceCount | int | `16` | concurrentPieceCount is the number of concurrent pieces to download. |
| client.config.download.pieceTimeout | string | `"30s"` | pieceTimeout is the timeout for downloading a piece from source. |
| client.config.download.rateLimit | string | `"10GiB"` | rateLimit is the default rate limit of the download speed in GiB/Mib/Kib per second, default is 10GiB/s. |
| client.config.download.server.socketPath | string | `"/var/run/dragonfly/dfdaemon.sock"` | socketPath is the unix socket path for dfdaemon GRPC service. |
| client.config.dynconfig.refreshInterval | string | `"5m"` | refreshInterval is the interval to refresh dynamic configuration from manager. |
| client.config.gc.interval | string | `"900s"` | interval is the interval to do gc. |
| client.config.gc.policy.distHighThresholdPercent | int | `80` | distHighThresholdPercent is the high threshold percent of the disk usage. If the disk usage is greater than the threshold, dfdaemon will do gc. |
| client.config.gc.policy.distLowThresholdPercent | int | `60` | distLowThresholdPercent is the low threshold percent of the disk usage. If the disk usage is less than the threshold, dfdaemon will stop gc. |
| client.config.gc.policy.taskTTL | string | `"168h"` | taskTTL is the ttl of the task. |
| client.config.health.server.port | int | `4003` | port is the port to the health server. |
| client.config.host | object | `{"idc":"","location":""}` | host is the host configuration for dfdaemon. |
| client.config.log.level | string | `"info"` | Specify the logging level [trace, debug, info, warn, error] |
| client.config.manager.addrs | list | `[]` | addrs is manager addresses. |
| client.config.metrics.server.port | int | `4002` | port is the port to the metrics server. |
| client.config.proxy.disableBackToSource | bool | `false` | disableBackToSource indicates whether disable to download back-to-source when download failed. |
| client.config.proxy.prefetch | bool | `false` | prefetch pre-downloads full of the task when download with range request. |
| client.config.proxy.readBufferSize | int | `32768` | readBufferSize is the buffer size for reading piece from disk, default is 32KB. |
| client.config.proxy.registryMirror.addr | string | `"https://index.docker.io"` | addr is the default address of the registry mirror. Proxy will start a registry mirror service for the client to pull the image. The client can use the default address of the registry mirror in configuration to pull the image. The `X-Dragonfly-Registry` header can instead of the default address of registry mirror. |
| client.config.proxy.rules | list | `[{"regex":"blobs/sha256.*"}]` | rules is the list of rules for the proxy server. regex is the regex of the request url. useTLS indicates whether use tls for the proxy backend. redirect is the redirect url. filteredQueryParams is the filtered query params to generate the task id. When filter is ["Signature", "Expires", "ns"], for example: http://example.com/xyz?Expires=e1&Signature=s1&ns=docker.io and http://example.com/xyz?Expires=e2&Signature=s2&ns=docker.io will generate the same task id. Default value includes the filtered query params of s3, gcs, oss, obs, cos. |
| client.config.proxy.server.port | int | `4001` | port is the port to the proxy server. |
| client.config.scheduler.announceInterval | string | `"5m"` | announceInterval is the interval to announce peer to the scheduler. Announcer will provide the scheduler with peer information for scheduling, peer information includes cpu, memory, etc. |
| client.config.scheduler.enableBackToSource | bool | `true` | enableBackToSource indicates whether enable back-to-source download, when the scheduling failed. |
| client.config.scheduler.maxScheduleCount | int | `5` | maxScheduleCount is the max count of schedule. |
| client.config.scheduler.scheduleTimeout | string | `"30s"` | scheduleTimeout is the timeout for scheduling. If the scheduling timesout, dfdaemon will back-to-source download if enableBackToSource is true, otherwise dfdaemon will return download failed. |
| client.config.security.enable | bool | `false` | enable indicates whether enable security. |
| client.config.server.cacheDir | string | `"/var/cache/dragonfly/dfdaemon/"` | cacheDir is the directory to store cache files. |
| client.config.server.pluginDir | string | `"/var/lib/dragonfly/plugins/dfdaemon/"` | pluginDir is the directory to store plugins. |
| client.config.stats.server.port | int | `4004` | port is the port to the stats server. |
| client.config.storage.dir | string | `"/var/lib/dragonfly/"` | dir is the directory to store task's metadata and content. |
| client.config.storage.keep | bool | `false` | keep indicates whether keep the task's metadata and content when the dfdaemon restarts. |
| client.config.storage.readBufferSize | int | `131072` | readBufferSize is the buffer size for reading piece from disk, default is 128KB. |
| client.config.storage.writeBufferSize | int | `131072` | writeBufferSize is the buffer size for writing piece to disk, default is 128KB. |
| client.config.upload.rateLimit | string | `"10GiB"` | rateLimit is the default rate limit of the upload speed in GiB/Mib/Kib per second, default is 10GiB/s. |
| client.config.upload.server.port | int | `4000` | port is the port to the grpc server. |
| client.config.verbose | bool | `false` | verbose prints log. |
| client.dfinit.config.containerRuntime.containerd.configPath | string | `"/etc/containerd/config.toml"` | configPath is the path of containerd configuration file. |
| client.dfinit.config.containerRuntime.containerd.registries | list | `[{"capabilities":["pull","resolve"],"hostNamespace":"docker.io","serverAddr":"https://index.docker.io"},{"capabilities":["pull","resolve"],"hostNamespace":"ghcr.io","serverAddr":"https://ghcr.io"}]` | registries is the list of containerd registries. hostNamespace is the location where container images and artifacts are sourced, refer to https://github.com/containerd/containerd/blob/main/docs/hosts.md#registry-host-namespace. The registry host namespace portion is [registry_host_name|IP address][:port], such as docker.io, ghcr.io, gcr.io, etc. serverAddr specifies the default server for this registry host namespace, refer to https://github.com/containerd/containerd/blob/main/docs/hosts.md#server-field. capabilities is the list of capabilities in containerd configuration, refer to https://github.com/containerd/containerd/blob/main/docs/hosts.md#capabilities-field. |
| client.dfinit.config.log.level | string | `"info"` | Specify the logging level [trace, debug, info, warn, error] |
| client.dfinit.config.proxy.addr | string | `"http://127.0.0.1:4001"` | addr is the proxy server address of dfdaemon. |
| client.dfinit.config.verbose | bool | `true` | verbose prints log. |
| client.dfinit.enable | bool | `false` | Enable dfinit to override configuration of container runtime. |
| client.dfinit.image.digest | string | `""` | Image digest. |
| client.dfinit.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| client.dfinit.image.registry | string | `"docker.io"` | Image registry. |
| client.dfinit.image.repository | string | `"dragonflyoss/dfinit"` | Image repository. |
| client.dfinit.image.tag | string | `"v0.1.88"` | Image tag. |
| client.enable | bool | `true` | Enable client. |
| client.extraVolumeMounts | list | `[{"mountPath":"/var/lib/dragonfly/","name":"storage"},{"mountPath":"/var/log/dragonfly/dfdaemon/","name":"logs"}]` | Extra volumeMounts for dfdaemon. |
| client.extraVolumes | list | `[{"hostPath":{"path":"/var/lib/dragonfly/","type":"DirectoryOrCreate"},"name":"storage"},{"emptyDir":{},"name":"logs"}]` | Extra volumes for dfdaemon. |
| client.fullnameOverride | string | `""` | Override scheduler fullname. |
| client.hostAliases | list | `[]` | Host Aliases. |
| client.hostIPC | bool | `true` | hostIPC specify if host IPC should be enabled for peer pod. |
| client.hostNetwork | bool | `true` | hostNetwork specify if host network should be enabled for peer pod. |
| client.hostPID | bool | `true` | hostPID allows visibility of processes on the host for peer pod. |
| client.image.digest | string | `""` | Image digest. |
| client.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| client.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| client.image.registry | string | `"docker.io"` | Image registry. |
| client.image.repository | string | `"dragonflyoss/client"` | Image repository. |
| client.image.tag | string | `"v0.1.88"` | Image tag. |
| client.initContainer.image.digest | string | `""` | Image digest. |
| client.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| client.initContainer.image.registry | string | `"docker.io"` | Image registry. |
| client.initContainer.image.repository | string | `"busybox"` | Image repository. |
| client.initContainer.image.tag | string | `"latest"` | Image tag. |
| client.initContainer.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits. |
| client.maxProcs | string | `""` | maxProcs Limits the number of operating system threads that can execute user-level. Go code simultaneously by setting GOMAXPROCS environment variable, refer to https://golang.org/pkg/runtime. |
| client.metrics.enable | bool | `false` | Enable client metrics. |
| client.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels. |
| client.metrics.prometheusRule.enable | bool | `false` | Enable prometheus rule ref: https://github.com/coreos/prometheus-operator. |
| client.metrics.prometheusRule.rules | list | `[{"alert":"ClientDown","annotations":{"message":"Client instance {{ \"{{ $labels.instance }}\" }} is down","summary":"Client instance is down"},"expr":"sum(dragonfly_client_version{container=\"client\"}) == 0","for":"5m","labels":{"severity":"critical"}},{"alert":"ClientHighNumberOfFailedDownloadTask","annotations":{"message":"Client has a high number of failed download task","summary":"Client has a high number of failed download task"},"expr":"sum(irate(dragonfly_client_download_task_failure_total{container=\"client\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"ClientSuccessRateOfDownloadingTask","annotations":{"message":"Client's success rate of downloading task is low","summary":"Client's success rate of downloading task is low"},"expr":"(sum(rate(dragonfly_client_download_task_total{container=\"client\"}[1m])) - sum(rate(dragonfly_client_download_task_failure_total{container=\"client\"}[1m]))) / sum(rate(dragonfly_client_download_task_total{container=\"client\"}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}}]` | Prometheus rules. |
| client.metrics.service.annotations | object | `{}` | Service annotations. |
| client.metrics.service.labels | object | `{}` | Service labels. |
| client.metrics.service.type | string | `"ClusterIP"` | Service type. |
| client.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels |
| client.metrics.serviceMonitor.enable | bool | `false` | Enable prometheus service monitor. ref: https://github.com/coreos/prometheus-operator. |
| client.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped. |
| client.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended. |
| client.name | string | `"client"` | Client name. |
| client.nameOverride | string | `""` | Override scheduler name. |
| client.nodeSelector | object | `{}` | Node labels for pod assignment. |
| client.podAnnotations | object | `{}` | Pod annotations. |
| client.podLabels | object | `{}` | Pod labels. |
| client.priorityClassName | string | `""` | Pod priorityClassName. |
| client.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits. |
| client.statefulsetAnnotations | object | `{}` | Statefulset annotations. |
| client.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds. |
| client.tolerations | list | `[]` | List of node taints to tolerate. |
| client.updateStrategy | object | `{}` | Update strategy for replicas. |
| clusterDomain | string | `"cluster.local"` | Install application cluster domain. |
| externalManager.grpcPort | int | `65003` | External GRPC service port. |
| externalManager.host | string | `nil` | External manager hostname. |
| externalManager.restPort | int | `8080` | External REST service port. |
| externalMysql.database | string | `"manager"` | External mysql database name. |
| externalMysql.host | string | `nil` | External mysql hostname. |
| externalMysql.migrate | bool | `true` | Running GORM migration. |
| externalMysql.password | string | `"dragonfly"` | External mysql password. |
| externalMysql.port | int | `3306` | External mysql port. |
| externalMysql.username | string | `"dragonfly"` | External mysql username. |
| externalRedis.addrs | list | `["redis.example.com:6379"]` | External redis server addresses. |
| externalRedis.backendDB | int | `2` | External redis backend db. |
| externalRedis.brokerDB | int | `1` | External redis broker db. |
| externalRedis.db | int | `0` | External redis db. |
| externalRedis.masterName | string | `""` | External redis sentinel master name. |
| externalRedis.networkTopologyDB | int | `3` | External redis networkTopology db. |
| externalRedis.password | string | `""` | External redis password. |
| externalRedis.username | string | `""` | External redis username. |
| fullnameOverride | string | `""` | Override dragonfly fullname. |
| global.imagePullSecrets | list | `[]` | Global Docker registry secret names as an array. |
| global.imageRegistry | string | `""` | Global Docker image registry. |
| global.nodeSelector | object | `{}` | Global node labels for pod assignment. |
| global.storageClass | string | `""` | Global storageClass for Persistent Volume(s). |
| manager.config.auth.jwt.key | string | `"ZHJhZ29uZmx5Cg=="` | Key is secret key used for signing, default value is encoded base64 of dragonfly. Please change the key in production. |
| manager.config.auth.jwt.maxRefresh | string | `"48h"` | MaxRefresh field allows clients to refresh their token until MaxRefresh has passed, default duration is two days. |
| manager.config.auth.jwt.realm | string | `"Dragonfly"` | Realm name to display to the user, default value is Dragonfly. |
| manager.config.auth.jwt.timeout | string | `"48h"` | Timeout is duration that a jwt token is valid, default duration is two days. |
| manager.config.cache.local.size | int | `200000` | Size of LFU cache. |
| manager.config.cache.local.ttl | string | `"3m"` | Local cache TTL duration. |
| manager.config.cache.redis.ttl | string | `"5m"` | Redis cache TTL duration. |
| manager.config.console | bool | `false` | Console shows log on console. |
| manager.config.jaeger | string | `""` |  |
| manager.config.job.preheat | object | `{"registryTimeout":"1m"}` | Preheat configuration. |
| manager.config.job.preheat.registryTimeout | string | `"1m"` | registryTimeout is the timeout for requesting registry to get token and manifest. |
| manager.config.job.syncPeers | object | `{"interval":"24h","timeout":"10m"}` | Sync peers configuration. |
| manager.config.job.syncPeers.interval | string | `"24h"` | interval is the interval for syncing all peers information from the scheduler and display peers information in the manager console. |
| manager.config.job.syncPeers.timeout | string | `"10m"` | timeout is the timeout for syncing peers information from the single scheduler. |
| manager.config.network.enableIPv6 | bool | `false` | enableIPv6 enables ipv6. |
| manager.config.objectStorage.accessKey | string | `""` | AccessKey is access key ID. |
| manager.config.objectStorage.enable | bool | `false` | Enable object storage. |
| manager.config.objectStorage.endpoint | string | `""` | Endpoint is datacenter endpoint. |
| manager.config.objectStorage.name | string | `"s3"` | Name is object storage name of type, it can be s3 or oss. |
| manager.config.objectStorage.region | string | `""` | Reigon is storage region. |
| manager.config.objectStorage.s3ForcePathStyle | bool | `true` | S3ForcePathStyle sets force path style for s3, true by default. Set this to `true` to force the request to use path-style addressing, i.e., `http://s3.amazonaws.com/BUCKET/KEY`. By default, the S3 client will use virtual hosted bucket addressing when possible (`http://BUCKET.s3.amazonaws.com/KEY`). Refer to https://github.com/aws/aws-sdk-go/blob/main/aws/config.go#L118. |
| manager.config.objectStorage.secretKey | string | `""` | SecretKey is access key secret. |
| manager.config.pprofPort | int | `-1` | Listen port for pprof, only valid when the verbose option is true default is -1. If it is 0, pprof will use a random port. |
| manager.config.security.autoIssueCert | bool | `false` | AutoIssueCert indicates to issue client certificates for all grpc call. If AutoIssueCert is false, any other option in Security will be ignored. |
| manager.config.security.caCert | string | `""` | CACert is the CA certificate for all grpc tls handshake, it can be path or PEM format string. |
| manager.config.security.caKey | string | `""` | CAKey is the CA private key, it can be path or PEM format string. |
| manager.config.security.certSpec.dnsNames | list | `["dragonfly-manager","dragonfly-manager.dragonfly-system.svc","dragonfly-manager.dragonfly-system.svc.cluster.local"]` | DNSNames is a list of dns names be set on the certificate. |
| manager.config.security.certSpec.ipAddresses | string | `nil` | IPAddresses is a list of ip addresses be set on the certificate. |
| manager.config.security.certSpec.validityPeriod | string | `"87600h"` | ValidityPeriod is the validity period  of certificate. |
| manager.config.security.tlsPolicy | string | `"prefer"` | TLSPolicy controls the grpc shandshake behaviors:   force: both ClientHandshake and ServerHandshake are only support tls.   prefer: ServerHandshake supports tls and insecure (non-tls), ClientHandshake will only support tls.   default: ServerHandshake supports tls and insecure (non-tls), ClientHandshake will only support insecure (non-tls). Notice: If the drgaonfly service has been deployed, a two-step upgrade is required. The first step is to set tlsPolicy to default, and then upgrade the dragonfly services. The second step is to set tlsPolicy to prefer, and tthen completely upgrade the dragonfly services. |
| manager.config.server.cacheDir | string | `""` | Dynconfig cache directory. |
| manager.config.server.grpc.advertiseIP | string | `""` | GRPC advertise ip. |
| manager.config.server.logDir | string | `""` | Log directory. |
| manager.config.server.pluginDir | string | `""` | Plugin directory. |
| manager.config.server.rest.tls.cert | string | `""` | Certificate file path. |
| manager.config.server.rest.tls.key | string | `""` | Key file path. |
| manager.config.server.workHome | string | `""` | Work directory. |
| manager.config.verbose | bool | `false` | Whether to enable debug level logger and enable pprof. |
| manager.deploymentAnnotations | object | `{}` | Deployment annotations. |
| manager.enable | bool | `true` | Enable manager. |
| manager.extraVolumeMounts | list | `[{"mountPath":"/var/log/dragonfly/manager","name":"logs"}]` | Extra volumeMounts for manager. |
| manager.extraVolumes | list | `[{"emptyDir":{},"name":"logs"}]` | Extra volumes for manager. |
| manager.fullnameOverride | string | `""` | Override manager fullname. |
| manager.grpcPort | int | `65003` | GRPC service port. |
| manager.hostAliases | list | `[]` | Host Aliases. |
| manager.image.digest | string | `""` | Image digest. |
| manager.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| manager.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| manager.image.registry | string | `"docker.io"` | Image registry. |
| manager.image.repository | string | `"dragonflyoss/manager"` | Image repository. |
| manager.image.tag | string | `"v2.1.51"` | Image tag. |
| manager.ingress.annotations | object | `{}` | Ingress annotations. |
| manager.ingress.className | string | `""` | Ingress class name. Requirement: kubernetes >=1.18. |
| manager.ingress.enable | bool | `false` | Enable ingress. |
| manager.ingress.hosts | list | `[]` | Manager ingress hosts. |
| manager.ingress.path | string | `"/"` | Ingress host path. |
| manager.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type. Requirement: kubernetes >=1.18. |
| manager.ingress.tls | list | `[]` | Ingress TLS configuration. |
| manager.initContainer.image.digest | string | `""` | Image digest. |
| manager.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| manager.initContainer.image.registry | string | `"docker.io"` | Image registry. |
| manager.initContainer.image.repository | string | `"busybox"` | Image repository. |
| manager.initContainer.image.tag | string | `"latest"` | Image tag. |
| manager.initContainer.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits. |
| manager.maxProcs | string | `""` | maxProcs Limits the number of operating system threads that can execute user-level. Go code simultaneously by setting GOMAXPROCS environment variable, refer to https://golang.org/pkg/runtime. |
| manager.metrics.enable | bool | `false` | Enable manager metrics. |
| manager.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels. |
| manager.metrics.prometheusRule.enable | bool | `false` | Enable prometheus rule. ref: https://github.com/coreos/prometheus-operator. |
| manager.metrics.prometheusRule.rules | list | `[{"alert":"ManagerDown","annotations":{"message":"Manager instance {{ \"{{ $labels.instance }}\" }} is down","summary":"Manager instance is down"},"expr":"sum(dragonfly_manager_version{}) == 0","for":"5m","labels":{"severity":"critical"}},{"alert":"ManagerHighNumberOfFailedGRPCRequest","annotations":{"message":"Manager has a high number of failed grpc request","summary":"Manager has a high number of failed grpc request"},"expr":"sum(rate(grpc_server_started_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\"}[1m])) - sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"OK\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"NotFound\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"PermissionDenied\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"InvalidArgument\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"ManagerSuccessRateOfGRPCRequest","annotations":{"message":"Manager's success rate of grpc request is low","summary":"Manager's success rate of grpc request is low"},"expr":"(sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"OK\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"NotFound\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"PermissionDenied\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"InvalidArgument\"}[1m]))) / sum(rate(grpc_server_started_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\"}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"ManagerHighNumberOfFailedRESTRequest","annotations":{"message":"Manager has a high number of failed rest request","summary":"Manager has a high number of failed rest request"},"expr":"sum(rate(dragonfly_manager_requests_total{}[1m])) - sum(rate(dragonfly_manager_requests_total{code=~\"[12]..\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"ManagerSuccessRateOfRESTRequest","annotations":{"message":"Manager's success rate of rest request is low","summary":"Manager's success rate of rest request is low"},"expr":"sum(rate(dragonfly_manager_requests_total{code=~\"[12]..\"}[1m])) / sum(rate(dragonfly_manager_requests_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}}]` | Prometheus rules. |
| manager.metrics.service.annotations | object | `{}` | Service annotations. |
| manager.metrics.service.labels | object | `{}` | Service labels. |
| manager.metrics.service.type | string | `"ClusterIP"` | Service type. |
| manager.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels. |
| manager.metrics.serviceMonitor.enable | bool | `false` | Enable prometheus service monitor. ref: https://github.com/coreos/prometheus-operator. |
| manager.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped. |
| manager.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended. |
| manager.name | string | `"manager"` | Manager name. |
| manager.nameOverride | string | `""` | Override manager name. |
| manager.nodeSelector | object | `{}` | Node labels for pod assignment. |
| manager.podAnnotations | object | `{}` | Pod annotations. |
| manager.podLabels | object | `{}` | Pod labels. |
| manager.priorityClassName | string | `""` | Pod priorityClassName. |
| manager.replicas | int | `3` | Number of Pods to launch. |
| manager.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits. |
| manager.restPort | int | `8080` | REST service port. |
| manager.service.annotations | object | `{}` | Service annotations. |
| manager.service.labels | object | `{}` | Service labels. |
| manager.service.type | string | `"ClusterIP"` | Service type. |
| manager.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds. |
| manager.tolerations | list | `[]` | List of node taints to tolerate. |
| manager.updateStrategy | object | `{"type":"RollingUpdate"}` | Update strategy for replicas. |
| mysql.auth.database | string | `"manager"` | Mysql database name. |
| mysql.auth.host | string | `""` | Mysql hostname. |
| mysql.auth.password | string | `"dragonfly"` | Mysql password. |
| mysql.auth.rootPassword | string | `"dragonfly-root"` | Mysql root password. |
| mysql.auth.username | string | `"dragonfly"` | Mysql username. |
| mysql.clusterDomain | string | `"cluster.local"` | Cluster domain. |
| mysql.enable | bool | `true` | Enable mysql with docker container. |
| mysql.migrate | bool | `true` | Running GORM migration. |
| mysql.primary.service.port | int | `3306` | Mysql port. |
| nameOverride | string | `""` | Override dragonfly name. |
| namespaceOverride | string | `""` | Override dragonfly namespace. |
| redis.auth.enabled | bool | `true` | Enable password authentication. |
| redis.auth.password | string | `"dragonfly"` | Redis password. |
| redis.clusterDomain | string | `"cluster.local"` | Cluster domain. |
| redis.enable | bool | `true` | Enable redis cluster with docker container. |
| redis.master.service.ports.redis | int | `6379` | Redis master service port. |
| scheduler.config.console | bool | `false` | Console shows log on console. |
| scheduler.config.dynconfig.refreshInterval | string | `"1m"` | Dynamic config refresh interval. |
| scheduler.config.dynconfig.type | string | `"manager"` | Type is deprecated and is no longer used. Please remove it from your configuration. |
| scheduler.config.host.idc | string | `""` | IDC is the idc of scheduler instance. |
| scheduler.config.host.location | string | `""` | Location is the location of scheduler instance. |
| scheduler.config.jaeger | string | `""` |  |
| scheduler.config.manager.keepAlive.interval | string | `"5s"` | Manager keepalive interval. |
| scheduler.config.manager.schedulerClusterID | int | `1` | Associated scheduler cluster id. |
| scheduler.config.network.enableIPv6 | bool | `false` | enableIPv6 enables ipv6. |
| scheduler.config.pprofPort | int | `-1` | Listen port for pprof, only valid when the verbose option is true. default is -1. If it is 0, pprof will use a random port. |
| scheduler.config.resource | object | `{"task":{"downloadTiny":{"scheme":"http","timeout":"1m","tls":{"insecureSkipVerify":true}}}}` | resource configuration. |
| scheduler.config.resource.task | object | `{"downloadTiny":{"scheme":"http","timeout":"1m","tls":{"insecureSkipVerify":true}}}` | task configuration. |
| scheduler.config.resource.task.downloadTiny | object | `{"scheme":"http","timeout":"1m","tls":{"insecureSkipVerify":true}}` | downloadTiny is the configuration of downloading tiny task by scheduler. |
| scheduler.config.resource.task.downloadTiny.scheme | string | `"http"` | scheme is download tiny task scheme. |
| scheduler.config.resource.task.downloadTiny.timeout | string | `"1m"` | timeout is http request timeout. |
| scheduler.config.resource.task.downloadTiny.tls | object | `{"insecureSkipVerify":true}` | tls is download tiny task TLS configuration. |
| scheduler.config.resource.task.downloadTiny.tls.insecureSkipVerify | bool | `true` | insecureSkipVerify controls whether a client verifies the server's certificate chain and hostname. |
| scheduler.config.scheduler.algorithm | string | `"default"` | Algorithm configuration to use different scheduling algorithms, default configuration supports "default", "ml" and "nt". "default" is the rule-based scheduling algorithm, "ml" is the machine learning scheduling algorithm, "nt" is the rule-based and networkTopology-based scheduling algorithm. It also supports user plugin extension, the algorithm value is "plugin", and the compiled `d7y-scheduler-plugin-evaluator.so` file is added to the dragonfly working directory plugins. |
| scheduler.config.scheduler.backToSourceCount | int | `200` | backToSourceCount is single task allows the peer to back-to-source count. |
| scheduler.config.scheduler.gc.hostGCInterval | string | `"6h"` | hostGCInterval is the interval of host gc. |
| scheduler.config.scheduler.gc.hostTTL | string | `"1h"` | hostTTL is time to live of host. If host announces message to scheduler, then HostTTl will be reset. |
| scheduler.config.scheduler.gc.peerGCInterval | string | `"10s"` | peerGCInterval is the interval of peer gc. |
| scheduler.config.scheduler.gc.peerTTL | string | `"24h"` | peerTTL is the ttl of peer. If the peer has been downloaded by other peers, then PeerTTL will be reset. |
| scheduler.config.scheduler.gc.pieceDownloadTimeout | string | `"30m"` | pieceDownloadTimeout is the timeout of downloading piece. |
| scheduler.config.scheduler.gc.taskGCInterval | string | `"30m"` | taskGCInterval is the interval of task gc. If all the peers have been reclaimed in the task, then the task will also be reclaimed. |
| scheduler.config.scheduler.networkTopology.cache.interval | string | `"5m"` | interval is cache cleanup interval. |
| scheduler.config.scheduler.networkTopology.cache.ttl | string | `"5m"` | ttl is networkTopology cache items ttl. |
| scheduler.config.scheduler.networkTopology.collectInterval | string | `"2h"` | collectInterval is the interval of collecting network topology. |
| scheduler.config.scheduler.networkTopology.probe.count | int | `10` | count is the number of probing hosts. |
| scheduler.config.scheduler.networkTopology.probe.queueLength | int | `5` | queueLength is the length of probe queue. |
| scheduler.config.scheduler.retryBackToSourceLimit | int | `5` | retryBackToSourceLimit reaches the limit, then the peer back-to-source. |
| scheduler.config.scheduler.retryInterval | string | `"700ms"` | Retry scheduling interval. |
| scheduler.config.scheduler.retryLimit | int | `7` | Retry scheduling limit times. |
| scheduler.config.security.autoIssueCert | bool | `false` | AutoIssueCert indicates to issue client certificates for all grpc call. If AutoIssueCert is false, any other option in Security will be ignored. |
| scheduler.config.security.caCert | string | `""` | CACert is the root CA certificate for all grpc tls handshake, it can be path or PEM format string. |
| scheduler.config.security.certSpec.dnsNames | list | `["dragonfly-scheduler","dragonfly-scheduler.dragonfly-system.svc","dragonfly-scheduler.dragonfly-system.svc.cluster.local"]` | DNSNames is a list of dns names be set on the certificate. |
| scheduler.config.security.certSpec.ipAddresses | string | `nil` | IPAddresses is a list of ip addresses be set on the certificate. |
| scheduler.config.security.certSpec.validityPeriod | string | `"4320h"` | ValidityPeriod is the validity period  of certificate. |
| scheduler.config.security.tlsPolicy | string | `"prefer"` | TLSPolicy controls the grpc shandshake behaviors:   force: both ClientHandshake and ServerHandshake are only support tls.   prefer: ServerHandshake supports tls and insecure (non-tls), ClientHandshake will only support tls.   default: ServerHandshake supports tls and insecure (non-tls), ClientHandshake will only support insecure (non-tls). Notice: If the drgaonfly service has been deployed, a two-step upgrade is required. The first step is to set tlsPolicy to default, and then upgrade the dragonfly services. The second step is to set tlsPolicy to prefer, and tthen completely upgrade the dragonfly services. |
| scheduler.config.security.tlsVerify | bool | `false` | TLSVerify indicates to verify certificates. |
| scheduler.config.seedPeer.enable | bool | `true` | scheduler enable seed peer as P2P peer, if the value is false, P2P network will not be back-to-source through seed peer but by dfdaemon and preheat feature does not work. |
| scheduler.config.server.advertiseIP | string | `""` | Advertise ip. |
| scheduler.config.server.advertisePort | int | `8002` | Advertise port. |
| scheduler.config.server.cacheDir | string | `""` | Dynconfig cache directory. |
| scheduler.config.server.dataDir | string | `""` | Storage directory. |
| scheduler.config.server.listenIP | string | `"0.0.0.0"` | Listen ip. |
| scheduler.config.server.logDir | string | `""` | Log directory. |
| scheduler.config.server.pluginDir | string | `""` | Plugin directory. |
| scheduler.config.server.port | int | `8002` | Server port. |
| scheduler.config.server.workHome | string | `""` | Work directory. |
| scheduler.config.storage.bufferSize | int | `100` | bufferSize sets the size of buffer container, if the buffer is full, write all the records in the buffer to the file. |
| scheduler.config.storage.maxBackups | int | `10` | maxBackups sets the maximum number of storage files to retain. |
| scheduler.config.storage.maxSize | int | `100` | maxSize sets the maximum size in megabytes of storage file. |
| scheduler.config.verbose | bool | `false` | Whether to enable debug level logger and enable pprof. |
| scheduler.containerPort | int | `8002` | Pod containerPort. |
| scheduler.enable | bool | `true` | Enable scheduler. |
| scheduler.extraVolumeMounts | list | `[{"mountPath":"/var/log/dragonfly/scheduler","name":"logs"}]` | Extra volumeMounts for scheduler. |
| scheduler.extraVolumes | list | `[{"emptyDir":{},"name":"logs"}]` | Extra volumes for scheduler. |
| scheduler.fullnameOverride | string | `""` | Override scheduler fullname. |
| scheduler.hostAliases | list | `[]` | Host Aliases. |
| scheduler.image.digest | string | `""` | Image digest. |
| scheduler.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| scheduler.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| scheduler.image.registry | string | `"docker.io"` | Image registry. |
| scheduler.image.repository | string | `"dragonflyoss/scheduler"` | Image repository. |
| scheduler.image.tag | string | `"v2.1.51"` | Image tag. |
| scheduler.initContainer.image.digest | string | `""` | Image digest. |
| scheduler.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| scheduler.initContainer.image.registry | string | `"docker.io"` | Image registry. |
| scheduler.initContainer.image.repository | string | `"busybox"` | Image repository. |
| scheduler.initContainer.image.tag | string | `"latest"` | Image tag. |
| scheduler.initContainer.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits. |
| scheduler.maxProcs | string | `""` | maxProcs Limits the number of operating system threads that can execute user-level. Go code simultaneously by setting GOMAXPROCS environment variable, refer to https://golang.org/pkg/runtime. |
| scheduler.metrics.enable | bool | `false` | Enable scheduler metrics. |
| scheduler.metrics.enableHost | bool | `false` | Enable host metrics. |
| scheduler.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels. |
| scheduler.metrics.prometheusRule.enable | bool | `false` | Enable prometheus rule ref: https://github.com/coreos/prometheus-operator. |
| scheduler.metrics.prometheusRule.rules | list | `[{"alert":"SchedulerDown","annotations":{"message":"Scheduler instance {{ \"{{ $labels.instance }}\" }} is down","summary":"Scheduler instance is down"},"expr":"sum(dragonfly_scheduler_version{}) == 0","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedDownloadPeer","annotations":{"message":"Scheduler has a high number of failed download peer","summary":"Scheduler has a high number of failed download peer"},"expr":"sum(irate(dragonfly_scheduler_download_peer_finished_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfDownloadingPeer","annotations":{"message":"Scheduler's success rate of downloading peer is low","summary":"Scheduler's success rate of downloading peer is low"},"expr":"(sum(rate(dragonfly_scheduler_download_peer_finished_total{}[1m])) - sum(rate(dragonfly_scheduler_download_peer_finished_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_download_peer_finished_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedRegisterPeer","annotations":{"message":"Scheduler has a high number of failed register peer","summary":"Scheduler has a high number of failed register peer"},"expr":"sum(irate(dragonfly_scheduler_register_peer_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfRegisterTask","annotations":{"message":"Scheduler's success rate of register peer is low","summary":"Scheduler's success rate of register peer is low"},"expr":"(sum(rate(dragonfly_scheduler_register_peer_total{}[1m])) - sum(rate(dragonfly_scheduler_register_peer_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_register_peer_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedLeavePeer","annotations":{"message":"Scheduler has a high number of failed leave peer","summary":"Scheduler has a high number of failed leave peer"},"expr":"sum(irate(dragonfly_scheduler_leave_peer_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfLeavingPeer","annotations":{"message":"Scheduler's success rate of leaving peer is low","summary":"Scheduler's success rate of leaving peer is low"},"expr":"(sum(rate(dragonfly_scheduler_leave_peer_total{}[1m])) - sum(rate(dragonfly_scheduler_leave_peer_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_leave_peer_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedStatTask","annotations":{"message":"Scheduler has a high number of failed stat task","summary":"Scheduler has a high number of failed stat task"},"expr":"sum(irate(dragonfly_scheduler_stat_task_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfStatTask","annotations":{"message":"Scheduler's success rate of stat task is low","summary":"Scheduler's success rate of stat task is low"},"expr":"(sum(rate(dragonfly_scheduler_stat_task_total{}[1m])) - sum(rate(dragonfly_scheduler_stat_task_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_stat_task_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedAnnouncePeer","annotations":{"message":"Scheduler has a high number of failed announce peer","summary":"Scheduler has a high number of failed announce peer"},"expr":"sum(irate(dragonfly_scheduler_announce_peer_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfAnnouncingPeer","annotations":{"message":"Scheduler's success rate of announcing peer is low","summary":"Scheduler's success rate of announcing peer is low"},"expr":"(sum(rate(dragonfly_scheduler_announce_peer_total{}[1m])) - sum(rate(dragonfly_scheduler_announce_peer_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_announce_peer_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedLeaveHost","annotations":{"message":"Scheduler has a high number of failed leave host","summary":"Scheduler has a high number of failed leave host"},"expr":"sum(irate(dragonfly_scheduler_leave_host_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfLeavingHost","annotations":{"message":"Scheduler's success rate of leaving host is low","summary":"Scheduler's success rate of leaving host is low"},"expr":"(sum(rate(dragonfly_scheduler_leave_host_total{}[1m])) - sum(rate(dragonfly_scheduler_leave_host_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_leave_host_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedAnnounceHost","annotations":{"message":"Scheduler has a high number of failed annoucne host","summary":"Scheduler has a high number of failed annoucne host"},"expr":"sum(irate(dragonfly_scheduler_announce_host_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfAnnouncingHost","annotations":{"message":"Scheduler's success rate of announcing host is low","summary":"Scheduler's success rate of announcing host is low"},"expr":"(sum(rate(dragonfly_scheduler_announce_host_total{}[1m])) - sum(rate(dragonfly_scheduler_announce_host_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_announce_host_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedGRPCRequest","annotations":{"message":"Scheduler has a high number of failed grpc request","summary":"Scheduler has a high number of failed grpc request"},"expr":"sum(rate(grpc_server_started_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\"}[1m])) - sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"OK\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"NotFound\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"PermissionDenied\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"InvalidArgument\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfGRPCRequest","annotations":{"message":"Scheduler's success rate of grpc request is low","summary":"Scheduler's success rate of grpc request is low"},"expr":"(sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"OK\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"NotFound\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"PermissionDenied\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"InvalidArgument\"}[1m]))) / sum(rate(grpc_server_started_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\"}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}}]` | Prometheus rules. |
| scheduler.metrics.service.annotations | object | `{}` | Service annotations. |
| scheduler.metrics.service.labels | object | `{}` | Service labels. |
| scheduler.metrics.service.type | string | `"ClusterIP"` | Service type. |
| scheduler.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels. |
| scheduler.metrics.serviceMonitor.enable | bool | `false` | Enable prometheus service monitor. ref: https://github.com/coreos/prometheus-operator. |
| scheduler.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped. |
| scheduler.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended. |
| scheduler.name | string | `"scheduler"` | Scheduler name. |
| scheduler.nameOverride | string | `""` | Override scheduler name. |
| scheduler.nodeSelector | object | `{}` | Node labels for pod assignment. |
| scheduler.podAnnotations | object | `{}` | Pod annotations. |
| scheduler.podLabels | object | `{}` | Pod labels. |
| scheduler.priorityClassName | string | `""` | Pod priorityClassName. |
| scheduler.replicas | int | `3` | Number of Pods to launch. |
| scheduler.resources | object | `{"limits":{"cpu":"4","memory":"8Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits. |
| scheduler.service.annotations | object | `{}` | Service annotations. |
| scheduler.service.labels | object | `{}` | Service labels. |
| scheduler.service.type | string | `"ClusterIP"` | Service type. |
| scheduler.statefulsetAnnotations | object | `{}` | Statefulset annotations. |
| scheduler.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds. |
| scheduler.tolerations | list | `[]` | List of node taints to tolerate. |
| scheduler.updateStrategy | object | `{}` | Update strategy for replicas. |
| seedClient.config.download.concurrentPieceCount | int | `16` | concurrentPieceCount is the number of concurrent pieces to download. |
| seedClient.config.download.pieceTimeout | string | `"30s"` | pieceTimeout is the timeout for downloading a piece from source. |
| seedClient.config.download.rateLimit | string | `"50GiB"` | rateLimit is the default rate limit of the download speed in GiB/Mib/Kib per second, default is 50GiB/s. |
| seedClient.config.download.server.socketPath | string | `"/var/run/dragonfly/dfdaemon.sock"` | socketPath is the unix socket path for dfdaemon GRPC service. |
| seedClient.config.dynconfig.refreshInterval | string | `"1m"` | refreshInterval is the interval to refresh dynamic configuration from manager. |
| seedClient.config.gc.interval | string | `"900s"` | interval is the interval to do gc. |
| seedClient.config.gc.policy.distHighThresholdPercent | int | `80` | distHighThresholdPercent is the high threshold percent of the disk usage. If the disk usage is greater than the threshold, dfdaemon will do gc. |
| seedClient.config.gc.policy.distLowThresholdPercent | int | `60` | distLowThresholdPercent is the low threshold percent of the disk usage. If the disk usage is less than the threshold, dfdaemon will stop gc. |
| seedClient.config.gc.policy.taskTTL | string | `"168h"` | taskTTL is the ttl of the task. |
| seedClient.config.health.server.port | int | `4003` | port is the port to the health server. |
| seedClient.config.host | object | `{"idc":"","location":""}` | host is the host configuration for dfdaemon. |
| seedClient.config.log.level | string | `"info"` | Specify the logging level [trace, debug, info, warn, error] |
| seedClient.config.manager.addrs | list | `[]` | addrs is manager addresses. |
| seedClient.config.metrics.server.port | int | `4002` | port is the port to the metrics server. |
| seedClient.config.proxy.disableBackToSource | bool | `false` | disableBackToSource indicates whether disable to download back-to-source when download failed. |
| seedClient.config.proxy.prefetch | bool | `false` | prefetch pre-downloads full of the task when download with range request. |
| seedClient.config.proxy.readBufferSize | int | `32768` | readBufferSize is the buffer size for reading piece from disk, default is 32KB. |
| seedClient.config.proxy.registryMirror.addr | string | `"https://index.docker.io"` | addr is the default address of the registry mirror. Proxy will start a registry mirror service for the client to pull the image. The client can use the default address of the registry mirror in configuration to pull the image. The `X-Dragonfly-Registry` header can instead of the default address of registry mirror. |
| seedClient.config.proxy.rules | list | `[{"regex":"blobs/sha256.*"}]` | rules is the list of rules for the proxy server. regex is the regex of the request url. useTLS indicates whether use tls for the proxy backend. redirect is the redirect url. filteredQueryParams is the filtered query params to generate the task id. When filter is ["Signature", "Expires", "ns"], for example: http://example.com/xyz?Expires=e1&Signature=s1&ns=docker.io and http://example.com/xyz?Expires=e2&Signature=s2&ns=docker.io will generate the same task id. Default value includes the filtered query params of s3, gcs, oss, obs, cos. |
| seedClient.config.proxy.server.port | int | `4001` | port is the port to the proxy server. |
| seedClient.config.scheduler.announceInterval | string | `"1m"` | announceInterval is the interval to announce peer to the scheduler. Announcer will provide the scheduler with peer information for scheduling, peer information includes cpu, memory, etc. |
| seedClient.config.scheduler.maxScheduleCount | int | `5` | maxScheduleCount is the max count of schedule. |
| seedClient.config.scheduler.scheduleTimeout | string | `"30s"` | scheduleTimeout is the timeout for scheduling. If the scheduling timesout, dfdaemon will back-to-source download if enableBackToSource is true, otherwise dfdaemon will return download failed. |
| seedClient.config.security.enable | bool | `false` | enable indicates whether enable security. |
| seedClient.config.seedPeer.clusterID | int | `1` | clusterID is the cluster id of the seed peer cluster. |
| seedClient.config.seedPeer.enable | bool | `true` | enable indicates whether enable seed peer. |
| seedClient.config.seedPeer.keepaliveInterval | string | `"15s"` | keepaliveInterval is the interval to keep alive with manager. |
| seedClient.config.seedPeer.type | string | `"super"` | type is the type of seed peer. |
| seedClient.config.server.cacheDir | string | `"/var/cache/dragonfly/dfdaemon/"` | cacheDir is the directory to store cache files. |
| seedClient.config.server.pluginDir | string | `"/var/lib/dragonfly/plugins/dfdaemon/"` | pluginDir is the directory to store plugins. |
| seedClient.config.stats.server.port | int | `4004` | port is the port to the stats server. |
| seedClient.config.storage.dir | string | `"/var/lib/dragonfly/"` | dir is the directory to store task's metadata and content. |
| seedClient.config.storage.keep | bool | `false` | keep indicates whether keep the task's metadata and content when the dfdaemon restarts. |
| seedClient.config.storage.readBufferSize | int | `131072` | readBufferSize is the buffer size for reading piece from disk, default is 128KB. |
| seedClient.config.storage.writeBufferSize | int | `131072` | writeBufferSize is the buffer size for writing piece to disk, default is 128KB. |
| seedClient.config.upload.rateLimit | string | `"50GiB"` | rateLimit is the default rate limit of the upload speed in GiB/Mib/Kib per second, default is 50GiB/s. |
| seedClient.config.upload.server.port | int | `4000` | port is the port to the grpc server. |
| seedClient.config.verbose | bool | `false` | verbose prints log. |
| seedClient.enable | bool | `true` | Enable seed client. |
| seedClient.extraVolumeMounts | list | `[{"mountPath":"/var/log/dragonfly/dfdaemon/","name":"logs"}]` | Extra volumeMounts for dfdaemon. |
| seedClient.extraVolumes | list | `[{"emptyDir":{},"name":"logs"}]` | Extra volumes for dfdaemon. |
| seedClient.fullnameOverride | string | `""` | Override scheduler fullname. |
| seedClient.hostAliases | list | `[]` | Host Aliases. |
| seedClient.image.digest | string | `""` | Image digest. |
| seedClient.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| seedClient.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| seedClient.image.registry | string | `"docker.io"` | Image registry. |
| seedClient.image.repository | string | `"dragonflyoss/client"` | Image repository. |
| seedClient.image.tag | string | `"v0.1.88"` | Image tag. |
| seedClient.initContainer.image.digest | string | `""` | Image digest. |
| seedClient.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| seedClient.initContainer.image.registry | string | `"docker.io"` | Image registry. |
| seedClient.initContainer.image.repository | string | `"busybox"` | Image repository. |
| seedClient.initContainer.image.tag | string | `"latest"` | Image tag. |
| seedClient.initContainer.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits. |
| seedClient.maxProcs | string | `""` | maxProcs Limits the number of operating system threads that can execute user-level. Go code simultaneously by setting GOMAXPROCS environment variable, refer to https://golang.org/pkg/runtime. |
| seedClient.metrics.enable | bool | `false` | Enable seed client metrics. |
| seedClient.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels. |
| seedClient.metrics.prometheusRule.enable | bool | `false` | Enable prometheus rule ref: https://github.com/coreos/prometheus-operator. |
| seedClient.metrics.prometheusRule.rules | list | `[{"alert":"SeedClientDown","annotations":{"message":"Seed client instance {{ \"{{ $labels.instance }}\" }} is down","summary":"Seed client instance is down"},"expr":"sum(dragonfly_client_version{container=\"seed-client\"}) == 0","for":"5m","labels":{"severity":"critical"}},{"alert":"SeedClientHighNumberOfFailedDownloadTask","annotations":{"message":"Seed client has a high number of failed download task","summary":"Seed client has a high number of failed download task"},"expr":"sum(irate(dragonfly_client_download_task_failure_total{container=\"seed-client\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SeedClientSuccessRateOfDownloadingTask","annotations":{"message":"Seed client's success rate of downloading task is low","summary":"Seed client's success rate of downloading task is low"},"expr":"(sum(rate(dragonfly_client_download_task_total{container=\"seed-client\"}[1m])) - sum(rate(dragonfly_client_download_task_failure_total{container=\"seed-client\"}[1m]))) / sum(rate(dragonfly_client_download_task_total{container=\"seed-client\"}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}}]` | Prometheus rules. |
| seedClient.metrics.service.annotations | object | `{}` | Service annotations. |
| seedClient.metrics.service.labels | object | `{}` | Service labels. |
| seedClient.metrics.service.type | string | `"ClusterIP"` | Service type. |
| seedClient.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels |
| seedClient.metrics.serviceMonitor.enable | bool | `false` | Enable prometheus service monitor. ref: https://github.com/coreos/prometheus-operator. |
| seedClient.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped. |
| seedClient.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended. |
| seedClient.name | string | `"seed-client"` | Seed client name. |
| seedClient.nameOverride | string | `""` | Override scheduler name. |
| seedClient.nodeSelector | object | `{}` | Node labels for pod assignment. |
| seedClient.persistence.accessModes | list | `["ReadWriteOnce"]` | Persistence access modes. |
| seedClient.persistence.annotations | object | `{}` | Persistence annotations. |
| seedClient.persistence.enable | bool | `true` | Enable persistence for seed peer. |
| seedClient.persistence.size | string | `"50Gi"` | Persistence persistence size. |
| seedClient.podAnnotations | object | `{}` | Pod annotations. |
| seedClient.podLabels | object | `{}` | Pod labels. |
| seedClient.priorityClassName | string | `""` | Pod priorityClassName. |
| seedClient.replicas | int | `3` | Number of Pods to launch. |
| seedClient.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits. |
| seedClient.service.annotations | object | `{}` | Service annotations. |
| seedClient.service.labels | object | `{}` | Service labels. |
| seedClient.service.type | string | `"ClusterIP"` | Service type. |
| seedClient.statefulsetAnnotations | object | `{}` | Statefulset annotations. |
| seedClient.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds. |
| seedClient.tolerations | list | `[]` | List of node taints to tolerate. |
| seedClient.updateStrategy | object | `{}` | Update strategy for replicas. |

## Chart dependencies

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | mysql | 10.1.1 |
| https://charts.bitnami.com/bitnami | redis | 19.5.5 |
