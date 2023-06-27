{{/* Define a template to generate the name of the application */}}
{{- define "s3-irsa-app.name" -}}
{{- default "s3-irsa-app" }}
{{- end }}

{{/* Define a template to generate the name and version of the chart */}}
{{- define "s3-irsa-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}
