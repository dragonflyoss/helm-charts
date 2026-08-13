{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "dragonfly.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts.
*/}}
{{- define "common.names.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
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
Return "true" if a manager is available, either deployed by this chart (manager.enable)
or provided externally (externalManager.host). If neither is configured, the scheduler
and client load the dynamic configuration from the local dynconfig.yaml file mounted as
a ConfigMap instead of fetching it from the manager.
*/}}
{{- define "dragonfly.manager.enable" -}}
{{- if or .Values.manager.enable .Values.externalManager.host -}}
true
{{- end -}}
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

{{/*
Renders a value that contains template perhaps with scope if the scope is present.
Usage:
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $ ) }}
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $ "scope" $app ) }}
*/}}
{{- define "common.tplvalues.render" -}}
{{- $value := typeIs "string" .value | ternary .value (.value | toYaml) }}
{{- if contains "{{" (toJson .value) }}
  {{- if .scope }}
      {{- tpl (cat "{{- with $.RelativeScope -}}" $value "{{- end }}") (merge (dict "RelativeScope" .scope) .context) }}
  {{- else }}
    {{- tpl $value .context }}
  {{- end }}
{{- else }}
    {{- $value }}
{{- end }}
{{- end -}}

{{/*
Render the shared inter-component gRPC JWT authentication configuration.
*/}}
{{- define "dragonfly.grpcAuth.config" -}}
{{- $mode := lower .Values.grpcAuth.mode -}}
{{- if not (has $mode (list "disabled" "permissive" "required")) -}}
{{- fail "grpcAuth.mode must be one of disabled, permissive, or required" -}}
{{- end -}}
mode: {{ $mode | quote }}
{{ if ne $mode "disabled" }}
{{- $existingSecret := required "grpcAuth.existingSecret is required when gRPC authentication is enabled" .Values.grpcAuth.existingSecret -}}
{{- $activeKeyID := required "grpcAuth.activeKeyID is required when gRPC authentication is enabled" .Values.grpcAuth.activeKeyID -}}
{{- $mountPath := required "grpcAuth.mountPath is required when gRPC authentication is enabled" .Values.grpcAuth.mountPath -}}
{{- if eq (len .Values.grpcAuth.keys) 0 -}}
{{- fail "grpcAuth.keys must contain at least one key when gRPC authentication is enabled" -}}
{{- end -}}
requireTransportSecurity: {{ .Values.grpcAuth.requireTransportSecurity }}
jwt:
  issuer: {{ .Values.grpcAuth.issuer | quote }}
  activeKeyID: {{ $activeKeyID | quote }}
  tokenTTL: {{ .Values.grpcAuth.tokenTTL | quote }}
  maxTokenTTL: {{ .Values.grpcAuth.maxTokenTTL | quote }}
  clockSkew: {{ .Values.grpcAuth.clockSkew | quote }}
  refreshBefore: {{ .Values.grpcAuth.refreshBefore | quote }}
  keys:
{{- $seen := dict -}}
{{- $activeFound := false -}}
{{- range $index, $key := .Values.grpcAuth.keys }}
{{- $id := required "every grpcAuth.keys entry requires id" $key.id -}}
{{- $secretKey := required "every grpcAuth.keys entry requires secretKey" $key.secretKey -}}
{{- if hasKey $seen $id -}}
{{- fail (printf "grpcAuth key id %q is duplicated" $id) -}}
{{- end -}}
{{- $_ := set $seen $id true -}}
{{- if eq $id $activeKeyID -}}
{{- $activeFound = true -}}
{{- end }}
    - id: {{ $id | quote }}
      secretFile: {{ printf "%s/key-%d" (trimSuffix "/" $mountPath) $index | quote }}
{{- end -}}
{{- if not $activeFound -}}
{{- fail "grpcAuth.activeKeyID must identify an entry in grpcAuth.keys" -}}
{{- end -}}
{{- end }}
{{- end -}}

{{/*
Create a default fully qualified injector name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dragonfly.injector.fullname" -}}
{{ template "dragonfly.fullname" . }}-injector
{{- end -}}

{{/*
Return the proper image name (for the injector image)
*/}}
{{- define "injector.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.injector.image "global" .Values.global ) -}}
{{- end -}}
