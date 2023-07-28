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
Create a default fully qualified scheduler name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.scheduler.fullname" -}}
{{ template "dragonfly.fullname" . }}-{{ .Values.scheduler.name }}
{{- end -}}

{{/*
Create a default fully qualified seed peer name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.seedPeer.fullname" -}}
{{ template "dragonfly.fullname" . }}-{{ .Values.seedPeer.name }}
{{- end -}}

{{/*
Create a default fully qualified manager name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.manager.fullname" -}}
{{ template "dragonfly.fullname" . }}-{{ .Values.manager.name }}
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
