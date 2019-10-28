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
{{- define "importer.definition.vault" }}
  {{- if eq .Values.global.subscriptionId "bf308a5c-0624-4334-8ff8-8dca9fd43783"}}
  {{- "ccd-saat" -}}
  {{- else }}
  {{- "ccd-aat" -}}
  {{- end }}
{{- end }}

{{- define "importer.definition.resourcegroup" }}
  {{- if eq .Values.global.subscriptionId "bf308a5c-0624-4334-8ff8-8dca9fd43783"}}
  {{- "ccd-shared-saat" -}}
  {{- else }}
  {{- "ccd-shared-aat" -}}
  {{- end }}
{{- end }}

{{- define "importer.definition.vaultGit" }}
  {{- if eq .Values.global.subscriptionId "bf308a5c-0624-4334-8ff8-8dca9fd43783"}}
  {{- "infra-vault-sandbox" -}}
  {{- else }}
  {{- "infra-vault-nonprod" -}}
  {{- end }}
{{- end }}

{{- define "hmcts.ccddi.overrideEnv" -}}
{{- if .Values.global.environment -}}
{{- tpl .Values.global.environment $ | trunc 53 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}