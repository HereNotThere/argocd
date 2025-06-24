{{/*
Expand the name of the chart.
*/}}
{{- define "main-alb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "main-alb.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "main-alb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "main-alb.labels" -}}
helm.sh/chart: {{ include "main-alb.chart" . }}
{{ include "main-alb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "main-alb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "main-alb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "main-alb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "main-alb.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Argocd Domain name
*/}}
{{- define "argocd.domainName" -}}
{{- printf "argocd-%s.towns.com" .Values.global.environmentName }}
{{- end }}


{{/*
Notification Service domain name
*/}}
{{- define "notification-service.domainName" -}}
{{- printf "river-notification-service-%s.towns.com" .Values.global.environmentName }}
{{- end }}

{{/*
Subgraph domain name
*/}}
{{- define "subgraph.domainName" -}}
{{- printf "subgraph-%s.towns.com" .Values.global.environmentName }}
{{- end }}

{{/*
RPC Gateway domain name
*/}}
{{- define "rpc-gateway.domainName" -}}
{{- printf "rpc-gateway-%s.towns.com" .Values.global.environmentName }}
{{- end }}

{{/*
App Registry Service domain name
*/}}
{{- define "app-registry-service.domainName" -}}
{{- printf "app-registry.%s.towns.com" .Values.global.environmentName }}
{{- end }}

{{/*
All host names to attach to the ALB. A comma separated list of all the host names that should be attached to the ALB.
*/}}
{{- define "main-alb.hosts" -}}
{{ include "argocd.domainName" . }},{{ include "notification-service.domainName" . }},{{ include "subgraph.domainName" . }},{{ include "rpc-gateway.domainName" . }},{{ include "app-registry-service.domainName" . }}
{{- end }}

