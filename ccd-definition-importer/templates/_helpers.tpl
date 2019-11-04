{{- define "hmcts.ccddi.releaseName" -}}
{{- if .Values.releaseNameOverride -}}
{{- tpl .Values.releaseNameOverride $ | trunc 53 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 53 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{/*
All the common labels needed for the labels sections of the definitions.
*/}}
{{- define "ccddi.labels" }}
app.kubernetes.io/name: {{ template "hmcts.ccddi.releaseName" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ template "hmcts.ccddi.releaseName" . }}
{{- end -}}
