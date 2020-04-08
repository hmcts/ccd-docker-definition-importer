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
{{- if .Values.aadIdentityName }}
aadpodidbinding: {{ .Values.aadIdentityName }}
{{- end }}
app.kubernetes.io/name: {{ template "hmcts.ccddi.releaseName" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ template "hmcts.ccddi.releaseName" . }}
{{- end -}}
{{/*
Adding in the helper here where we can use a secret object to include secrets to for the deployed service.
The key or "environment variable" must be uppercase and contain only numbers or "_".
Example format:
"
 ENVIRONMENT_VAR:
    secretRef: secret-vault
    key: connectionString
    disabled: false
"
*/}}
{{- define "ccddi.secrets" -}}

  {{- if .Values.secrets -}}
    {{- range $key, $val := .Values.secrets }}
      {{- if and $val (not $val.disabled) }}
- name: {{ if $key | regexMatch "^[^.-]+$" -}}
          {{- $key }}
        {{- else -}}
            {{- fail (join "Environment variables can not contain '.' or '-' Failed key: " ($key|quote)) -}}
        {{- end }}
  valueFrom:
    secretKeyRef:
      name: {{  tpl (required "Each item in \"secrets:\" needs a secretRef member" $val.secretRef) $ }}
      key: {{ required "Each item in \"secrets:\" needs a key member" $val.key }}
      {{- end }}
    {{- end }}
  {{- end -}}
{{- end }}

{{/*
This template is for adding the environment variable list and checking the format of the keys
The key or "environment variable" must be uppercase and contain only numbers or "_".
*/}}
{{- define "ccddi.environment" -}}
  {{- if .Values.environment -}}
    {{- range $key, $val := .Values.environment }}
- name: {{ if $key | regexMatch "^[^.-]+$" -}}
          {{- $key }}
        {{- else -}}
            {{- fail (join "Environment variables can not contain '.' or '-' Failed key: " ($key|quote)) -}}
        {{- end }}
  value: {{ tpl ($val | quote) $ }}
    {{- end }}
  {{- end }}
{{- end }}
