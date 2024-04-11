{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "dragonfly.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified manager name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.manager.fullname" -}}
{{ template "dragonfly.fullname" . }}-{{ .Values.manager.name }}
{{- end -}}

{{/*
Create a default fully qualified scheduler name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.scheduler.fullname" -}}
{{ template "dragonfly.fullname" . }}-{{ .Values.scheduler.name }}
{{- end -}}

{{/*
Create a default fully qualified client name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.client.fullname" -}}
{{ template "dragonfly.fullname" . }}-{{ .Values.client.name }}
{{- end -}}

{{/*
Create a default fully qualified seed client name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.seedClient.fullname" -}}
{{ template "dragonfly.fullname" . }}-{{ .Values.seedClient.name }}
{{- end -}}

{{/*
Create a default fully qualified dfinit name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.dfinit.fullname" -}}
{{ template "dragonfly.fullname" . }}-dfinit
{{- end -}}

{{/*
Create a default fully qualified seed peer name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.seedPeer.fullname" -}}
{{ template "dragonfly.fullname" . }}-{{ .Values.seedPeer.name }}
{{- end -}}

{{/*
Create a default fully qualified dfdaemon name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.dfdaemon.fullname" -}}
{{ template "dragonfly.fullname" . }}-{{ .Values.dfdaemon.name }}
{{- end -}}

{{/*
Create a default fully qualified trainer name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.trainer.fullname" -}}
{{ template "dragonfly.fullname" . }}-{{ .Values.trainer.name }}
{{- end -}}

{{/*
Create a default fully qualified triton name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.triton.fullname" -}}
{{ template "dragonfly.fullname" . }}-{{ .Values.triton.name }}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Return the proper image name
{{ include "common.images.image" ( dict "imageRoot" .Values.path.to.the.image "global" .Values.global ) }}
*/}}
{{- define "common.images.image" -}}
{{- $registryName := .imageRoot.registry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $separator := ":" -}}
{{- $termination := .imageRoot.tag | toString -}}
{{- if .global }}
    {{- if .global.imageRegistry }}
     {{- $registryName = .global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if .imageRoot.digest }}
    {{- $separator = "@" -}}
    {{- $termination = .imageRoot.digest | toString -}}
{{- end -}}
{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
{{- else -}}
    {{- printf "%s%s%s"  $repositoryName $separator $termination -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper image name (for the manager image)
*/}}
{{- define "manager.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.manager.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the scheduler image)
*/}}
{{- define "scheduler.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.scheduler.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the client image)
*/}}
{{- define "client.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.client.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the seedClient image)
*/}}
{{- define "seedClient.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.seedClient.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the client dfinit image)
*/}}
{{- define "client.dfinit.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.client.dfinit.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the dfdaemon image)
*/}}
{{- define "dfdaemon.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.dfdaemon.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the seedPeer image)
*/}}
{{- define "seedPeer.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.seedPeer.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the trainer image)
*/}}
{{- define "trainer.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.trainer.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the triton image)
*/}}
{{- define "triton.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.triton.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the manager initContainer image)
*/}}
{{- define "manager.initContainer.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.manager.initContainer.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the scheduler initContainer image)
*/}}
{{- define "scheduler.initContainer.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.scheduler.initContainer.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the client initContainer image)
*/}}
{{- define "client.initContainer.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.client.initContainer.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the seedClient initContainer image)
*/}}
{{- define "seedClient.initContainer.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.seedClient.initContainer.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the dfdaemon initContainer image)
*/}}
{{- define "dfdaemon.initContainer.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.dfdaemon.initContainer.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the seedPeer initContainer image)
*/}}
{{- define "seedPeer.initContainer.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.seedPeer.initContainer.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper image name (for the containerRuntime initContainer image)
*/}}
{{- define "containerRuntime.initContainer.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.containerRuntime.initContainer.image "global" .Values.global ) -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Return  the proper Storage Class
{{ include "common.storage.class" ( dict "persistence" .Values.path.to.the.persistence "global" $) }}
*/}}
{{- define "common.storage.class" -}}

{{- $storageClass := .persistence.storageClass -}}
{{- if .global -}}
    {{- if .global.storageClass -}}
        {{- $storageClass = .global.storageClass -}}
    {{- end -}}
{{- end -}}

{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}

{{- end -}}
