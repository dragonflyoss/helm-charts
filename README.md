# Dragonfly Community Helm Charts

[![Dragonfly Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/dragonfly)](https://artifacthub.io/packages/helm/dragonfly/dragonfly)
[![Nydus Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/nydus-snapshotter)](https://artifacthub.io/packages/helm/dragonfly/nydus-snapshotter)
[![Dragonfly Stack Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/dragonfly-stack)](https://artifacthub.io/packages/helm/dragonfly/dragonfly-stack)
![Release Charts](https://github.com/dragonflyoss/helm-charts/workflows/Release%20Charts/badge.svg?branch=main)
[![Releases downloads](https://img.shields.io/github/downloads/dragonflyoss/helm-charts/total.svg)](https://github.com/dragonflyoss/helm-charts/releases)

Helm charts for Dragonfly Community.

## Introduction

Delivers efficient, stable, and secure data distribution and acceleration powered by P2P technology,
with an optional content‑addressable filesystem that accelerates OCI container launch.
It aims to provide a best‑practice, standards‑based solution for cloud‑native architectures,
improving large‑scale delivery of files, container images, OCI artifacts, AI/ML models, caches,
logs, dependencies, etc.

## Installation

Please refer to the [document][install] to install Dragonfly & Nydus on Kubernetes.

## Documentation

- [Install Dragonfly Stack on Kubernetes](./charts/dragonfly-stack/README.md)
- [Install Dragonfly on Kubernetes](./charts/dragonfly/README.md)
- [Install Nydus on Kubernetes](./charts/nydus-snapshotter/README.md)
- [Install Dragonfly & Nydus on Kubernetes][install]

## Community

Join the conversation and help the community grow. Here are the ways to get involved:

- **Slack Channel**: [#dragonfly](https://cloud-native.slack.com/messages/dragonfly/) on [CNCF Slack](https://slack.cncf.io/)
- **Github Discussions**: [Dragonfly Discussion Forum](https://github.com/dragonflyoss/dragonfly/discussions)
- **Developer Group**: <dragonfly-developers@googlegroups.com>
- **Mailing Lists**:
  - **Developers**: <dragonfly-developers@googlegroups.com>
  - **Maintainers**: <dragonfly-maintainers@googlegroups.com>
- **Twitter**: [@dragonfly_oss](https://twitter.com/dragonfly_oss)
- **DingTalk Group**: `22880028764`

[license]: LICENSE
[install]: INSTALL.md
