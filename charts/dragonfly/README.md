# Dragonfly Helm Chart

Provide efficient, stable, secure, low-cost file and image distribution services to be the best practice and standard solution in the related Cloud-Native area.

## TL;DR

```bash
$ helm repo add dragonfly https://dragonflyoss.github.io/helm-charts/
$ helm install --create-namespace --namespace dragonfly-system my-release dragonfly/dragonfly
```

## Introduction

Dragonfly is an open source intelligent P2P based image and file distribution system. Its goal is to tackle all distribution problems in cloud native scenarios. Currently Dragonfly focuses on being:

- Simple: well-defined user-facing API (HTTP), non-invasive to all container engines;
- Efficient: CDN support, P2P based file distribution to save enterprise bandwidth;
- Intelligent: host level speed limit, intelligent flow control due to host detection;
- Secure: block transmission encryption, HTTPS connection support.

Dragonfly is now hosted by the Cloud Native Computing Foundation (CNCF) as an Incubating Level Project. Originally it was born to solve all kinds of distribution at very large scales, such as application distribution, cache distribution, log distribution, image distribution, and so on.

## Install

Install dragonfly chart with release name `my-release`:

```bash
$ helm repo add dragonfly https://dragonflyoss.github.io/helm-charts/
$ helm install --create-namespace --namespace dragonfly-system my-release dragonfly/dragonfly
```

## Uninstall

Uninstall the `my-release` deployment:

```bash
$ helm delete my-release
```

## Configuration

