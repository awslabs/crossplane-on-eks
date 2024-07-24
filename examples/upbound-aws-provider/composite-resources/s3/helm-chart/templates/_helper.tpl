{{/* Define a template to generate the name of the application */}}
{{- define "s3-access-app.name" -}}
{{- default "s3-access-app" }}
{{- end }}

{{/* Define a template to generate the name and version of the chart */}}
{{- define "s3-access-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}
