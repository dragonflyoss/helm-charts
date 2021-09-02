# Dragonfly Helm Chart

![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.3.0](https://img.shields.io/badge/AppVersion-0.3.0-informational?style=flat-square)

Provide efficient, stable, secure, low-cost file and image distribution services to be the best practice and standard solution in the related Cloud-Native area.

## TL;DR

```shell
helm repo add dragonfly https://dragonflyoss.github.io/helm-charts/
helm install --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly
```

## Introduction

Dragonfly is an open source intelligent P2P based image and file distribution system. Its goal is to tackle all distribution problems in cloud native scenarios. Currently Dragonfly focuses on being:

- Simple: well-defined user-facing API (HTTP), non-invasive to all container engines;
- Efficient: CDN support, P2P based file distribution to save enterprise bandwidth;
- Intelligent: host level speed limit, intelligent flow control due to host detection;
- Secure: block transmission encryption, HTTPS connection support.

Dragonfly is now hosted by the Cloud Native Computing Foundation (CNCF) as an Incubating Level Project. Originally it was born to solve all kinds of distribution at very large scales, such as application distribution, cache distribution, log distribution, image distribution, and so on.

## Install

### Install with custom configuration

Create the `values.yaml` configuration file. It is recommended to use external redis and mysql instead of containers. This example uses external mysql and redis.

```yaml
mysql:
  enable: false
  auth:
    host: mysql-host
    username: dragonfly
    password: dragonfly
    database: manager
  primary:
    service:
      port: 3306

redis:
  enable: false
  host: redis-host
  password: dragonfly
  service:
    port: 6379
```

Install dragonfly chart with release name `dragonfly`:

```shell
helm repo add dragonfly https://dragonflyoss.github.io/helm-charts/
helm install --create-namespace --namespace dragonfly-system dragonfly dragonfly/dragonfly -f values.yaml
```

### Install with an existing manager

Create the `values.yaml` configuration file. Need to configure the cluster id associated with scheduler and cdn. This example is to deploy a cluster using the existing manager and redis.

```yaml
scheduler:
  config:
    manager:
      schedulerClusterID: 1

cdn:
  config:
    base:
      manager:
        cdnClusterID: 1

externalManager:
  enable: true
  host: "dragonfly-manager.dragonfly-system.svc.cluster.local"
  restPort: 8080
  grpcPort: 65003

redis:
  enable: false
  host: redis-host
  password: dragonfly
  service:
    port: 6379

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
helm delete dragonfly
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cdn.config.base.enableProfiler | bool | `false` | Enable profiler for data |
| cdn.config.base.failAccessInterval | string | `"3m"` | Interval time after failed to access the URL |
| cdn.config.base.gcInitialDelay | string | `"6s"` | Delay time from the start to the first GC execution |
| cdn.config.base.gcMetaInterval | string | `"2m"` | Interval time to execute GC meta |
| cdn.config.base.gcStorageInterval | string | `"15s"` | Interval time to execute GC storage |
| cdn.config.base.manager.cdnClusterID | int | `1` | Associated cdn cluster id |
| cdn.config.base.manager.keepAlive.interval | string | `"5s"` | Manager keepalive interval |
| cdn.config.base.maxBandwidth | string | `"200M"` | Network bandwidth that cdn can use |
| cdn.config.base.storagePattern | string | `"disk"` | Pattern of storage policy |
| cdn.config.base.systemReservedBandwidth | string | `"20M"` | Network bandwidth reserved for system software |
| cdn.config.base.taskExpireTime | string | `"3m"` | When a task is not accessed within the taskExpireTime and it will be treated to be expired |
| cdn.config.plugins.storageDriver | list | `[{"config":{"baseDir":"/tmp/cdn"},"enable":true,"name":"disk"}]` | Storage driver configuration |
| cdn.config.plugins.storageManager | list | `[{"config":{"driverConfigs":{"disk":{"gcConfig":{"cleanRatio":1,"fullGCThreshold":"5G","intervalThreshold":"2h","youngGCThreshold":"100G"}}},"gcInitialDelay":"5s","gcInterval":"15s"},"enable":true,"name":"disk"}]` | Storage manager configuration |
| cdn.containerPort | int | `8003` | Pod containerPort |
| cdn.enable | bool | `true` | Enable cdn |
| cdn.fullnameOverride | string | `""` | Override scheduler fullname |
| cdn.image | string | `"dragonflyoss/cdn"` | Image repository |
| cdn.name | string | `"cdn"` | CDN name |
| cdn.nameOverride | string | `""` | Override scheduler name |
| cdn.nginxContiainerPort | int | `8001` | Nginx containerPort for downloading |
| cdn.nodeSelector | object | `{}` | Node labels for pod assignment |
| cdn.persistence.accessModes | list | `["ReadWriteOnce"]` | Persistence access modes |
| cdn.persistence.annotations | object | `{}` | Persistence annotations |
| cdn.persistence.enabled | bool | `true` | Enable persistence for cdn |
| cdn.persistence.size | string | `"8Gi"` | Persistence persistence size |
| cdn.podAnnotations | object | `{}` | Pod annotations |
| cdn.podLabels | object | `{}` | Pod labels |
| cdn.priorityClassName | string | `""` | Pod priorityClassName |
| cdn.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| cdn.replicas | int | `3` | Number of Pods to launch |
| cdn.resources | object | `{"limits":{"cpu":"4","memory":"8Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits |
| cdn.service | object | `{"extraPorts":[{"name":"http-nginx","port":8001,"targetPort":8001}],"port":8003,"targetPort":8003,"type":"ClusterIP"}` | Service configuration |
| cdn.statefulsetAnnotations | object | `{}` | Statefulset annotations |
| cdn.tag | string | `"v0.3.0"` | Image tag |
| cdn.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds |
| cdn.tolerations | list | `[]` | List of node taints to tolerate |
| clusterDomain | string | `"cluster.local"` | Install application cluster domain |
| dfdaemon.config.aliveTime | string | `"0s"` | Daemon alive time, when sets 0s, daemon will not auto exit, it is useful for longtime running |
| dfdaemon.config.download.downloadGRPC.security | object | `{"insecure":true}` | Download grpc security option |
| dfdaemon.config.download.downloadGRPC.unixListen | object | `{"socket":"/tmp/dfdamon.sock"}` | Download service listen address current, only support unix domain socket |
| dfdaemon.config.download.peerGRPC.security | object | `{"insecure":true}` | Peer grpc security option |
| dfdaemon.config.download.peerGRPC.tcpListen.listen | string | `"0.0.0.0"` | Listen address |
| dfdaemon.config.download.peerGRPC.tcpListen.port | int | `65000` | Listen port |
| dfdaemon.config.download.rateLimit | string | `"200Mi"` | Download limit per second |
| dfdaemon.config.gcInterval | string | `"1m0s"` | Daemon gc task running interval |
| dfdaemon.config.host.advertiseIP | string | `"0.0.0.0"` | Access ip for other peers when local ip is different with access ip, advertiseIP should be set |
| dfdaemon.config.host.listenIP | string | `"0.0.0.0"` | TCP service listen address port should be set by other options |
| dfdaemon.config.jaeger | string | `""` | Jaeger url, like: http://jaeger.dragonfly.svc:14268 |
| dfdaemon.config.keepStorage | bool | `false` | When daemon exit, keep peer task data or not it is usefully when upgrade daemon service, all local cache will be saved default is false |
| dfdaemon.config.proxy.defaultFilter | string | `"Expires&Signature"` | Filter for hash url when defaultFilter: "Expires&Signature", for example:  http://localhost/xyz?Expires=111&Signature=222 and http://localhost/xyz?Expires=333&Signature=999 is same task |
| dfdaemon.config.proxy.proxies[0] | object | `{"regx":"blobs/sha256.*"}` | Proxy all http image layer download requests with dfget |
| dfdaemon.config.proxy.registryMirror.dynamic | bool | `true` | When enable, using header "X-Dragonfly-Registry" for remote instead of url |
| dfdaemon.config.proxy.registryMirror.url | string | `"https://index.docker.io"` | URL for the registry mirror |
| dfdaemon.config.proxy.security | object | `{"insecure":true}` | Proxy security option |
| dfdaemon.config.proxy.tcpListen.listen | string | `"0.0.0.0"` | Listen address |
| dfdaemon.config.proxy.tcpListen.namespace | string | `"/run/dragonfly/net"` | Namespace stands the linux net namespace, like /proc/1/ns/net it's useful for running daemon in pod with ip allocated and listening the special port in host net namespace Linux only |
| dfdaemon.config.storage.multiplex | bool | `true` | Set to ture for reusing underlying storage for same task id |
| dfdaemon.config.storage.strategy | string | `"io.d7y.storage.v2.simple"` | Storage strategy when process task data io.d7y.storage.v2.simple : download file to data directory first, then copy to output path, this is default action                           the download file in date directory will be the peer data for uploading to other peers io.d7y.storage.v2.advance: download file directly to output path with postfix, hard link to final output,                            avoid copy to output path, fast than simple strategy, but:                            the output file with postfix will be the peer data for uploading to other peers                            when user delete or change this file, this peer data will be corrupted default is io.d7y.storage.v2.advance |
| dfdaemon.config.storage.taskExpireTime | string | `"3m0s"` | Task data expire time when there is no access to a task data, this task will be gc. |
| dfdaemon.config.upload.rateLimit | string | `"100Mi"` | Upload limit per second |
| dfdaemon.config.upload.security | object | `{"insecure":true}` | Upload grpc security option |
| dfdaemon.config.upload.tcpListen.listen | string | `"0.0.0.0"` | Listen address |
| dfdaemon.config.upload.tcpListen.port | int | `65002` | Listen port |
| dfdaemon.config.verbose | bool | `true` | When enable, pprof will be enabled |
| dfdaemon.containerPort | int | `65001` | Pod containerPort |
| dfdaemon.daemonsetAnnotations | object | `{}` | Daemonset annotations |
| dfdaemon.enable | bool | `true` | Enable dfdaemon |
| dfdaemon.fullnameOverride | string | `""` | Override dfdaemon fullname |
| dfdaemon.hostNetwork | bool | `false` | Using hostNetwork when pod with host network can communicate with normal pods with cni network |
| dfdaemon.hostPort | int | `65001` | When .hostNetwork == false, and .config.proxy.tcpListen.namespace is empty many network add-ons do not yet support hostPort https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/#hostport-services-do-not-work by default, dfdaemon injects the 65001 port to host network by sharing host network namespace, if you want to use hostPort, please empty .config.proxy.tcpListen.namespace below, and keep .hostNetwork == false for performance, injecting the 65001 port to host network is better than hostPort |
| dfdaemon.image | string | `"dragonflyoss/dfdaemon"` | Image repository |
| dfdaemon.name | string | `"dfdaemon"` | Dfdaemon name |
| dfdaemon.nameOverride | string | `""` | Override dfdaemon name |
| dfdaemon.nodeSelector | object | `{}` | Node labels for pod assignment |
| dfdaemon.podAnnotations | object | `{}` | Pod annotations |
| dfdaemon.podLabels | object | `{}` | Pod labels |
| dfdaemon.priorityClassName | string | `""` | Pod priorityClassName |
| dfdaemon.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| dfdaemon.resources | object | `{"limits":{"cpu":"2","memory":"2Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits |
| dfdaemon.tag | string | `"v0.3.0"` | Image tag |
| dfdaemon.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds |
| dfdaemon.tolerations | list | `[]` | List of node taints to tolerate |
| externalManager.grpcPort | int | `65003` | GRPC service port |
| externalManager.host | string | `nil` | Manager hostname |
| externalManager.restPort | int | `8080` | REST service port |
| externalMysql.database | string | `"manager"` | Mysql database name |
| externalMysql.host | string | `nil` | Mysql hostname |
| externalMysql.migrate | bool | `true` | Running GORM migration |
| externalMysql.password | string | `"dragonfly"` | Mysql password |
| externalMysql.port | int | `3306` | Mysql port |
| externalMysql.username | string | `"dragonfly"` | Mysql username |
| externalRedis.host | string | `""` | Redis hostname |
| externalRedis.password | string | `"dragonfly"` | Redis password |
| externalRedis.port | int | `6379` | Redis port |
| fullnameOverride | string | `""` | Override dragonfly fullname |
| jaeger.enable | bool | `false` | Enable an all in one jaeger for tracing every downloading event should not use in production environment |
| manager.deploymentAnnotations | object | `{}` | Deployment annotations |
| manager.enable | bool | `true` | Enable manager |
| manager.fullnameOverride | string | `""` | Override manager fullname |
| manager.grpcPort | int | `65003` | GRPC service port |
| manager.image | string | `"dragonflyoss/manager"` | Image repository |
| manager.ingress.annotations | object | `{}` | Ingress annotations |
| manager.ingress.enabled | bool | `false` | Enable ingress |
| manager.ingress.hosts | list | `[]` | Manager ingress hosts |
| manager.ingress.path | string | `"/"` | Ingress host path |
| manager.ingress.tls | list | `[]` | Ingress TLS configuration |
| manager.name | string | `"manager"` | Manager name |
| manager.nameOverride | string | `""` | Override manager name |
| manager.nodeSelector | object | `{}` | Node labels for pod assignment |
| manager.podAnnotations | object | `{}` | Pod annotations |
| manager.podLabels | object | `{}` | Pod labels |
| manager.priorityClassName | string | `""` | Pod priorityClassName |
| manager.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| manager.replicas | int | `3` | Number of Pods to launch |
| manager.resources | object | `{"limits":{"cpu":"2","memory":"4Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits |
| manager.restPort | int | `8080` | REST service port |
| manager.serviceAnnotations | object | `{}` | Service annotations |
| manager.tag | string | `"v0.3.0"` | Image tag |
| manager.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds |
| manager.tolerations | list | `[]` | List of node taints to tolerate |
| mysql.auth.database | string | `"manager"` | Mysql database name |
| mysql.auth.host | string | `""` | Mysql hostname |
| mysql.auth.password | string | `"dragonfly"` | Mysql password |
| mysql.auth.rootPassword | string | `"dragonfly-root"` | Mysql root password |
| mysql.auth.username | string | `"dragonfly"` | Mysql username |
| mysql.clusterDomain | string | `"cluster.local"` | Cluster domain |
| mysql.enable | bool | `true` | Enable mysql with docker container. |
| mysql.migrate | bool | `true` | Running GORM migration |
| mysql.primary.service.port | int | `3306` | Mysql port |
| nameOverride | string | `""` | Override dragonfly name |
| redis.clusterDomain | string | `"cluster.local"` | Cluster domain |
| redis.enable | bool | `true` | Enable redis cluster with docker container |
| redis.host | string | `""` | Redis hostname |
| redis.password | string | `"dragonfly"` | Redis password |
| redis.service.port | int | `6379` | Redis port |
| redis.usePassword | bool | `true` | Use password authentication |
| scheduler.config.debug | bool | `false` | Enable debug mode |
| scheduler.config.dynconfig.type | string | `"manager"` | Dynamic configuration pull source, pull from manager service by default |
| scheduler.config.manager.keepAlive.interval | string | `"5s"` | Manager keepalive interval |
| scheduler.config.manager.schedulerClusterID | int | `1` | Associated scheduler cluster id |
| scheduler.config.worker | object | `{"senderJobPoolSize":10000,"senderNum":10,"workerJobPoolSize":10000,"workerNum":4}` | Scheduling queue configuration |
| scheduler.containerPort | int | `8002` | Pod containerPort |
| scheduler.enable | bool | `true` | Enable scheduler |
| scheduler.fullnameOverride | string | `""` | Override scheduler fullname |
| scheduler.image | string | `"dragonflyoss/scheduler"` | Image repository |
| scheduler.name | string | `"scheduler"` | Scheduler name |
| scheduler.nameOverride | string | `""` | Override scheduler name |
| scheduler.nodeSelector | object | `{}` | Node labels for pod assignment |
| scheduler.podAnnotations | object | `{}` | Pod annotations |
| scheduler.podLabels | object | `{}` | Pod labels |
| scheduler.priorityClassName | string | `""` | Pod priorityClassName |
| scheduler.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| scheduler.replicas | int | `3` | Number of Pods to launch |
| scheduler.resources | object | `{"limits":{"cpu":"4","memory":"8Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits |
| scheduler.service | object | `{"port":8002,"targetPort":8002,"type":"ClusterIP"}` | Service configuration |
| scheduler.serviceAnnotations | object | `{}` | Service annotations |
| scheduler.statefulsetAnnotations | object | `{}` | Statefulset annotations |
| scheduler.tag | string | `"v0.3.0"` | Image tag |
| scheduler.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds |
| scheduler.tolerations | list | `[]` | List of node taints to tolerate |

## Chart dependencies

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | mysql | 8.0.0 |
| https://charts.bitnami.com/bitnami | redis | 12.1.0 |
