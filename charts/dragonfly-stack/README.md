# Dragonfly Stack Helm Chart

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/dragonfly)](https://artifacthub.io/packages/search?repo=dragonfly-stack)

Collects Dragonfly component and Nydus component into a single chart to provide a complete solution for the Dragonfly stack.

## TL;DR

```shell
helm repo add dragonfly-stack https://dragonflyoss.github.io/helm-charts/
helm install --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly-stask
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
dragonfly:
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

Install dragonfly-stack chart with release name `dragonfly`:

```shell
helm repo add dragonfly-stack https://dragonflyoss.github.io/helm-charts/
helm install --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly-stack -f values.yaml
```

### Install with an existing manager

Create the `values.yaml` configuration file. Need to configure the cluster id associated with scheduler and seed peer. This example is to deploy a cluster using the existing manager and redis.

```yaml
dragonfly:
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

Install dragonfly-stack chart with release name `dragonfly`:

```shell
helm repo add dragonfly-stack https://dragonflyoss.github.io/helm-charts/
helm install --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly-stack -f values.yaml
```

## Uninstall

Uninstall the `dragonfly` deployment:

```shell
helm delete dragonfly --namespace dragonfly-system
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dragonfly.client.config.download.concurrentPieceCount | int | `16` | concurrentPieceCount is the number of concurrent pieces to download. |
| dragonfly.client.config.download.pieceTimeout | string | `"30s"` | pieceTimeout is the timeout for downloading a piece from source. |
| dragonfly.client.config.download.rateLimit | int | `20000000000` | rateLimit is the default rate limit of the download speed in bps(bytes per second), default is 20Gbps. |
| dragonfly.client.config.download.server.socketPath | string | `"/var/run/dragonfly/dfdaemon.sock"` | socketPath is the unix socket path for dfdaemon GRPC service. |
| dragonfly.client.config.dynconfig.refreshInterval | string | `"5m"` | refreshInterval is the interval to refresh dynamic configuration from manager. |
| dragonfly.client.config.gc.interval | string | `"900s"` | interval is the interval to do gc. |
| dragonfly.client.config.gc.policy.distHighThresholdPercent | int | `80` | distHighThresholdPercent is the high threshold percent of the disk usage. If the disk usage is greater than the threshold, dfdaemon will do gc. |
| dragonfly.client.config.gc.policy.distLowThresholdPercent | int | `60` | distLowThresholdPercent is the low threshold percent of the disk usage. If the disk usage is less than the threshold, dfdaemon will stop gc. |
| dragonfly.client.config.gc.policy.taskTTL | string | `"168h"` | taskTTL is the ttl of the task. |
| dragonfly.client.config.health.server.port | int | `4003` | port is the port to the health server. |
| dragonfly.client.config.host | object | `{"idc":"","location":""}` | host is the host configuration for dfdaemon. |
| dragonfly.client.config.log.level | string | `"info"` | Specify the logging level [trace, debug, info, warn, error] |
| dragonfly.client.config.manager.addrs | list | `[]` | addrs is manager addresses. |
| dragonfly.client.config.metrics.server.port | int | `4002` | port is the port to the metrics server. |
| dragonfly.client.config.proxy.disableBackToSource | bool | `false` | disableBackToSource indicates whether disable to download back-to-source when download failed. |
| dragonfly.client.config.proxy.prefetch | bool | `false` | prefetch pre-downloads full of the task when download with range request. |
| dragonfly.client.config.proxy.readBufferSize | int | `32768` | readBufferSize is the buffer size for reading piece from disk, default is 32KB. |
| dragonfly.client.config.proxy.registryMirror.addr | string | `"https://index.docker.io"` | addr is the default address of the registry mirror. Proxy will start a registry mirror service for the client to pull the image. The client can use the default address of the registry mirror in configuration to pull the image. The `X-Dragonfly-Registry` header can instead of the default address of registry mirror. |
| dragonfly.client.config.proxy.rules | list | `[{"regex":"blobs/sha256.*"}]` | rules is the list of rules for the proxy server. regex is the regex of the request url. useTLS indicates whether use tls for the proxy backend. redirect is the redirect url. filteredQueryParams is the filtered query params to generate the task id. When filter is ["Signature", "Expires", "ns"], for example: http://example.com/xyz?Expires=e1&Signature=s1&ns=docker.io and http://example.com/xyz?Expires=e2&Signature=s2&ns=docker.io will generate the same task id. Default value includes the filtered query params of s3, gcs, oss, obs, cos. |
| dragonfly.client.config.proxy.server.port | int | `4001` | port is the port to the proxy server. |
| dragonfly.client.config.scheduler.announceInterval | string | `"5m"` | announceInterval is the interval to announce peer to the scheduler. Announcer will provide the scheduler with peer information for scheduling, peer information includes cpu, memory, etc. |
| dragonfly.client.config.scheduler.enableBackToSource | bool | `true` | enableBackToSource indicates whether enable back-to-source download, when the scheduling failed. |
| dragonfly.client.config.scheduler.maxScheduleCount | int | `5` | maxScheduleCount is the max count of schedule. |
| dragonfly.client.config.scheduler.scheduleTimeout | string | `"30s"` | scheduleTimeout is the timeout for scheduling. If the scheduling timesout, dfdaemon will back-to-source download if enableBackToSource is true, otherwise dfdaemon will return download failed. |
| dragonfly.client.config.security.enable | bool | `false` | enable indicates whether enable security. |
| dragonfly.client.config.stats.server.port | int | `4004` | port is the port to the stats server. |
| dragonfly.client.config.storage.dir | string | `"/var/lib/dragonfly/"` | dir is the directory to store task's metadata and content. |
| dragonfly.client.config.storage.keep | bool | `false` | keep indicates whether keep the task's metadata and content when the dfdaemon restarts. |
| dragonfly.client.config.storage.readBufferSize | int | `131072` | readBufferSize is the buffer size for reading piece from disk, default is 128KB. |
| dragonfly.client.config.storage.writeBufferSize | int | `131072` | writeBufferSize is the buffer size for writing piece to disk, default is 128KB. |
| dragonfly.client.config.upload.rateLimit | int | `20000000000` | rateLimit is the default rate limit of the upload speed in bps(bytes per second), default is 20Gbps. |
| dragonfly.client.config.upload.server.port | int | `4000` | port is the port to the grpc server. |
| dragonfly.client.config.verbose | bool | `false` | verbose prints log. |
| dragonfly.client.dfinit.config.containerRuntime.containerd.configPath | string | `"/etc/containerd/config.toml"` | configPath is the path of containerd configuration file. |
| dragonfly.client.dfinit.config.containerRuntime.containerd.registries | list | `[{"capabilities":["pull","resolve"],"hostNamespace":"docker.io","serverAddr":"https://index.docker.io"},{"capabilities":["pull","resolve"],"hostNamespace":"ghcr.io","serverAddr":"https://ghcr.io"}]` | registries is the list of containerd registries. hostNamespace is the location where container images and artifacts are sourced, refer to https://github.com/containerd/containerd/blob/main/docs/hosts.md#registry-host-namespace. The registry host namespace portion is [registry_host_name|IP address][:port], such as docker.io, ghcr.io, gcr.io, etc. serverAddr specifies the default server for this registry host namespace, refer to https://github.com/containerd/containerd/blob/main/docs/hosts.md#server-field. capabilities is the list of capabilities in containerd configuration, refer to https://github.com/containerd/containerd/blob/main/docs/hosts.md#capabilities-field. |
| dragonfly.client.dfinit.config.log.level | string | `"info"` | Specify the logging level [trace, debug, info, warn, error] |
| dragonfly.client.dfinit.config.proxy.addr | string | `"http://127.0.0.1:4001"` | addr is the proxy server address of dfdaemon. |
| dragonfly.client.dfinit.config.verbose | bool | `true` | verbose prints log. |
| dragonfly.client.dfinit.enable | bool | `false` | Enable dfinit to override configuration of container runtime. |
| dragonfly.client.dfinit.image.digest | string | `""` | Image digest. |
| dragonfly.client.dfinit.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| dragonfly.client.dfinit.image.registry | string | `"docker.io"` | Image registry. |
| dragonfly.client.dfinit.image.repository | string | `"dragonflyoss/dfinit"` | Image repository. |
| dragonfly.client.dfinit.image.tag | string | `"v0.1.82"` | Image tag. |
| dragonfly.client.enable | bool | `true` | Enable client. |
| dragonfly.client.extraVolumeMounts | list | `[{"mountPath":"/var/lib/dragonfly/","name":"storage"},{"mountPath":"/var/log/dragonfly/dfdaemon/","name":"logs"}]` | Extra volumeMounts for dfdaemon. |
| dragonfly.client.extraVolumes | list | `[{"hostPath":{"path":"/var/lib/dragonfly/","type":"DirectoryOrCreate"},"name":"storage"},{"emptyDir":{},"name":"logs"}]` | Extra volumes for dfdaemon. |
| dragonfly.client.fullnameOverride | string | `""` | Override scheduler fullname. |
| dragonfly.client.hostAliases | list | `[]` | Host Aliases. |
| dragonfly.client.hostIPC | bool | `true` | hostIPC specify if host IPC should be enabled for peer pod. |
| dragonfly.client.hostNetwork | bool | `true` | hostNetwork specify if host network should be enabled for peer pod. |
| dragonfly.client.hostPID | bool | `true` | hostPID allows visibility of processes on the host for peer pod. |
| dragonfly.client.image.digest | string | `""` | Image digest. |
| dragonfly.client.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| dragonfly.client.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| dragonfly.client.image.registry | string | `"docker.io"` | Image registry. |
| dragonfly.client.image.repository | string | `"dragonflyoss/client"` | Image repository. |
| dragonfly.client.image.tag | string | `"v0.1.82"` | Image tag. |
| dragonfly.client.initContainer.image.digest | string | `""` | Image digest. |
| dragonfly.client.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| dragonfly.client.initContainer.image.registry | string | `"docker.io"` | Image registry. |
| dragonfly.client.initContainer.image.repository | string | `"busybox"` | Image repository. |
| dragonfly.client.initContainer.image.tag | string | `"latest"` | Image tag. |
| dragonfly.client.maxProcs | string | `""` | maxProcs Limits the number of operating system threads that can execute user-level. Go code simultaneously by setting GOMAXPROCS environment variable, refer to https://golang.org/pkg/runtime. |
| dragonfly.client.metrics.enable | bool | `false` | Enable client metrics. |
| dragonfly.client.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels. |
| dragonfly.client.metrics.prometheusRule.enable | bool | `false` | Enable prometheus rule ref: https://github.com/coreos/prometheus-operator. |
| dragonfly.client.metrics.prometheusRule.rules | list | `[{"alert":"ClientDown","annotations":{"message":"Client instance {{ \"{{ $labels.instance }}\" }} is down","summary":"Client instance is down"},"expr":"sum(dragonfly_client_version{container=\"client\"}) == 0","for":"5m","labels":{"severity":"critical"}},{"alert":"ClientHighNumberOfFailedDownloadTask","annotations":{"message":"Client has a high number of failed download task","summary":"Client has a high number of failed download task"},"expr":"sum(irate(dragonfly_client_download_task_failure_total{container=\"client\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"ClientSuccessRateOfDownloadingTask","annotations":{"message":"Client's success rate of downloading task is low","summary":"Client's success rate of downloading task is low"},"expr":"(sum(rate(dragonfly_client_download_task_total{container=\"client\"}[1m])) - sum(rate(dragonfly_client_download_task_failure_total{container=\"client\"}[1m]))) / sum(rate(dragonfly_client_download_task_total{container=\"client\"}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}}]` | Prometheus rules. |
| dragonfly.client.metrics.service.annotations | object | `{}` | Service annotations. |
| dragonfly.client.metrics.service.labels | object | `{}` | Service labels. |
| dragonfly.client.metrics.service.type | string | `"ClusterIP"` | Service type. |
| dragonfly.client.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels |
| dragonfly.client.metrics.serviceMonitor.enable | bool | `false` | Enable prometheus service monitor. ref: https://github.com/coreos/prometheus-operator. |
| dragonfly.client.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped. |
| dragonfly.client.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended. |
| dragonfly.client.name | string | `"client"` | Client name. |
| dragonfly.client.nameOverride | string | `""` | Override scheduler name. |
| dragonfly.client.nodeSelector | object | `{}` | Node labels for pod assignment. |
| dragonfly.client.podAnnotations | object | `{}` | Pod annotations. |
| dragonfly.client.podLabels | object | `{}` | Pod labels. |
| dragonfly.client.priorityClassName | string | `""` | Pod priorityClassName. |
| dragonfly.client.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits. |
| dragonfly.client.statefulsetAnnotations | object | `{}` | Statefulset annotations. |
| dragonfly.client.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds. |
| dragonfly.client.tolerations | list | `[]` | List of node taints to tolerate. |
| dragonfly.client.updateStrategy | object | `{}` | Update strategy for replicas. |
| dragonfly.enabled | bool | `true` |  |
| dragonfly.externalManager.grpcPort | int | `65003` | External GRPC service port. |
| dragonfly.externalManager.host | string | `nil` | External manager hostname. |
| dragonfly.externalManager.restPort | int | `8080` | External REST service port. |
| dragonfly.externalMysql.database | string | `"manager"` | External mysql database name. |
| dragonfly.externalMysql.host | string | `nil` | External mysql hostname. |
| dragonfly.externalMysql.migrate | bool | `true` | Running GORM migration. |
| dragonfly.externalMysql.password | string | `"dragonfly"` | External mysql password. |
| dragonfly.externalMysql.port | int | `3306` | External mysql port. |
| dragonfly.externalMysql.username | string | `"dragonfly"` | External mysql username. |
| dragonfly.externalRedis.addrs | list | `["redis.example.com:6379"]` | External redis server addresses. |
| dragonfly.externalRedis.backendDB | int | `2` | External redis backend db. |
| dragonfly.externalRedis.brokerDB | int | `1` | External redis broker db. |
| dragonfly.externalRedis.db | int | `0` | External redis db. |
| dragonfly.externalRedis.masterName | string | `""` | External redis sentinel master name. |
| dragonfly.externalRedis.password | string | `""` | External redis password. |
| dragonfly.externalRedis.username | string | `""` | External redis username. |
| dragonfly.manager.config.auth.jwt.key | string | `"ZHJhZ29uZmx5Cg=="` | Key is secret key used for signing, default value is encoded base64 of dragonfly. Please change the key in production. |
| dragonfly.manager.config.auth.jwt.maxRefresh | string | `"48h"` | MaxRefresh field allows clients to refresh their token until MaxRefresh has passed, default duration is two days. |
| dragonfly.manager.config.auth.jwt.realm | string | `"Dragonfly"` | Realm name to display to the user, default value is Dragonfly. |
| dragonfly.manager.config.auth.jwt.timeout | string | `"48h"` | Timeout is duration that a jwt token is valid, default duration is two days. |
| dragonfly.manager.config.cache.local.size | int | `200000` | Size of LFU cache. |
| dragonfly.manager.config.cache.local.ttl | string | `"3m"` | Local cache TTL duration. |
| dragonfly.manager.config.cache.redis.ttl | string | `"5m"` | Redis cache TTL duration. |
| dragonfly.manager.config.console | bool | `false` | Console shows log on console. |
| dragonfly.manager.config.jaeger | string | `""` |  |
| dragonfly.manager.config.job.preheat | object | `{"registryTimeout":"1m"}` | Preheat configuration. |
| dragonfly.manager.config.job.preheat.registryTimeout | string | `"1m"` | registryTimeout is the timeout for requesting registry to get token and manifest. |
| dragonfly.manager.config.job.syncPeers | object | `{"interval":"24h","timeout":"10m"}` | Sync peers configuration. |
| dragonfly.manager.config.job.syncPeers.interval | string | `"24h"` | interval is the interval for syncing all peers information from the scheduler and display peers information in the manager console. |
| dragonfly.manager.config.job.syncPeers.timeout | string | `"10m"` | timeout is the timeout for syncing peers information from the single scheduler. |
| dragonfly.manager.config.network.enableIPv6 | bool | `false` | enableIPv6 enables ipv6. |
| dragonfly.manager.config.objectStorage.accessKey | string | `""` | AccessKey is access key ID. |
| dragonfly.manager.config.objectStorage.enable | bool | `false` | Enable object storage. |
| dragonfly.manager.config.objectStorage.endpoint | string | `""` | Endpoint is datacenter endpoint. |
| dragonfly.manager.config.objectStorage.name | string | `"s3"` | Name is object storage name of type, it can be s3 or oss. |
| dragonfly.manager.config.objectStorage.region | string | `""` | Reigon is storage region. |
| dragonfly.manager.config.objectStorage.s3ForcePathStyle | bool | `true` | S3ForcePathStyle sets force path style for s3, true by default. Set this to `true` to force the request to use path-style addressing, i.e., `http://s3.amazonaws.com/BUCKET/KEY`. By default, the S3 client will use virtual hosted bucket addressing when possible (`http://BUCKET.s3.amazonaws.com/KEY`). Refer to https://github.com/aws/aws-sdk-go/blob/main/aws/config.go#L118. |
| dragonfly.manager.config.objectStorage.secretKey | string | `""` | SecretKey is access key secret. |
| dragonfly.manager.config.pprofPort | int | `-1` | Listen port for pprof, only valid when the verbose option is true default is -1. If it is 0, pprof will use a random port. |
| dragonfly.manager.config.security.autoIssueCert | bool | `false` | AutoIssueCert indicates to issue client certificates for all grpc call. If AutoIssueCert is false, any other option in Security will be ignored. |
| dragonfly.manager.config.security.caCert | string | `""` | CACert is the CA certificate for all grpc tls handshake, it can be path or PEM format string. |
| dragonfly.manager.config.security.caKey | string | `""` | CAKey is the CA private key, it can be path or PEM format string. |
| dragonfly.manager.config.security.certSpec.dnsNames | list | `["dragonfly-manager","dragonfly-manager.dragonfly-system.svc","dragonfly-manager.dragonfly-system.svc.cluster.local"]` | DNSNames is a list of dns names be set on the certificate. |
| dragonfly.manager.config.security.certSpec.ipAddresses | string | `nil` | IPAddresses is a list of ip addresses be set on the certificate. |
| dragonfly.manager.config.security.certSpec.validityPeriod | string | `"87600h"` | ValidityPeriod is the validity period  of certificate. |
| dragonfly.manager.config.security.tlsPolicy | string | `"prefer"` | TLSPolicy controls the grpc shandshake behaviors:   force: both ClientHandshake and ServerHandshake are only support tls.   prefer: ServerHandshake supports tls and insecure (non-tls), ClientHandshake will only support tls.   default: ServerHandshake supports tls and insecure (non-tls), ClientHandshake will only support insecure (non-tls). Notice: If the drgaonfly service has been deployed, a two-step upgrade is required. The first step is to set tlsPolicy to default, and then upgrade the dragonfly services. The second step is to set tlsPolicy to prefer, and tthen completely upgrade the dragonfly services. |
| dragonfly.manager.config.server.cacheDir | string | `""` | Dynconfig cache directory. |
| dragonfly.manager.config.server.grpc.advertiseIP | string | `""` | GRPC advertise ip. |
| dragonfly.manager.config.server.logDir | string | `""` | Log directory. |
| dragonfly.manager.config.server.pluginDir | string | `""` | Plugin directory. |
| dragonfly.manager.config.server.rest.tls.cert | string | `""` | Certificate file path. |
| dragonfly.manager.config.server.rest.tls.key | string | `""` | Key file path. |
| dragonfly.manager.config.server.workHome | string | `""` | Work directory. |
| dragonfly.manager.config.verbose | bool | `false` | Whether to enable debug level logger and enable pprof. |
| dragonfly.manager.deploymentAnnotations | object | `{}` | Deployment annotations. |
| dragonfly.manager.enable | bool | `true` | Enable manager. |
| dragonfly.manager.extraVolumeMounts | list | `[{"mountPath":"/var/log/dragonfly/manager","name":"logs"}]` | Extra volumeMounts for manager. |
| dragonfly.manager.extraVolumes | list | `[{"emptyDir":{},"name":"logs"}]` | Extra volumes for manager. |
| dragonfly.manager.fullnameOverride | string | `""` | Override manager fullname. |
| dragonfly.manager.grpcPort | int | `65003` | GRPC service port. |
| dragonfly.manager.hostAliases | list | `[]` | Host Aliases. |
| dragonfly.manager.image.digest | string | `""` | Image digest. |
| dragonfly.manager.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| dragonfly.manager.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| dragonfly.manager.image.registry | string | `"docker.io"` | Image registry. |
| dragonfly.manager.image.repository | string | `"dragonflyoss/manager"` | Image repository. |
| dragonfly.manager.image.tag | string | `"v2.1.49"` | Image tag. |
| dragonfly.manager.ingress.annotations | object | `{}` | Ingress annotations. |
| dragonfly.manager.ingress.className | string | `""` | Ingress class name. Requirement: kubernetes >=1.18. |
| dragonfly.manager.ingress.enable | bool | `false` | Enable ingress. |
| dragonfly.manager.ingress.hosts | list | `[]` | Manager ingress hosts. |
| dragonfly.manager.ingress.path | string | `"/"` | Ingress host path. |
| dragonfly.manager.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type. Requirement: kubernetes >=1.18. |
| dragonfly.manager.ingress.tls | list | `[]` | Ingress TLS configuration. |
| dragonfly.manager.initContainer.image.digest | string | `""` | Image digest. |
| dragonfly.manager.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| dragonfly.manager.initContainer.image.registry | string | `"docker.io"` | Image registry. |
| dragonfly.manager.initContainer.image.repository | string | `"busybox"` | Image repository. |
| dragonfly.manager.initContainer.image.tag | string | `"latest"` | Image tag. |
| dragonfly.manager.maxProcs | string | `""` | maxProcs Limits the number of operating system threads that can execute user-level. Go code simultaneously by setting GOMAXPROCS environment variable, refer to https://golang.org/pkg/runtime. |
| dragonfly.manager.metrics.enable | bool | `false` | Enable manager metrics. |
| dragonfly.manager.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels. |
| dragonfly.manager.metrics.prometheusRule.enable | bool | `false` | Enable prometheus rule. ref: https://github.com/coreos/prometheus-operator. |
| dragonfly.manager.metrics.prometheusRule.rules | list | `[{"alert":"ManagerDown","annotations":{"message":"Manager instance {{ \"{{ $labels.instance }}\" }} is down","summary":"Manager instance is down"},"expr":"sum(dragonfly_manager_version{}) == 0","for":"5m","labels":{"severity":"critical"}},{"alert":"ManagerHighNumberOfFailedGRPCRequest","annotations":{"message":"Manager has a high number of failed grpc request","summary":"Manager has a high number of failed grpc request"},"expr":"sum(rate(grpc_server_started_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\"}[1m])) - sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"OK\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"NotFound\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"PermissionDenied\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"InvalidArgument\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"ManagerSuccessRateOfGRPCRequest","annotations":{"message":"Manager's success rate of grpc request is low","summary":"Manager's success rate of grpc request is low"},"expr":"(sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"OK\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"NotFound\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"PermissionDenied\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\",grpc_code=\"InvalidArgument\"}[1m]))) / sum(rate(grpc_server_started_total{grpc_service=\"manager.Manager\",grpc_type=\"unary\"}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"ManagerHighNumberOfFailedRESTRequest","annotations":{"message":"Manager has a high number of failed rest request","summary":"Manager has a high number of failed rest request"},"expr":"sum(rate(dragonfly_manager_requests_total{}[1m])) - sum(rate(dragonfly_manager_requests_total{code=~\"[12]..\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"ManagerSuccessRateOfRESTRequest","annotations":{"message":"Manager's success rate of rest request is low","summary":"Manager's success rate of rest request is low"},"expr":"sum(rate(dragonfly_manager_requests_total{code=~\"[12]..\"}[1m])) / sum(rate(dragonfly_manager_requests_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}}]` | Prometheus rules. |
| dragonfly.manager.metrics.service.annotations | object | `{}` | Service annotations. |
| dragonfly.manager.metrics.service.labels | object | `{}` | Service labels. |
| dragonfly.manager.metrics.service.type | string | `"ClusterIP"` | Service type. |
| dragonfly.manager.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels. |
| dragonfly.manager.metrics.serviceMonitor.enable | bool | `false` | Enable prometheus service monitor. ref: https://github.com/coreos/prometheus-operator. |
| dragonfly.manager.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped. |
| dragonfly.manager.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended. |
| dragonfly.manager.name | string | `"manager"` | Manager name. |
| dragonfly.manager.nameOverride | string | `""` | Override manager name. |
| dragonfly.manager.nodeSelector | object | `{}` | Node labels for pod assignment. |
| dragonfly.manager.podAnnotations | object | `{}` | Pod annotations. |
| dragonfly.manager.podLabels | object | `{}` | Pod labels. |
| dragonfly.manager.priorityClassName | string | `""` | Pod priorityClassName. |
| dragonfly.manager.replicas | int | `3` | Number of Pods to launch. |
| dragonfly.manager.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits. |
| dragonfly.manager.restPort | int | `8080` | REST service port. |
| dragonfly.manager.service.annotations | object | `{}` | Service annotations. |
| dragonfly.manager.service.labels | object | `{}` | Service labels. |
| dragonfly.manager.service.type | string | `"ClusterIP"` | Service type. |
| dragonfly.manager.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds. |
| dragonfly.manager.tolerations | list | `[]` | List of node taints to tolerate. |
| dragonfly.manager.updateStrategy | object | `{"type":"RollingUpdate"}` | Update strategy for replicas. |
| dragonfly.mysql.auth.database | string | `"manager"` | Mysql database name. |
| dragonfly.mysql.auth.host | string | `""` | Mysql hostname. |
| dragonfly.mysql.auth.password | string | `"dragonfly"` | Mysql password. |
| dragonfly.mysql.auth.rootPassword | string | `"dragonfly-root"` | Mysql root password. |
| dragonfly.mysql.auth.username | string | `"dragonfly"` | Mysql username. |
| dragonfly.mysql.clusterDomain | string | `"cluster.local"` | Cluster domain. |
| dragonfly.mysql.enable | bool | `true` | Enable mysql with docker container. |
| dragonfly.mysql.migrate | bool | `true` | Running GORM migration. |
| dragonfly.mysql.primary.service.port | int | `3306` | Mysql port. |
| dragonfly.redis.auth.enabled | bool | `true` | Enable password authentication. |
| dragonfly.redis.auth.password | string | `"dragonfly"` | Redis password. |
| dragonfly.redis.clusterDomain | string | `"cluster.local"` | Cluster domain. |
| dragonfly.redis.enable | bool | `true` | Enable redis cluster with docker container. |
| dragonfly.redis.master.service.ports.redis | int | `6379` | Redis master service port. |
| dragonfly.scheduler.config.console | bool | `false` | Console shows log on console. |
| dragonfly.scheduler.config.dynconfig.refreshInterval | string | `"1m"` | Dynamic config refresh interval. |
| dragonfly.scheduler.config.dynconfig.type | string | `"manager"` | Type is deprecated and is no longer used. Please remove it from your configuration. |
| dragonfly.scheduler.config.host.idc | string | `""` | IDC is the idc of scheduler instance. |
| dragonfly.scheduler.config.host.location | string | `""` | Location is the location of scheduler instance. |
| dragonfly.scheduler.config.jaeger | string | `""` |  |
| dragonfly.scheduler.config.manager.keepAlive.interval | string | `"5s"` | Manager keepalive interval. |
| dragonfly.scheduler.config.manager.schedulerClusterID | int | `1` | Associated scheduler cluster id. |
| dragonfly.scheduler.config.network.enableIPv6 | bool | `false` | enableIPv6 enables ipv6. |
| dragonfly.scheduler.config.pprofPort | int | `-1` | Listen port for pprof, only valid when the verbose option is true. default is -1. If it is 0, pprof will use a random port. |
| dragonfly.scheduler.config.resource | object | `{"task":{"downloadTiny":{"scheme":"http","timeout":"1m","tls":{"insecureSkipVerify":true}}}}` | resource configuration. |
| dragonfly.scheduler.config.resource.task | object | `{"downloadTiny":{"scheme":"http","timeout":"1m","tls":{"insecureSkipVerify":true}}}` | task configuration. |
| dragonfly.scheduler.config.resource.task.downloadTiny | object | `{"scheme":"http","timeout":"1m","tls":{"insecureSkipVerify":true}}` | downloadTiny is the configuration of downloading tiny task by scheduler. |
| dragonfly.scheduler.config.resource.task.downloadTiny.scheme | string | `"http"` | scheme is download tiny task scheme. |
| dragonfly.scheduler.config.resource.task.downloadTiny.timeout | string | `"1m"` | timeout is http request timeout. |
| dragonfly.scheduler.config.resource.task.downloadTiny.tls | object | `{"insecureSkipVerify":true}` | tls is download tiny task TLS configuration. |
| dragonfly.scheduler.config.resource.task.downloadTiny.tls.insecureSkipVerify | bool | `true` | insecureSkipVerify controls whether a client verifies the server's certificate chain and hostname. |
| dragonfly.scheduler.config.scheduler.algorithm | string | `"default"` | Algorithm configuration to use different scheduling algorithms, default configuration supports "default", "ml" and "nt". "default" is the rule-based scheduling algorithm, "ml" is the machine learning scheduling algorithm. It also supports user plugin extension, the algorithm value is "plugin", and the compiled `d7y-scheduler-plugin-evaluator.so` file is added to the dragonfly working directory plugins. |
| dragonfly.scheduler.config.scheduler.backToSourceCount | int | `200` | backToSourceCount is single task allows the peer to back-to-source count. |
| dragonfly.scheduler.config.scheduler.gc.hostGCInterval | string | `"6h"` | hostGCInterval is the interval of host gc. |
| dragonfly.scheduler.config.scheduler.gc.hostTTL | string | `"1h"` | hostTTL is time to live of host. If host announces message to scheduler, then HostTTl will be reset. |
| dragonfly.scheduler.config.scheduler.gc.peerGCInterval | string | `"10s"` | peerGCInterval is the interval of peer gc. |
| dragonfly.scheduler.config.scheduler.gc.peerTTL | string | `"24h"` | peerTTL is the ttl of peer. If the peer has been downloaded by other peers, then PeerTTL will be reset. |
| dragonfly.scheduler.config.scheduler.gc.pieceDownloadTimeout | string | `"30m"` | pieceDownloadTimeout is the timeout of downloading piece. |
| dragonfly.scheduler.config.scheduler.gc.taskGCInterval | string | `"30m"` | taskGCInterval is the interval of task gc. If all the peers have been reclaimed in the task, then the task will also be reclaimed. |
| dragonfly.scheduler.config.scheduler.retryBackToSourceLimit | int | `5` | retryBackToSourceLimit reaches the limit, then the peer back-to-source. |
| dragonfly.scheduler.config.scheduler.retryInterval | string | `"700ms"` | Retry scheduling interval. |
| dragonfly.scheduler.config.scheduler.retryLimit | int | `7` | Retry scheduling limit times. |
| dragonfly.scheduler.config.security.autoIssueCert | bool | `false` | AutoIssueCert indicates to issue client certificates for all grpc call. If AutoIssueCert is false, any other option in Security will be ignored. |
| dragonfly.scheduler.config.security.caCert | string | `""` | CACert is the root CA certificate for all grpc tls handshake, it can be path or PEM format string. |
| dragonfly.scheduler.config.security.certSpec.dnsNames | list | `["dragonfly-scheduler","dragonfly-scheduler.dragonfly-system.svc","dragonfly-scheduler.dragonfly-system.svc.cluster.local"]` | DNSNames is a list of dns names be set on the certificate. |
| dragonfly.scheduler.config.security.certSpec.ipAddresses | string | `nil` | IPAddresses is a list of ip addresses be set on the certificate. |
| dragonfly.scheduler.config.security.certSpec.validityPeriod | string | `"4320h"` | ValidityPeriod is the validity period  of certificate. |
| dragonfly.scheduler.config.security.tlsPolicy | string | `"prefer"` | TLSPolicy controls the grpc shandshake behaviors:   force: both ClientHandshake and ServerHandshake are only support tls.   prefer: ServerHandshake supports tls and insecure (non-tls), ClientHandshake will only support tls.   default: ServerHandshake supports tls and insecure (non-tls), ClientHandshake will only support insecure (non-tls). Notice: If the drgaonfly service has been deployed, a two-step upgrade is required. The first step is to set tlsPolicy to default, and then upgrade the dragonfly services. The second step is to set tlsPolicy to prefer, and tthen completely upgrade the dragonfly services. |
| dragonfly.scheduler.config.security.tlsVerify | bool | `false` | TLSVerify indicates to verify certificates. |
| dragonfly.scheduler.config.seedPeer.enable | bool | `true` | scheduler enable seed peer as P2P peer, if the value is false, P2P network will not be back-to-source through seed peer but by dfdaemon and preheat feature does not work. |
| dragonfly.scheduler.config.server.advertiseIP | string | `""` | Advertise ip. |
| dragonfly.scheduler.config.server.advertisePort | int | `8002` | Advertise port. |
| dragonfly.scheduler.config.server.cacheDir | string | `""` | Dynconfig cache directory. |
| dragonfly.scheduler.config.server.dataDir | string | `""` | Storage directory. |
| dragonfly.scheduler.config.server.listenIP | string | `"0.0.0.0"` | Listen ip. |
| dragonfly.scheduler.config.server.logDir | string | `""` | Log directory. |
| dragonfly.scheduler.config.server.pluginDir | string | `""` | Plugin directory. |
| dragonfly.scheduler.config.server.port | int | `8002` | Server port. |
| dragonfly.scheduler.config.server.workHome | string | `""` | Work directory. |
| dragonfly.scheduler.config.storage.bufferSize | int | `100` | bufferSize sets the size of buffer container, if the buffer is full, write all the records in the buffer to the file. |
| dragonfly.scheduler.config.storage.maxBackups | int | `10` | maxBackups sets the maximum number of storage files to retain. |
| dragonfly.scheduler.config.storage.maxSize | int | `100` | maxSize sets the maximum size in megabytes of storage file. |
| dragonfly.scheduler.config.verbose | bool | `false` | Whether to enable debug level logger and enable pprof. |
| dragonfly.scheduler.containerPort | int | `8002` | Pod containerPort. |
| dragonfly.scheduler.enable | bool | `true` | Enable scheduler. |
| dragonfly.scheduler.extraVolumeMounts | list | `[{"mountPath":"/var/log/dragonfly/scheduler","name":"logs"}]` | Extra volumeMounts for scheduler. |
| dragonfly.scheduler.extraVolumes | list | `[{"emptyDir":{},"name":"logs"}]` | Extra volumes for scheduler. |
| dragonfly.scheduler.fullnameOverride | string | `""` | Override scheduler fullname. |
| dragonfly.scheduler.hostAliases | list | `[]` | Host Aliases. |
| dragonfly.scheduler.image.digest | string | `""` | Image digest. |
| dragonfly.scheduler.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| dragonfly.scheduler.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| dragonfly.scheduler.image.registry | string | `"docker.io"` | Image registry. |
| dragonfly.scheduler.image.repository | string | `"dragonflyoss/scheduler"` | Image repository. |
| dragonfly.scheduler.image.tag | string | `"v2.1.49"` | Image tag. |
| dragonfly.scheduler.initContainer.image.digest | string | `""` | Image digest. |
| dragonfly.scheduler.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| dragonfly.scheduler.initContainer.image.registry | string | `"docker.io"` | Image registry. |
| dragonfly.scheduler.initContainer.image.repository | string | `"busybox"` | Image repository. |
| dragonfly.scheduler.initContainer.image.tag | string | `"latest"` | Image tag. |
| dragonfly.scheduler.maxProcs | string | `""` | maxProcs Limits the number of operating system threads that can execute user-level. Go code simultaneously by setting GOMAXPROCS environment variable, refer to https://golang.org/pkg/runtime. |
| dragonfly.scheduler.metrics.enable | bool | `false` | Enable scheduler metrics. |
| dragonfly.scheduler.metrics.enableHost | bool | `false` | Enable host metrics. |
| dragonfly.scheduler.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels. |
| dragonfly.scheduler.metrics.prometheusRule.enable | bool | `false` | Enable prometheus rule ref: https://github.com/coreos/prometheus-operator. |
| dragonfly.scheduler.metrics.prometheusRule.rules | list | `[{"alert":"SchedulerDown","annotations":{"message":"Scheduler instance {{ \"{{ $labels.instance }}\" }} is down","summary":"Scheduler instance is down"},"expr":"sum(dragonfly_scheduler_version{}) == 0","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedDownloadPeer","annotations":{"message":"Scheduler has a high number of failed download peer","summary":"Scheduler has a high number of failed download peer"},"expr":"sum(irate(dragonfly_scheduler_download_peer_finished_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfDownloadingPeer","annotations":{"message":"Scheduler's success rate of downloading peer is low","summary":"Scheduler's success rate of downloading peer is low"},"expr":"(sum(rate(dragonfly_scheduler_download_peer_finished_total{}[1m])) - sum(rate(dragonfly_scheduler_download_peer_finished_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_download_peer_finished_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedRegisterPeer","annotations":{"message":"Scheduler has a high number of failed register peer","summary":"Scheduler has a high number of failed register peer"},"expr":"sum(irate(dragonfly_scheduler_register_peer_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfRegisterTask","annotations":{"message":"Scheduler's success rate of register peer is low","summary":"Scheduler's success rate of register peer is low"},"expr":"(sum(rate(dragonfly_scheduler_register_peer_total{}[1m])) - sum(rate(dragonfly_scheduler_register_peer_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_register_peer_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedLeavePeer","annotations":{"message":"Scheduler has a high number of failed leave peer","summary":"Scheduler has a high number of failed leave peer"},"expr":"sum(irate(dragonfly_scheduler_leave_peer_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfLeavingPeer","annotations":{"message":"Scheduler's success rate of leaving peer is low","summary":"Scheduler's success rate of leaving peer is low"},"expr":"(sum(rate(dragonfly_scheduler_leave_peer_total{}[1m])) - sum(rate(dragonfly_scheduler_leave_peer_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_leave_peer_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedStatTask","annotations":{"message":"Scheduler has a high number of failed stat task","summary":"Scheduler has a high number of failed stat task"},"expr":"sum(irate(dragonfly_scheduler_stat_task_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfStatTask","annotations":{"message":"Scheduler's success rate of stat task is low","summary":"Scheduler's success rate of stat task is low"},"expr":"(sum(rate(dragonfly_scheduler_stat_task_total{}[1m])) - sum(rate(dragonfly_scheduler_stat_task_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_stat_task_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedAnnouncePeer","annotations":{"message":"Scheduler has a high number of failed announce peer","summary":"Scheduler has a high number of failed announce peer"},"expr":"sum(irate(dragonfly_scheduler_announce_peer_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfAnnouncingPeer","annotations":{"message":"Scheduler's success rate of announcing peer is low","summary":"Scheduler's success rate of announcing peer is low"},"expr":"(sum(rate(dragonfly_scheduler_announce_peer_total{}[1m])) - sum(rate(dragonfly_scheduler_announce_peer_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_announce_peer_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedLeaveHost","annotations":{"message":"Scheduler has a high number of failed leave host","summary":"Scheduler has a high number of failed leave host"},"expr":"sum(irate(dragonfly_scheduler_leave_host_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfLeavingHost","annotations":{"message":"Scheduler's success rate of leaving host is low","summary":"Scheduler's success rate of leaving host is low"},"expr":"(sum(rate(dragonfly_scheduler_leave_host_total{}[1m])) - sum(rate(dragonfly_scheduler_leave_host_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_leave_host_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedAnnounceHost","annotations":{"message":"Scheduler has a high number of failed annoucne host","summary":"Scheduler has a high number of failed annoucne host"},"expr":"sum(irate(dragonfly_scheduler_announce_host_failure_total{}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfAnnouncingHost","annotations":{"message":"Scheduler's success rate of announcing host is low","summary":"Scheduler's success rate of announcing host is low"},"expr":"(sum(rate(dragonfly_scheduler_announce_host_total{}[1m])) - sum(rate(dragonfly_scheduler_announce_host_failure_total{}[1m]))) / sum(rate(dragonfly_scheduler_announce_host_total{}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}},{"alert":"SchedulerHighNumberOfFailedGRPCRequest","annotations":{"message":"Scheduler has a high number of failed grpc request","summary":"Scheduler has a high number of failed grpc request"},"expr":"sum(rate(grpc_server_started_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\"}[1m])) - sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"OK\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"NotFound\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"PermissionDenied\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"InvalidArgument\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SchedulerSuccessRateOfGRPCRequest","annotations":{"message":"Scheduler's success rate of grpc request is low","summary":"Scheduler's success rate of grpc request is low"},"expr":"(sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"OK\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"NotFound\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"PermissionDenied\"}[1m])) + sum(rate(grpc_server_handled_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\",grpc_code=\"InvalidArgument\"}[1m]))) / sum(rate(grpc_server_started_total{grpc_service=\"scheduler.Scheduler\",grpc_type=\"unary\"}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}}]` | Prometheus rules. |
| dragonfly.scheduler.metrics.service.annotations | object | `{}` | Service annotations. |
| dragonfly.scheduler.metrics.service.labels | object | `{}` | Service labels. |
| dragonfly.scheduler.metrics.service.type | string | `"ClusterIP"` | Service type. |
| dragonfly.scheduler.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels. |
| dragonfly.scheduler.metrics.serviceMonitor.enable | bool | `false` | Enable prometheus service monitor. ref: https://github.com/coreos/prometheus-operator. |
| dragonfly.scheduler.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped. |
| dragonfly.scheduler.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended. |
| dragonfly.scheduler.name | string | `"scheduler"` | Scheduler name. |
| dragonfly.scheduler.nameOverride | string | `""` | Override scheduler name. |
| dragonfly.scheduler.nodeSelector | object | `{}` | Node labels for pod assignment. |
| dragonfly.scheduler.podAnnotations | object | `{}` | Pod annotations. |
| dragonfly.scheduler.podLabels | object | `{}` | Pod labels. |
| dragonfly.scheduler.priorityClassName | string | `""` | Pod priorityClassName. |
| dragonfly.scheduler.replicas | int | `3` | Number of Pods to launch. |
| dragonfly.scheduler.resources | object | `{"limits":{"cpu":"4","memory":"8Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits. |
| dragonfly.scheduler.service.annotations | object | `{}` | Service annotations. |
| dragonfly.scheduler.service.labels | object | `{}` | Service labels. |
| dragonfly.scheduler.service.type | string | `"ClusterIP"` | Service type. |
| dragonfly.scheduler.statefulsetAnnotations | object | `{}` | Statefulset annotations. |
| dragonfly.scheduler.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds. |
| dragonfly.scheduler.tolerations | list | `[]` | List of node taints to tolerate. |
| dragonfly.scheduler.updateStrategy | object | `{}` | Update strategy for replicas. |
| dragonfly.seedClient.config.download.concurrentPieceCount | int | `16` | concurrentPieceCount is the number of concurrent pieces to download. |
| dragonfly.seedClient.config.download.pieceTimeout | string | `"30s"` | pieceTimeout is the timeout for downloading a piece from source. |
| dragonfly.seedClient.config.download.rateLimit | int | `20000000000` | rateLimit is the default rate limit of the download speed in bps(bytes per second), default is 20Gbps. |
| dragonfly.seedClient.config.download.server.socketPath | string | `"/var/run/dragonfly/dfdaemon.sock"` | socketPath is the unix socket path for dfdaemon GRPC service. |
| dragonfly.seedClient.config.dynconfig.refreshInterval | string | `"1m"` | refreshInterval is the interval to refresh dynamic configuration from manager. |
| dragonfly.seedClient.config.gc.interval | string | `"900s"` | interval is the interval to do gc. |
| dragonfly.seedClient.config.gc.policy.distHighThresholdPercent | int | `80` | distHighThresholdPercent is the high threshold percent of the disk usage. If the disk usage is greater than the threshold, dfdaemon will do gc. |
| dragonfly.seedClient.config.gc.policy.distLowThresholdPercent | int | `60` | distLowThresholdPercent is the low threshold percent of the disk usage. If the disk usage is less than the threshold, dfdaemon will stop gc. |
| dragonfly.seedClient.config.gc.policy.taskTTL | string | `"168h"` | taskTTL is the ttl of the task. |
| dragonfly.seedClient.config.health.server.port | int | `4003` | port is the port to the health server. |
| dragonfly.seedClient.config.host | object | `{"idc":"","location":""}` | host is the host configuration for dfdaemon. |
| dragonfly.seedClient.config.log.level | string | `"info"` | Specify the logging level [trace, debug, info, warn, error] |
| dragonfly.seedClient.config.manager.addrs | list | `[]` | addrs is manager addresses. |
| dragonfly.seedClient.config.metrics.server.port | int | `4002` | port is the port to the metrics server. |
| dragonfly.seedClient.config.proxy.disableBackToSource | bool | `false` | disableBackToSource indicates whether disable to download back-to-source when download failed. |
| dragonfly.seedClient.config.proxy.prefetch | bool | `false` | prefetch pre-downloads full of the task when download with range request. |
| dragonfly.seedClient.config.proxy.readBufferSize | int | `32768` | readBufferSize is the buffer size for reading piece from disk, default is 32KB. |
| dragonfly.seedClient.config.proxy.registryMirror.addr | string | `"https://index.docker.io"` | addr is the default address of the registry mirror. Proxy will start a registry mirror service for the client to pull the image. The client can use the default address of the registry mirror in configuration to pull the image. The `X-Dragonfly-Registry` header can instead of the default address of registry mirror. |
| dragonfly.seedClient.config.proxy.rules | list | `[{"regex":"blobs/sha256.*"}]` | rules is the list of rules for the proxy server. regex is the regex of the request url. useTLS indicates whether use tls for the proxy backend. redirect is the redirect url. filteredQueryParams is the filtered query params to generate the task id. When filter is ["Signature", "Expires", "ns"], for example: http://example.com/xyz?Expires=e1&Signature=s1&ns=docker.io and http://example.com/xyz?Expires=e2&Signature=s2&ns=docker.io will generate the same task id. Default value includes the filtered query params of s3, gcs, oss, obs, cos. |
| dragonfly.seedClient.config.proxy.server.port | int | `4001` | port is the port to the proxy server. |
| dragonfly.seedClient.config.scheduler.announceInterval | string | `"1m"` | announceInterval is the interval to announce peer to the scheduler. Announcer will provide the scheduler with peer information for scheduling, peer information includes cpu, memory, etc. |
| dragonfly.seedClient.config.scheduler.maxScheduleCount | int | `5` | maxScheduleCount is the max count of schedule. |
| dragonfly.seedClient.config.scheduler.scheduleTimeout | string | `"30s"` | scheduleTimeout is the timeout for scheduling. If the scheduling timesout, dfdaemon will back-to-source download if enableBackToSource is true, otherwise dfdaemon will return download failed. |
| dragonfly.seedClient.config.security.enable | bool | `false` | enable indicates whether enable security. |
| dragonfly.seedClient.config.seedPeer.clusterID | int | `1` | clusterID is the cluster id of the seed peer cluster. |
| dragonfly.seedClient.config.seedPeer.enable | bool | `true` | enable indicates whether enable seed peer. |
| dragonfly.seedClient.config.seedPeer.keepaliveInterval | string | `"15s"` | keepaliveInterval is the interval to keep alive with manager. |
| dragonfly.seedClient.config.seedPeer.type | string | `"super"` | type is the type of seed peer. |
| dragonfly.seedClient.config.stats.server.port | int | `4004` | port is the port to the stats server. |
| dragonfly.seedClient.config.storage.dir | string | `"/var/lib/dragonfly/"` | dir is the directory to store task's metadata and content. |
| dragonfly.seedClient.config.storage.keep | bool | `false` | keep indicates whether keep the task's metadata and content when the dfdaemon restarts. |
| dragonfly.seedClient.config.storage.readBufferSize | int | `131072` | readBufferSize is the buffer size for reading piece from disk, default is 128KB. |
| dragonfly.seedClient.config.storage.writeBufferSize | int | `131072` | writeBufferSize is the buffer size for writing piece to disk, default is 128KB. |
| dragonfly.seedClient.config.upload.rateLimit | int | `20000000000` | rateLimit is the default rate limit of the upload speed in bps(bytes per second), default is 20Gbps. |
| dragonfly.seedClient.config.upload.server.port | int | `4000` | port is the port to the grpc server. |
| dragonfly.seedClient.config.verbose | bool | `false` | verbose prints log. |
| dragonfly.seedClient.enable | bool | `true` | Enable seed client. |
| dragonfly.seedClient.extraVolumeMounts | list | `[{"mountPath":"/var/log/dragonfly/dfdaemon/","name":"logs"}]` | Extra volumeMounts for dfdaemon. |
| dragonfly.seedClient.extraVolumes | list | `[{"emptyDir":{},"name":"logs"}]` | Extra volumes for dfdaemon. |
| dragonfly.seedClient.fullnameOverride | string | `""` | Override scheduler fullname. |
| dragonfly.seedClient.hostAliases | list | `[]` | Host Aliases. |
| dragonfly.seedClient.image.digest | string | `""` | Image digest. |
| dragonfly.seedClient.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| dragonfly.seedClient.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| dragonfly.seedClient.image.registry | string | `"docker.io"` | Image registry. |
| dragonfly.seedClient.image.repository | string | `"dragonflyoss/client"` | Image repository. |
| dragonfly.seedClient.image.tag | string | `"v0.1.82"` | Image tag. |
| dragonfly.seedClient.initContainer.image.digest | string | `""` | Image digest. |
| dragonfly.seedClient.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| dragonfly.seedClient.initContainer.image.registry | string | `"docker.io"` | Image registry. |
| dragonfly.seedClient.initContainer.image.repository | string | `"busybox"` | Image repository. |
| dragonfly.seedClient.initContainer.image.tag | string | `"latest"` | Image tag. |
| dragonfly.seedClient.maxProcs | string | `""` | maxProcs Limits the number of operating system threads that can execute user-level. Go code simultaneously by setting GOMAXPROCS environment variable, refer to https://golang.org/pkg/runtime. |
| dragonfly.seedClient.metrics.enable | bool | `false` | Enable seed client metrics. |
| dragonfly.seedClient.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels. |
| dragonfly.seedClient.metrics.prometheusRule.enable | bool | `false` | Enable prometheus rule ref: https://github.com/coreos/prometheus-operator. |
| dragonfly.seedClient.metrics.prometheusRule.rules | list | `[{"alert":"SeedClientDown","annotations":{"message":"Seed client instance {{ \"{{ $labels.instance }}\" }} is down","summary":"Seed client instance is down"},"expr":"sum(dragonfly_client_version{container=\"seed-client\"}) == 0","for":"5m","labels":{"severity":"critical"}},{"alert":"SeedClientHighNumberOfFailedDownloadTask","annotations":{"message":"Seed client has a high number of failed download task","summary":"Seed client has a high number of failed download task"},"expr":"sum(irate(dragonfly_client_download_task_failure_total{container=\"seed-client\"}[1m])) > 100","for":"1m","labels":{"severity":"warning"}},{"alert":"SeedClientSuccessRateOfDownloadingTask","annotations":{"message":"Seed client's success rate of downloading task is low","summary":"Seed client's success rate of downloading task is low"},"expr":"(sum(rate(dragonfly_client_download_task_total{container=\"seed-client\"}[1m])) - sum(rate(dragonfly_client_download_task_failure_total{container=\"seed-client\"}[1m]))) / sum(rate(dragonfly_client_download_task_total{container=\"seed-client\"}[1m])) < 0.6","for":"5m","labels":{"severity":"critical"}}]` | Prometheus rules. |
| dragonfly.seedClient.metrics.service.annotations | object | `{}` | Service annotations. |
| dragonfly.seedClient.metrics.service.labels | object | `{}` | Service labels. |
| dragonfly.seedClient.metrics.service.type | string | `"ClusterIP"` | Service type. |
| dragonfly.seedClient.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels |
| dragonfly.seedClient.metrics.serviceMonitor.enable | bool | `false` | Enable prometheus service monitor. ref: https://github.com/coreos/prometheus-operator. |
| dragonfly.seedClient.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped. |
| dragonfly.seedClient.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended. |
| dragonfly.seedClient.name | string | `"seed-client"` | Seed client name. |
| dragonfly.seedClient.nameOverride | string | `""` | Override scheduler name. |
| dragonfly.seedClient.nodeSelector | object | `{}` | Node labels for pod assignment. |
| dragonfly.seedClient.persistence.accessModes | list | `["ReadWriteOnce"]` | Persistence access modes. |
| dragonfly.seedClient.persistence.annotations | object | `{}` | Persistence annotations. |
| dragonfly.seedClient.persistence.enable | bool | `true` | Enable persistence for seed peer. |
| dragonfly.seedClient.persistence.size | string | `"50Gi"` | Persistence persistence size. |
| dragonfly.seedClient.podAnnotations | object | `{}` | Pod annotations. |
| dragonfly.seedClient.podLabels | object | `{}` | Pod labels. |
| dragonfly.seedClient.priorityClassName | string | `""` | Pod priorityClassName. |
| dragonfly.seedClient.replicas | int | `3` | Number of Pods to launch. |
| dragonfly.seedClient.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits. |
| dragonfly.seedClient.service.annotations | object | `{}` | Service annotations. |
| dragonfly.seedClient.service.labels | object | `{}` | Service labels. |
| dragonfly.seedClient.service.type | string | `"ClusterIP"` | Service type. |
| dragonfly.seedClient.statefulsetAnnotations | object | `{}` | Statefulset annotations. |
| dragonfly.seedClient.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds. |
| dragonfly.seedClient.tolerations | list | `[]` | List of node taints to tolerate. |
| dragonfly.seedClient.updateStrategy | object | `{}` | Update strategy for replicas. |
| global.imagePullSecrets | list | `[]` | Global Docker registry secret names as an array. |
| global.imageRegistry | string | `""` | Global Docker image registry. |
| global.nodeSelector | object | `{}` | Global node labels for pod assignment. |
| global.storageClass | string | `""` | Global storageClass for Persistent Volume(s). |
| nydus-snapshotter.args | list | `[]` | Args to overwrite default nydus-snapshotter startup command |
| nydus-snapshotter.containerRuntime | object | `{"containerd":{"configFile":"/etc/containerd/config.toml","enable":false},"initContainer":{"image":{"pullPolicy":"Always","registry":"ghcr.io","repository":"liubin/toml-cli","tag":"v0.0.7"}}}` | [Experimental] Container runtime support Choose special container runtime in Kubernetes. Support: Containerd, Docker, CRI-O |
| nydus-snapshotter.containerRuntime.containerd | object | `{"configFile":"/etc/containerd/config.toml","enable":false}` | [Experimental] Containerd support |
| nydus-snapshotter.containerRuntime.containerd.configFile | string | `"/etc/containerd/config.toml"` | Custom config path directory, default is /etc/containerd/config.toml |
| nydus-snapshotter.containerRuntime.containerd.enable | bool | `false` | Enable containerd support Inject nydus-snapshotter config into ${containerRuntime.containerd.configFile}, |
| nydus-snapshotter.containerRuntime.initContainer.image.pullPolicy | string | `"Always"` | Image pull policy. |
| nydus-snapshotter.containerRuntime.initContainer.image.registry | string | `"ghcr.io"` | Image registry. |
| nydus-snapshotter.containerRuntime.initContainer.image.repository | string | `"liubin/toml-cli"` | Image repository. |
| nydus-snapshotter.containerRuntime.initContainer.image.tag | string | `"v0.0.7"` | Image tag. |
| nydus-snapshotter.daemonsetAnnotations | object | `{}` | Daemonset annotations |
| nydus-snapshotter.dragonfly.enable | bool | `true` | Enable dragonfly |
| nydus-snapshotter.dragonfly.mirrorConfig[0].auth_through | bool | `false` |  |
| nydus-snapshotter.dragonfly.mirrorConfig[0].headers.X-Dragonfly-Registry | string | `"https://index.docker.io"` |  |
| nydus-snapshotter.dragonfly.mirrorConfig[0].host | string | `"http://127.0.0.1:4001"` |  |
| nydus-snapshotter.dragonfly.mirrorConfig[0].ping_url | string | `"http://127.0.0.1:4003/healthy"` |  |
| nydus-snapshotter.enabled | bool | `true` |  |
| nydus-snapshotter.hostAliases | list | `[]` | Host Aliases |
| nydus-snapshotter.hostNetwork | bool | `true` | Let nydus-snapshotter run in host network |
| nydus-snapshotter.hostPid | bool | `true` | Let nydus-snapshotter use the host's pid namespace |
| nydus-snapshotter.image.pullPolicy | string | `"Always"` | Image pull policy. |
| nydus-snapshotter.image.pullSecrets | list | `[]` (defaults to global.imagePullSecrets). | Image pull secrets. |
| nydus-snapshotter.image.registry | string | `"ghcr.io"` | Image registry. |
| nydus-snapshotter.image.repository | string | `"containerd/nydus-snapshotter"` | Image repository. |
| nydus-snapshotter.image.tag | string | `"v0.9.0"` | Image tag. |
| nydus-snapshotter.name | string | `"nydus-snapshotter"` | nydus-snapshotter name |
| nydus-snapshotter.nodeSelector | object | `{}` | Node labels for pod assignment |
| nydus-snapshotter.podAnnotations | object | `{}` | Pod annotations |
| nydus-snapshotter.podLabels | object | `{}` | Pod labels |
| nydus-snapshotter.priorityClassName | string | `""` | Pod priorityClassName |
| nydus-snapshotter.resources | object | `{"limits":{"cpu":"2","memory":"2Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits |
| nydus-snapshotter.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds |
| nydus-snapshotter.tolerations | list | `[]` | List of node taints to tolerate |

## Chart dependencies

| Repository | Name | Version |
|------------|------|---------|
| https://dragonflyoss.github.io/helm-charts/ | dragonfly | 1.1.67 |
| https://dragonflyoss.github.io/helm-charts/ | nydus-snapshotter | 0.0.10 |
