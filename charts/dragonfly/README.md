# Dragonfly Helm Chart

![Version: 0.5.19](https://img.shields.io/badge/Version-0.5.19-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.5.19](https://img.shields.io/badge/AppVersion-0.5.19-informational?style=flat-square)

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

## Installation Guide

When use Dragonfly in Kubernetes, a container runtime must be configured. These work can be done by init script in this charts.

For more detail about installation is available in [Kubernetes with Dragonfly](https://github.com/dragonflyoss/Dragonfly2/blob/main/docs/en/ecosystem/Kubernetes-with-Dragonfly.md)

We recommend read the details about [Kubernetes with Dragonfly](https://github.com/dragonflyoss/Dragonfly2/blob/main/docs/en/ecosystem/Kubernetes-with-Dragonfly.md) before install.

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
  host: redis-host
  password: dragonfly
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
  host: redis-host
  password: dragonfly
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
helm delete dragonfly --namespace dragonfly-system
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
| cdn.config.jaeger | string | `""` | Jaeger url, like: http://jaeger.dragonfly.svc:14268/api/traces |
| cdn.config.plugins.storageDriver | list | `[{"config":{"baseDir":"/tmp/cdn"},"enable":true,"name":"disk"}]` | Storage driver configuration |
| cdn.config.plugins.storageManager | list | `[{"config":{"driverConfigs":{"disk":{"gcConfig":{"cleanRatio":1,"fullGCThreshold":"5G","intervalThreshold":"2h","youngGCThreshold":"100G"}}},"gcInitialDelay":"5s","gcInterval":"15s"},"enable":true,"name":"disk"}]` | Storage manager configuration |
| cdn.containerPort | int | `8003` | Pod containerPort |
| cdn.enable | bool | `true` | Enable cdn |
| cdn.extraVolumeMounts | list | `[{"mountPath":"/var/log/dragonfly/cdn","name":"logs"}]` | Extra volumeMounts for cdn. |
| cdn.extraVolumes | list | `[{"emptyDir":{},"name":"logs"}]` | Extra volumes for cdn. |
| cdn.fullnameOverride | string | `""` | Override scheduler fullname |
| cdn.hostAliases | list | `[]` | Host Aliases |
| cdn.image | string | `"dragonflyoss/cdn"` | Image repository |
| cdn.initContainer.image | string | `"busybox"` | Init container image repository |
| cdn.initContainer.pullPolicy | string | `"IfNotPresent"` | Container image pull policy |
| cdn.initContainer.tag | string | `"latest"` | Init container image tag |
| cdn.metrics.enable | bool | `false` | Enable manager metrics |
| cdn.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels |
| cdn.metrics.prometheusRule.enable | bool | `false` | Enable prometheus rule ref: https://github.com/coreos/prometheus-operator |
| cdn.metrics.prometheusRule.rules | list | `[]` | Prometheus rules |
| cdn.metrics.service.annotations | object | `{}` | Service annotations |
| cdn.metrics.service.labels | object | `{}` | Service labels |
| cdn.metrics.service.type | string | `"ClusterIP"` | Service type |
| cdn.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels |
| cdn.metrics.serviceMonitor.enable | bool | `false` | Enable prometheus service monitor ref: https://github.com/coreos/prometheus-operator |
| cdn.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped |
| cdn.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended |
| cdn.name | string | `"cdn"` | CDN name |
| cdn.nameOverride | string | `""` | Override scheduler name |
| cdn.nginxContiainerPort | int | `8001` | Nginx containerPort for downloading |
| cdn.nodeSelector | object | `{}` | Node labels for pod assignment |
| cdn.persistence.accessModes | list | `["ReadWriteOnce"]` | Persistence access modes |
| cdn.persistence.annotations | object | `{}` | Persistence annotations |
| cdn.persistence.enable | bool | `true` | Enable persistence for cdn |
| cdn.persistence.size | string | `"8Gi"` | Persistence persistence size |
| cdn.podAnnotations | object | `{}` | Pod annotations |
| cdn.podLabels | object | `{}` | Pod labels |
| cdn.priorityClassName | string | `""` | Pod priorityClassName |
| cdn.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| cdn.replicas | int | `3` | Number of Pods to launch |
| cdn.resources | object | `{"limits":{"cpu":"4","memory":"8Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits |
| cdn.service | object | `{"extraPorts":[{"name":"http-nginx","port":8001,"targetPort":8001}],"port":8003,"targetPort":8003,"type":"ClusterIP"}` | Service configuration |
| cdn.statefulsetAnnotations | object | `{}` | Statefulset annotations |
| cdn.tag | string | `"v2.0.1-beta.2"` | Image tag |
| cdn.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds |
| cdn.tolerations | list | `[]` | List of node taints to tolerate |
| clusterDomain | string | `"cluster.local"` | Install application cluster domain |
| containerRuntime | object | `{"containerd":{"enable":false,"injectConfigPath":false,"registries":["https://ghcr.io","https://quay.io","https://harbor.example.com:8443"]},"crio":{"enable":false,"registries":["https://ghcr.io","https://quay.io","https://harbor.example.com:8443"]},"docker":{"caCert":{"commonName":"Dragonfly Authority CA","countryName":"CN","localityName":"Hangzhou","organizationName":"Dragonfly","stateOrProvinceName":"Hangzhou"},"enable":false,"injectHosts":true,"insecure":false,"registryDomains":["ghcr.io","quay.io"],"registryPorts":[443],"restart":false,"skipHosts":["127.0.0.1","docker.io"]},"initContainerImage":"dragonflyoss/openssl"}` | [Experimental] Container runtime support Choose special container runtime in Kubernetes. Support: Containerd, Docker |
| containerRuntime.containerd | object | `{"enable":false,"injectConfigPath":false,"registries":["https://ghcr.io","https://quay.io","https://harbor.example.com:8443"]}` | [Experimental] Containerd support |
| containerRuntime.containerd.enable | bool | `false` | Enable containerd support Inject mirror config into /etc/containerd/config.toml, if config_path is enabled in /etc/containerd/config.toml, the config take effect real time, but if config_path is not enabled in /etc/containerd/config.toml, need restart containerd to take effect. When the version in /etc/containerd/config.toml is "1", inject dfdaemon.config.proxy.registryMirror.url as registry mirror and restart containerd. When the version in /etc/containerd/config.toml is "2":   1. when config_path is enabled in /etc/containerd/config.toml, inject containerRuntime.containerd.registries into config_path,   2. when containerRuntime.containerd.injectConfigPath=true, inject config_path into /etc/containerd/config.toml and inject containerRuntime.containerd.registries into config_path,   3. when not config_path in /etc/containerd/config.toml and containerRuntime.containerd.injectConfigPath=false, inject dfdaemon.config.proxy.registryMirror.url as registry mirror and restart containerd. |
| containerRuntime.containerd.injectConfigPath | bool | `false` | Config path for multiple registries By default, init container will check /etc/containerd/config.toml, whether is config_path configured, if not, init container will just add the dfdaemon.config.proxy.registryMirror.url for registry mirror. When configPath is true, init container will inject config_path=/etc/containerd/certs.d and configure all registries. |
| containerRuntime.crio | object | `{"enable":false,"registries":["https://ghcr.io","https://quay.io","https://harbor.example.com:8443"]}` | [Experimental] CRI-O support |
| containerRuntime.crio.enable | bool | `false` | Enable CRI-O support Inject drop-in mirror config into /etc/containers/registries.conf.d. |
| containerRuntime.docker | object | `{"caCert":{"commonName":"Dragonfly Authority CA","countryName":"CN","localityName":"Hangzhou","organizationName":"Dragonfly","stateOrProvinceName":"Hangzhou"},"enable":false,"injectHosts":true,"insecure":false,"registryDomains":["ghcr.io","quay.io"],"registryPorts":[443],"restart":false,"skipHosts":["127.0.0.1","docker.io"]}` | [Experimental] Support docker, when use docker-shim in Kubernetes, please set containerRuntime.docker.enable to true. For supporting docker, we need generate CA and update certs, then hijack registries traffic, By default, it's unnecessary to restart docker daemon when pull image from private registries, this feature is support explicit registries in containerRuntime.registry.domains, default domains is ghcr.io, quay.io, please update your registries by --set containerRuntime.registry.domains='{harbor.example.com,harbor.example.net}' --set containerRuntime.registry.injectHosts=true --set containerRuntime.docker.enable=true Caution:   **We did not recommend to using dragonfly with docker in Kubernetes** due to many reasons: 1. no fallback image pulling policy. 2. deprecated in Kubernetes.   Because the original `daemonset` in Kubernetes did not support `Surging Rolling Update` policy.   When kill current dfdaemon pod, the new pod image can not be pulled anymore.   If you can not change runtime from docker to others, remind to choose a plan when upgrade dfdaemon:     Option 1: pull newly dfdaemon image manually before upgrade dragonfly, or use [ImagePullJob](https://openkruise.io/docs/user-manuals/imagepulljob) to pull image automate.     Option 2: keep the image registry of dragonfly is different from common registries and add host in `containerRuntime.docker.skipHosts`. Caution: docker hub image is not supported without restart docker daemon. When need pull image from docker hub or any other registries not in containerRuntime.registry.domains, set containerRuntime.docker.restart=true this feature will inject proxy config into docker.service and restart docker daemon. Caution: set restart to true only when live restore is enable. Requirement: Docker Engine v1.2.0+ without Rootless. |
| containerRuntime.docker.caCert | object | `{"commonName":"Dragonfly Authority CA","countryName":"CN","localityName":"Hangzhou","organizationName":"Dragonfly","stateOrProvinceName":"Hangzhou"}` | CA cert info for generating |
| containerRuntime.docker.enable | bool | `false` | Enable docker support Inject ca cert into /etc/docker/certs.d/, Refer: https://docs.docker.com/engine/security/certificates/. |
| containerRuntime.docker.injectHosts | bool | `true` | Inject domains into /etc/hosts to force redirect traffic to dfdaemon. Caution: This feature need dfdaemon to implement SNI Proxy, confirm image tag is greater than or equal to v2.0.0. When use certs and inject hosts in docker, no necessary to restart docker daemon. |
| containerRuntime.docker.insecure | bool | `false` | Skip verify remote tls cert in dfdaemon If registry cert is private or self-signed, set to true. Caution: this option is test only. When deploy in production, should not skip verify tls cert. |
| containerRuntime.docker.registryDomains | list | `["ghcr.io","quay.io"]` | Registry domains By default, docker pull image via https, currently, by default 443 port with https. If not standard port, update registryPorts. |
| containerRuntime.docker.registryPorts | list | `[443]` | Registry ports |
| containerRuntime.docker.restart | bool | `false` | Restart docker daemon to redirect traffic to dfdaemon When containerRuntime.docker.restart=true, containerRuntime.docker.injectHosts and containerRuntime.registry.domains is ignored. If did not want restart docker daemon, keep containerRuntime.docker.restart=false and containerRuntime.docker.injectHosts=true. |
| containerRuntime.docker.skipHosts | list | `["127.0.0.1","docker.io"]` | Skip hosts Some traffic did not redirect to dragonfly, like 127.0.0.1, and the image registries of dragonfly itself. The format likes NO_PROXY in golang, refer: https://github.com/golang/net/blob/release-branch.go1.15/http/httpproxy/proxy.go#L39. Caution: Some registries use s3 or oss for backend storage, when add registries to skipHosts,   don't forget add the corresponding backend storage. |
| containerRuntime.initContainerImage | string | `"dragonflyoss/openssl"` | The image name of init container, need include openssl for ca generating |
| dfdaemon.config.aliveTime | string | `"0s"` | Daemon alive time, when sets 0s, daemon will not auto exit, it is useful for longtime running |
| dfdaemon.config.dataDir | string | `"/root/.dragonfly/dfget-daemon/"` | Data directory |
| dfdaemon.config.download.calculateDigest | bool | `true` | Calculate digest, when only pull images, can be false to save cpu and memory |
| dfdaemon.config.download.downloadGRPC.security | object | `{"insecure":true}` | Download grpc security option |
| dfdaemon.config.download.downloadGRPC.unixListen | object | `{"socket":"/tmp/dfdamon.sock"}` | Download service listen address current, only support unix domain socket |
| dfdaemon.config.download.peerGRPC.security | object | `{"insecure":true}` | Peer grpc security option |
| dfdaemon.config.download.peerGRPC.tcpListen.listen | string | `"0.0.0.0"` | Listen address |
| dfdaemon.config.download.peerGRPC.tcpListen.port | int | `65000` | Listen port |
| dfdaemon.config.download.perPeerRateLimit | string | `"100Mi"` | Per peer task limit per second |
| dfdaemon.config.download.totalRateLimit | string | `"200Mi"` | Total download limit per second |
| dfdaemon.config.gcInterval | string | `"1m0s"` | Daemon gc task running interval |
| dfdaemon.config.host.advertiseIP | string | `"0.0.0.0"` | Access ip for other peers when local ip is different with access ip, advertiseIP should be set |
| dfdaemon.config.host.listenIP | string | `"0.0.0.0"` | TCP service listen address port should be set by other options |
| dfdaemon.config.jaeger | string | `""` | Jaeger url, like: http://jaeger.dragonfly.svc:14268/api/traces |
| dfdaemon.config.keepStorage | bool | `false` | When daemon exit, keep peer task data or not it is usefully when upgrade daemon service, all local cache will be saved default is false |
| dfdaemon.config.pprofPort | int | `0` |  |
| dfdaemon.config.proxy.defaultFilter | string | `"Expires&Signature"` | Filter for hash url when defaultFilter: "Expires&Signature", for example:  http://localhost/xyz?Expires=111&Signature=222 and http://localhost/xyz?Expires=333&Signature=999 is same task |
| dfdaemon.config.proxy.proxies[0] | object | `{"regx":"blobs/sha256.*"}` | Proxy all http image layer download requests with dfget |
| dfdaemon.config.proxy.registryMirror.dynamic | bool | `true` | When enabled, use value of "X-Dragonfly-Registry" in http header for remote instead of url host |
| dfdaemon.config.proxy.registryMirror.insecure | bool | `false` | When the cert of above url is secure, set insecure to true |
| dfdaemon.config.proxy.registryMirror.url | string | `"https://index.docker.io"` | URL for the registry mirror |
| dfdaemon.config.proxy.security | object | `{"insecure":true}` | Proxy security option |
| dfdaemon.config.proxy.tcpListen.listen | string | `"0.0.0.0"` | Listen address |
| dfdaemon.config.proxy.tcpListen.namespace | string | `"/run/dragonfly/net"` | Namespace stands the linux net namespace, like /proc/1/ns/net it's useful for running daemon in pod with ip allocated and listening the special port in host net namespace Linux only |
| dfdaemon.config.scheduler | object | `{"disableAutoBackSource":false}` | Scheduler config, netAddrs is auto-configured in templates/dfdaemon/dfdaemon-configmap.yaml |
| dfdaemon.config.scheduler.disableAutoBackSource | bool | `false` | Disable auto back source in dfdaemon |
| dfdaemon.config.storage.diskGCThreshold | string | `"50Gi"` | Disk GC Threshold |
| dfdaemon.config.storage.multiplex | bool | `true` | Set to ture for reusing underlying storage for same task id |
| dfdaemon.config.storage.strategy | string | `"io.d7y.storage.v2.simple"` | Storage strategy when process task data io.d7y.storage.v2.simple : download file to data directory first, then copy to output path, this is default action                           the download file in date directory will be the peer data for uploading to other peers io.d7y.storage.v2.advance: download file directly to output path with postfix, hard link to final output,                            avoid copy to output path, fast than simple strategy, but:                            the output file with postfix will be the peer data for uploading to other peers                            when user delete or change this file, this peer data will be corrupted default is io.d7y.storage.v2.advance |
| dfdaemon.config.storage.taskExpireTime | string | `"6h"` | Task data expire time when there is no access to a task data, this task will be gc. |
| dfdaemon.config.upload.rateLimit | string | `"100Mi"` | Upload limit per second |
| dfdaemon.config.upload.security | object | `{"insecure":true}` | Upload grpc security option |
| dfdaemon.config.upload.tcpListen.listen | string | `"0.0.0.0"` | Listen address |
| dfdaemon.config.upload.tcpListen.port | int | `65002` | Listen port |
| dfdaemon.config.verbose | bool | `true` | When enable, pprof will be enabled |
| dfdaemon.containerPort | int | `65001` | Pod containerPort |
| dfdaemon.daemonsetAnnotations | object | `{}` | Daemonset annotations |
| dfdaemon.enable | bool | `true` | Enable dfdaemon |
| dfdaemon.extraVolumeMounts | list | `[{"mountPath":"/var/log/dragonfly/daemon","name":"logs"}]` | Extra volumeMounts for dfdaemon. |
| dfdaemon.extraVolumes | list | `[{"emptyDir":{},"name":"logs"}]` | Extra volumes for dfdaemon. |
| dfdaemon.fullnameOverride | string | `""` | Override dfdaemon fullname |
| dfdaemon.hostAliases | list | `[]` | Host Aliases |
| dfdaemon.hostNetwork | bool | `false` | Using hostNetwork when pod with host network can communicate with normal pods with cni network |
| dfdaemon.hostPort | int | `65001` | When .hostNetwork == false, and .config.proxy.tcpListen.namespace is empty many network add-ons do not yet support hostPort https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/#hostport-services-do-not-work by default, dfdaemon injects the 65001 port to host network by sharing host network namespace, if you want to use hostPort, please empty .config.proxy.tcpListen.namespace below, and keep .hostNetwork == false for performance, injecting the 65001 port to host network is better than hostPort |
| dfdaemon.image | string | `"dragonflyoss/dfdaemon"` | Image repository |
| dfdaemon.mountDataDirAsHostPath | bool | `false` | Mount data directory from host when enabled, mount host path to dfdaemon, or just emptyDir in dfdaemon |
| dfdaemon.name | string | `"dfdaemon"` | Dfdaemon name |
| dfdaemon.nameOverride | string | `""` | Override dfdaemon name |
| dfdaemon.nodeSelector | object | `{}` | Node labels for pod assignment |
| dfdaemon.podAnnotations | object | `{}` | Pod annotations |
| dfdaemon.podLabels | object | `{}` | Pod labels |
| dfdaemon.priorityClassName | string | `""` | Pod priorityClassName |
| dfdaemon.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| dfdaemon.resources | object | `{"limits":{"cpu":"2","memory":"2Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits |
| dfdaemon.tag | string | `"v2.0.1-beta.2"` | Image tag |
| dfdaemon.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds |
| dfdaemon.tolerations | list | `[]` | List of node taints to tolerate |
| externalManager.grpcPort | int | `65003` | External GRPC service port |
| externalManager.host | string | `nil` | External manager hostname |
| externalManager.restPort | int | `8080` | External REST service port |
| externalMysql.database | string | `"manager"` | External mysql database name |
| externalMysql.host | string | `nil` | External mysql hostname |
| externalMysql.migrate | bool | `true` | Running GORM migration |
| externalMysql.password | string | `"dragonfly"` | External mysql password |
| externalMysql.port | int | `3306` | External mysql port |
| externalMysql.username | string | `"dragonfly"` | External mysql username |
| externalRedis.host | string | `""` | External redis hostname |
| externalRedis.password | string | `"dragonfly"` | External redis password |
| externalRedis.port | int | `6379` | External redis port |
| fullnameOverride | string | `""` | Override dragonfly fullname |
| jaeger.enable | bool | `false` | Enable an all in one jaeger for tracing every downloading event should not use in production environment |
| manager.config.jaeger | string | `""` | Jaeger url, like: http://jaeger.dragonfly.svc:14268/api/traces |
| manager.deploymentAnnotations | object | `{}` | Deployment annotations |
| manager.enable | bool | `true` | Enable manager |
| manager.extraVolumeMounts | list | `[{"mountPath":"/var/log/dragonfly/manager","name":"logs"}]` | Extra volumeMounts for manager. |
| manager.extraVolumes | list | `[{"emptyDir":{},"name":"logs"}]` | Extra volumes for manager. |
| manager.fullnameOverride | string | `""` | Override manager fullname |
| manager.grpcPort | int | `65003` | GRPC service port |
| manager.hostAliases | list | `[]` | Host Aliases |
| manager.image | string | `"dragonflyoss/manager"` | Image repository |
| manager.ingress.annotations | object | `{}` | Ingress annotations |
| manager.ingress.enable | bool | `false` | Enable ingress |
| manager.ingress.hosts | list | `[]` | Manager ingress hosts |
| manager.ingress.path | string | `"/"` | Ingress host path |
| manager.ingress.tls | list | `[]` | Ingress TLS configuration |
| manager.initContainer.image | string | `"busybox"` | Init container image repository |
| manager.initContainer.pullPolicy | string | `"IfNotPresent"` | Container image pull policy |
| manager.initContainer.tag | string | `"latest"` | Init container image tag |
| manager.metrics.enable | bool | `false` | Enable manager metrics |
| manager.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels |
| manager.metrics.prometheusRule.enable | bool | `false` | Enable prometheus rule ref: https://github.com/coreos/prometheus-operator |
| manager.metrics.prometheusRule.rules | list | `[]` | Prometheus rules |
| manager.metrics.service.annotations | object | `{}` | Service annotations |
| manager.metrics.service.labels | object | `{}` | Service labels |
| manager.metrics.service.type | string | `"ClusterIP"` | Service type |
| manager.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels |
| manager.metrics.serviceMonitor.enable | bool | `false` | Enable prometheus service monitor ref: https://github.com/coreos/prometheus-operator |
| manager.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped |
| manager.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended |
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
| manager.service.annotations | object | `{}` | Service annotations |
| manager.service.labels | object | `{}` | Service labels |
| manager.service.type | string | `"ClusterIP"` | Service type |
| manager.tag | string | `"v2.0.1-beta.2"` | Image tag |
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
| scheduler.config.jaeger | string | `""` | Jaeger url, like: http://jaeger.dragonfly.svc:14268/api/traces |
| scheduler.config.manager.keepAlive.interval | string | `"5s"` | Manager keepalive interval |
| scheduler.config.manager.schedulerClusterID | int | `1` | Associated scheduler cluster id |
| scheduler.config.worker | object | `{"senderJobPoolSize":10000,"senderNum":10,"workerJobPoolSize":10000,"workerNum":4}` | Scheduling queue configuration |
| scheduler.containerPort | int | `8002` | Pod containerPort |
| scheduler.enable | bool | `true` | Enable scheduler |
| scheduler.extraVolumeMounts | list | `[{"mountPath":"/var/log/dragonfly/scheduler","name":"logs"}]` | Extra volumeMounts for scheduler. |
| scheduler.extraVolumes | list | `[{"emptyDir":{},"name":"logs"}]` | Extra volumes for scheduler. |
| scheduler.fullnameOverride | string | `""` | Override scheduler fullname |
| scheduler.hostAliases | list | `[]` | Host Aliases |
| scheduler.image | string | `"dragonflyoss/scheduler"` | Image repository |
| scheduler.initContainer.image | string | `"busybox"` | Init container image repository |
| scheduler.initContainer.pullPolicy | string | `"IfNotPresent"` | Container image pull policy |
| scheduler.initContainer.tag | string | `"latest"` | Init container image tag |
| scheduler.metrics.enable | bool | `false` | Enable manager metrics |
| scheduler.metrics.prometheusRule.additionalLabels | object | `{}` | Additional labels |
| scheduler.metrics.prometheusRule.enable | bool | `false` | Enable prometheus rule ref: https://github.com/coreos/prometheus-operator |
| scheduler.metrics.prometheusRule.rules | list | `[]` | Prometheus rules |
| scheduler.metrics.service.annotations | object | `{}` | Service annotations |
| scheduler.metrics.service.labels | object | `{}` | Service labels |
| scheduler.metrics.service.type | string | `"ClusterIP"` | Service type |
| scheduler.metrics.serviceMonitor.additionalLabels | object | `{}` | Additional labels |
| scheduler.metrics.serviceMonitor.enable | bool | `false` | Enable prometheus service monitor ref: https://github.com/coreos/prometheus-operator |
| scheduler.metrics.serviceMonitor.interval | string | `"30s"` | Interval at which metrics should be scraped |
| scheduler.metrics.serviceMonitor.scrapeTimeout | string | `"10s"` | Timeout after which the scrape is ended |
| scheduler.name | string | `"scheduler"` | Scheduler name |
| scheduler.nameOverride | string | `""` | Override scheduler name |
| scheduler.nodeSelector | object | `{}` | Node labels for pod assignment |
| scheduler.podAnnotations | object | `{}` | Pod annotations |
| scheduler.podLabels | object | `{}` | Pod labels |
| scheduler.priorityClassName | string | `""` | Pod priorityClassName |
| scheduler.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| scheduler.replicas | int | `3` | Number of Pods to launch |
| scheduler.resources | object | `{"limits":{"cpu":"4","memory":"8Gi"},"requests":{"cpu":"0","memory":"0"}}` | Pod resource requests and limits |
| scheduler.service | object | `{"annotations":{},"port":8002,"targetPort":8002,"type":"ClusterIP"}` | Service configuration |
| scheduler.service.annotations | object | `{}` | Service annotations |
| scheduler.service.port | int | `8002` | Service port |
| scheduler.service.targetPort | int | `8002` | Service targetPort |
| scheduler.service.type | string | `"ClusterIP"` | Service type |
| scheduler.statefulsetAnnotations | object | `{}` | Statefulset annotations |
| scheduler.tag | string | `"v2.0.1-beta.2"` | Image tag |
| scheduler.terminationGracePeriodSeconds | string | `nil` | Pod terminationGracePeriodSeconds |
| scheduler.tolerations | list | `[]` | List of node taints to tolerate |

## Chart dependencies

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | mysql | 8.0.0 |
| https://charts.bitnami.com/bitnami | redis | 12.1.0 |
