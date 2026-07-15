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

{{/*
Placeholder tokens substituted into rendered manager.yaml/scheduler.yaml config files by
"dragonfly.renderSecretsScript" below. Configmap templates emit one of these tokens, instead of
the plaintext secret value, whenever the corresponding existingSecret value is configured.
*/}}
{{- define "dragonfly.secrets.mysqlPasswordPlaceholder" -}}__DRAGONFLY_MYSQL_PASSWORD__{{- end -}}
{{- define "dragonfly.secrets.redisPasswordPlaceholder" -}}__DRAGONFLY_REDIS_PASSWORD__{{- end -}}
{{- define "dragonfly.secrets.redisSentinelPasswordPlaceholder" -}}__DRAGONFLY_REDIS_SENTINEL_PASSWORD__{{- end -}}
{{- define "dragonfly.secrets.jwtKeyPlaceholder" -}}__DRAGONFLY_JWT_KEY__{{- end -}}

{{/*
Shell script run by the "render-secrets" initContainer. It copies the config template (mounted
read-only from a ConfigMap) into a writable emptyDir, then substitutes any placeholder token
(see above) for the value of its matching environment variable. Config keys that were not backed
by an existingSecret were rendered as plaintext directly by the ConfigMap template, so their
placeholder never appears here and the substitution is a no-op for them.
Placeholders are always emitted quoted (e.g. `password: "__DRAGONFLY_MYSQL_PASSWORD__"`), so a
value is first escaped for a YAML double-quoted scalar (backslash, then double quote), and the
result of that is then escaped again for use as a sed replacement (backslash, "/" delimiter, then
"&"). This lets secrets contain arbitrary characters -- including ":", "#", "\" and "/" -- without
corrupting the rendered config file. Raw, unescaped newlines within a secret are not supported.
Usage: {{ include "dragonfly.renderSecretsScript" . | indent 12 }} under a `sh -c |` command.
*/}}
{{- define "dragonfly.renderSecretsScript" -}}
set -eu
mkdir -p /dragonfly-config
for f in /dragonfly-config-template/*; do
  cp "$f" /dragonfly-config/
done
render() {
  placeholder="$1"
  value="$2"
  [ -z "$value" ] && return 0
  yaml_escaped=$(printf '%s' "$value" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
  sed_escaped=$(printf '%s' "$yaml_escaped" | sed 's/[&/\]/\\&/g')
  for f in /dragonfly-config/*; do
    sed -i "s/${placeholder}/${sed_escaped}/g" "$f"
  done
}
render '{{ include "dragonfly.secrets.mysqlPasswordPlaceholder" . }}' "${DRAGONFLY_MYSQL_PASSWORD:-}"
render '{{ include "dragonfly.secrets.redisPasswordPlaceholder" . }}' "${DRAGONFLY_REDIS_PASSWORD:-}"
render '{{ include "dragonfly.secrets.redisSentinelPasswordPlaceholder" . }}' "${DRAGONFLY_REDIS_SENTINEL_PASSWORD:-}"
render '{{ include "dragonfly.secrets.jwtKeyPlaceholder" . }}' "${DRAGONFLY_JWT_KEY:-}"
{{- end -}}