The following table lists the configurable parameters of the dragonfly chart, and their default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cdn.config.base.console | bool | `false` |  |
| cdn.config.base.enableProfiler | bool | `false` |  |
| cdn.config.base.failAccessInterval | string | `"3m"` |  |
| cdn.config.base.gcInitialDelay | string | `"6s"` |  |
| cdn.config.base.gcMetaInterval | string | `"2m"` |  |
| cdn.config.base.gcStorageInterval | string | `"15s"` |  |
| cdn.config.base.manager.cdnClusterID | int | `0` |  |
| cdn.config.base.manager.keepAlive.interval | string | `"5s"` |  |
| cdn.config.base.manager.keepAlive.retryInitBackOff | int | `5` |  |
| cdn.config.base.manager.keepAlive.retryMaxAttempts | int | `100000000` |  |
| cdn.config.base.manager.keepAlive.retryMaxBackOff | int | `10` |  |
| cdn.config.base.maxBandwidth | string | `"200M"` |  |
| cdn.config.base.storagePattern | string | `"disk"` |  |
| cdn.config.base.systemReservedBandwidth | string | `"20M"` |  |
| cdn.config.base.taskExpireTime | string | `"3m"` |  |
| cdn.config.plugins.storageDriver[0].config.baseDir | string | `"/tmp/cdn"` |  |
| cdn.config.plugins.storageDriver[0].enable | bool | `true` |  |
| cdn.config.plugins.storageDriver[0].name | string | `"disk"` |  |
| cdn.config.plugins.storageManager[0].config.driverConfigs.disk.gcConfig.cleanRatio | int | `1` |  |
| cdn.config.plugins.storageManager[0].config.driverConfigs.disk.gcConfig.fullGCThreshold | string | `"5G"` |  |
| cdn.config.plugins.storageManager[0].config.driverConfigs.disk.gcConfig.intervalThreshold | string | `"2h"` |  |
| cdn.config.plugins.storageManager[0].config.driverConfigs.disk.gcConfig.youngGCThreshold | string | `"100G"` |  |
| cdn.config.plugins.storageManager[0].config.gcInitialDelay | string | `"5s"` |  |
| cdn.config.plugins.storageManager[0].config.gcInterval | string | `"15s"` |  |
| cdn.config.plugins.storageManager[0].enable | bool | `true` |  |
| cdn.config.plugins.storageManager[0].name | string | `"disk"` |  |
| cdn.containerPort | int | `8003` |  |
| cdn.fullnameOverride | string | `""` |  |
| cdn.image | string | `"dragonflyoss/cdn"` |  |
| cdn.name | string | `"cdn"` |  |
| cdn.nameOverride | string | `""` |  |
| cdn.nginxContiainerPort | int | `8001` |  |
| cdn.nodeSelector | object | `{}` |  |
| cdn.podAnnotations | object | `{}` |  |
| cdn.podLabels | object | `{}` |  |
| cdn.priorityClassName | string | `""` |  |
| cdn.pullPolicy | string | `"IfNotPresent"` |  |
| cdn.replicas | int | `3` |  |
| cdn.resources.limits.cpu | string | `"4"` |  |
| cdn.resources.limits.memory | string | `"8Gi"` |  |
| cdn.resources.requests.cpu | string | `"0"` |  |
| cdn.resources.requests.memory | string | `"0"` |  |
| cdn.service.extraPorts[0].name | string | `"http-nginx"` |  |
| cdn.service.extraPorts[0].port | int | `8001` |  |
| cdn.service.extraPorts[0].targetPort | int | `8001` |  |
| cdn.service.port | int | `8003` |  |
| cdn.service.targetPort | int | `8003` |  |
| cdn.service.type | string | `"ClusterIP"` |  |
| cdn.statefulsetAnnotations | object | `{}` |  |
| cdn.tag | string | `"v0.1.0"` |  |
| cdn.terminationGracePeriodSeconds | string | `nil` |  |
| cdn.tolerations | list | `[]` |  |
| dfdaemon.config.aliveTime | string | `"0s"` |  |
| dfdaemon.config.download.downloadGRPC.security.insecure | bool | `true` |  |
| dfdaemon.config.download.downloadGRPC.unixListen.socket | string | `"/tmp/dfdamon.sock"` |  |
| dfdaemon.config.download.peerGRPC.security.insecure | bool | `true` |  |
| dfdaemon.config.download.peerGRPC.tcpListen.listen | string | `"0.0.0.0"` |  |
| dfdaemon.config.download.peerGRPC.tcpListen.port | int | `65000` |  |
| dfdaemon.config.download.rateLimit | string | `"200Mi"` |  |
| dfdaemon.config.gcInterval | string | `"1m0s"` |  |
| dfdaemon.config.host.advertiseIP | string | `"0.0.0.0"` |  |
| dfdaemon.config.host.listenIP | string | `"0.0.0.0"` |  |
| dfdaemon.config.jaeger | string | `""` |  |
| dfdaemon.config.keepStorage | bool | `false` |  |
| dfdaemon.config.proxy.defaultFilter | string | `"Expires&Signature"` |  |
| dfdaemon.config.proxy.proxies[0].regx | string | `"blobs/sha256.*"` |  |
| dfdaemon.config.proxy.registryMirror.dynamic | bool | `true` |  |
| dfdaemon.config.proxy.registryMirror.url | string | `"https://index.docker.io"` |  |
| dfdaemon.config.proxy.security.insecure | bool | `true` |  |
| dfdaemon.config.proxy.tcpListen.listen | string | `"0.0.0.0"` |  |
| dfdaemon.config.proxy.tcpListen.namespace | string | `"/run/dragonfly/net"` |  |
| dfdaemon.config.storage.multiplex | bool | `true` |  |
| dfdaemon.config.storage.strategy | string | `"io.d7y.storage.v2.simple"` |  |
| dfdaemon.config.storage.taskExpireTime | string | `"3m0s"` |  |
| dfdaemon.config.upload.rateLimit | string | `"100Mi"` |  |
| dfdaemon.config.upload.security.insecure | bool | `true` |  |
| dfdaemon.config.upload.tcpListen.listen | string | `"0.0.0.0"` |  |
| dfdaemon.config.upload.tcpListen.port | int | `65002` |  |
| dfdaemon.config.verbose | bool | `true` |  |
| dfdaemon.containerPort | int | `65001` |  |
| dfdaemon.daemonsetAnnotations | object | `{}` |  |
| dfdaemon.fullnameOverride | string | `""` |  |
| dfdaemon.hostNetwork | bool | `false` |  |
| dfdaemon.hostPort | int | `65001` |  |
| dfdaemon.image | string | `"dragonflyoss/dfdaemon"` |  |
| dfdaemon.name | string | `"dfdaemon"` |  |
| dfdaemon.nameOverride | string | `""` |  |
| dfdaemon.nodeSelector | object | `{}` |  |
| dfdaemon.podAnnotations | object | `{}` |  |
| dfdaemon.podLabels | object | `{}` |  |
| dfdaemon.priorityClassName | string | `""` |  |
| dfdaemon.pullPolicy | string | `"IfNotPresent"` |  |
| dfdaemon.resources.limits.cpu | string | `"2"` |  |
| dfdaemon.resources.limits.memory | string | `"2Gi"` |  |
| dfdaemon.resources.requests.cpu | string | `"0"` |  |
| dfdaemon.resources.requests.memory | string | `"0"` |  |
| dfdaemon.tag | string | `"v0.1.0"` |  |
| dfdaemon.terminationGracePeriodSeconds | string | `nil` |  |
| dfdaemon.tolerations | list | `[]` |  |
| fullnameOverride | string | `""` | Override dragonfly fullname |
| installation | object | `{"clusterDomain":"","jaeger":false}` | Values for dragonfly installation |
| installation.jaeger | bool | `false` | Enable an all in one jaeger for tracing every downloading event should not use in production environment |
| manager.fullnameOverride | string | `""` |  |
| manager.grpcPort | int | `65003` |  |
| manager.image | string | `"dragonflyoss/manager"` |  |
| manager.name | string | `"manager"` |  |
| manager.nameOverride | string | `""` |  |
| manager.nodeSelector | object | `{}` |  |
| manager.podAnnotations | object | `{}` |  |
| manager.podLabels | object | `{}` |  |
| manager.priorityClassName | string | `""` |  |
| manager.pullPolicy | string | `"IfNotPresent"` |  |
| manager.replicas | int | `3` |  |
| manager.resources.limits.cpu | string | `"2"` |  |
| manager.resources.limits.memory | string | `"4Gi"` |  |
| manager.resources.requests.cpu | string | `"0"` |  |
| manager.resources.requests.memory | string | `"0"` |  |
| manager.restPort | int | `8080` |  |
| manager.serviceAnnotations | object | `{}` |  |
| manager.statefulsetAnnotations | object | `{}` |  |
| manager.tag | string | `"v0.1.0"` |  |
| manager.terminationGracePeriodSeconds | string | `nil` |  |
| manager.tolerations | list | `[]` |  |
| mysql.auth.database | string | `"manager"` |  |
| mysql.auth.password | string | `"dragonfly"` |  |
| mysql.auth.rootPassword | string | `"dragonfly-root"` |  |
| mysql.auth.username | string | `"dragonfly"` |  |
| mysql.enable | bool | `true` |  |
| mysql.migrate | bool | `true` |  |
| mysql.primary.service.port | int | `3306` |  |
| nameOverride | string | `""` | Override dragonfly system name |
| namespaceOverride | string | `"dragonfly-system"` | Override dragonfly system namespace |
| redis.enable | bool | `true` |  |
| redis.password | string | `"dragonfly"` |  |
| redis.service.port | int | `6379` |  |
| scheduler.config.debug | bool | `false` |  |
| scheduler.config.dynconfig.type | string | `"manager"` |  |
| scheduler.config.manager.keepAlive.interval | string | `"5s"` |  |
| scheduler.config.manager.keepAlive.retryInitBackOff | int | `5` |  |
| scheduler.config.manager.keepAlive.retryMaxAttempts | int | `100000000` |  |
| scheduler.config.manager.keepAlive.retryMaxBackOff | int | `10` |  |
| scheduler.config.manager.schedulerClusterID | int | `0` |  |
| scheduler.config.worker.senderJobPoolSize | int | `10000` |  |
| scheduler.config.worker.senderNum | int | `10` |  |
| scheduler.config.worker.workerJobPoolSize | int | `10000` |  |
| scheduler.config.worker.workerNum | int | `4` |  |
| scheduler.containerPort | int | `8002` |  |
| scheduler.fullnameOverride | string | `""` |  |
| scheduler.image | string | `"dragonflyoss/scheduler"` |  |
| scheduler.name | string | `"scheduler"` |  |
| scheduler.nameOverride | string | `""` |  |
| scheduler.nodeSelector | object | `{}` |  |
| scheduler.podAnnotations | object | `{}` |  |
| scheduler.podLabels | object | `{}` |  |
| scheduler.priorityClassName | string | `""` |  |
| scheduler.pullPolicy | string | `"IfNotPresent"` |  |
| scheduler.replicas | int | `3` |  |
| scheduler.resources.limits.cpu | string | `"4"` |  |
| scheduler.resources.limits.memory | string | `"8Gi"` |  |
| scheduler.resources.requests.cpu | string | `"0"` |  |
| scheduler.resources.requests.memory | string | `"0"` |  |
| scheduler.service.port | int | `8002` |  |
| scheduler.service.targetPort | int | `8002` |  |
| scheduler.service.type | string | `"ClusterIP"` |  |
| scheduler.serviceAnnotations | object | `{}` |  |
| scheduler.statefulsetAnnotations | object | `{}` |  |
| scheduler.tag | string | `"v0.1.0"` |  |
| scheduler.terminationGracePeriodSeconds | string | `nil` |  |
| scheduler.tolerations | list | `[]` |  |

## Chart dependencies

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | mysql | 8.0.0 |
| https://charts.bitnami.com/bitnami | redis-cluster | 5.0.0 |
