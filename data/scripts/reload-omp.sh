#!/bin/sh
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/skwd-wall"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/skwd"
COLORS="$CACHE/colors.json"
OUTPUT="$CONFIG/ext/omp/skwd.omp.json"

[ -f "$COLORS" ] || exit 0
command -v jq >/dev/null || exit 0

mkdir -p "$(dirname "$OUTPUT")"

# temp workaround until I take time to investigate how to theme OMP
ENV_OUT="$CACHE/colors.env"
jq -r '
  "export SKWD_PRIMARY=\"\(.primary)\"",
  "export SKWD_ON_PRIMARY=\"\(.primaryText)\"",
  "export SKWD_PRIMARY_CONTAINER=\"\(.primaryContainer)\"",
  "export SKWD_ON_PRIMARY_CONTAINER=\"\(.primaryContainerText)\"",
  "export SKWD_TERTIARY=\"\(.tertiary)\"",
  "export SKWD_ON_TERTIARY=\"\(.tertiaryText)\"",
  "export SKWD_TERTIARY_CONTAINER=\"\(.tertiaryContainer)\"",
  "export SKWD_ON_TERTIARY_CONTAINER=\"\(.tertiaryContainerText)\"",
  "export SKWD_SURFACE=\"\(.surface)\"",
  "export SKWD_SURFACE_VARIANT=\"\(.surfaceVariant)\"",
  "export SKWD_ON_SURFACE_VARIANT=\"\(.surfaceVariantText)\"",
  "export SKWD_ERROR=\"\(.error)\"",
  "export SKWD_ON_ERROR=\"\(.errorText)\"",
  "export SKWD_OUTLINE=\"\(.outline)\""
' "$COLORS" > "$ENV_OUT"

jq '{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "version": 3,
  "final_space": true,
  "console_title_template": "{{ .Shell }} in {{ .Folder }}",
  "palette": {
    "primary": .primary,
    "on-primary": .primaryText,
    "primary-container": .primaryContainer,
    "on-primary-container": .primaryContainerText,
    "tertiary": .tertiary,
    "on-tertiary": .tertiaryText,
    "tertiary-container": .tertiaryContainer,
    "on-tertiary-container": .tertiaryContainerText,
    "surface": .surface,
    "surface-variant": .surfaceVariant,
    "on-surface-variant": .surfaceVariantText,
    "error": .error,
    "on-error": .errorText,
    "outline": .outline
  },
  "blocks": [
    {
      "type": "prompt", "alignment": "left",
      "segments": [
        {"type":"time","style":"powerline","powerline_symbol":"\ue0b8","foreground":"p:on-primary","background":"p:primary","foreground_templates":["{{ .Env.SKWD_ON_PRIMARY }}"],"background_templates":["{{ .Env.SKWD_PRIMARY }}"],"template":" {{ .CurrentDate | date \"15:04\" }} "},
        {"type":"path","style":"powerline","powerline_symbol":"\ue0b8","foreground":"p:on-tertiary","background":"p:tertiary","foreground_templates":["{{ .Env.SKWD_ON_TERTIARY }}"],"background_templates":["{{ .Env.SKWD_TERTIARY }}"],"template":" \uf413 {{ .Path }} ","properties":{"style":"agnoster_short","max_depth":3}},
        {"type":"git","style":"powerline","powerline_symbol":"\ue0b8","foreground":"p:on-primary","background":"p:primary","foreground_templates":["{{ .Env.SKWD_ON_PRIMARY }}"],"background_templates":["{{ .Env.SKWD_PRIMARY }}"],"template":" \ue0a0 {{ .HEAD }}{{ if .Working.Changed }} \uf044 {{ .Working.String }}{{ end }}{{ if .Staging.Changed }} \uf046 {{ .Staging.String }}{{ end }} ","properties":{"branch_icon":"","fetch_status":true,"fetch_stash_count":true}},
        {"type":"status","style":"powerline","powerline_symbol":"\ue0b8","foreground":"p:on-error","background":"p:error","foreground_templates":["{{ .Env.SKWD_ON_ERROR }}"],"background_templates":["{{ .Env.SKWD_ERROR }}"],"template":" \uf00d {{ .Code }} "}
      ]
    },
    {
      "type": "prompt", "alignment": "right", "overflow": "hide",
      "segments": [
        {"type":"executiontime","style":"powerline","powerline_symbol":"\ue0ba","invert_powerline":true,"foreground":"p:on-surface-variant","background":"p:surface-variant","foreground_templates":["{{ .Env.SKWD_ON_SURFACE_VARIANT }}"],"background_templates":["{{ .Env.SKWD_SURFACE_VARIANT }}"],"template":" \uf252 {{ .FormattedMs }} ","properties":{"threshold":2000,"style":"roundrock"}}
      ]
    },
    {
      "type": "prompt", "alignment": "left", "newline": true,
      "segments": [
        {"type":"text","style":"plain","foreground":"p:primary","foreground_templates":["{{ .Env.SKWD_PRIMARY }}"],"template":"❯ "}
      ]
    }
  ]
}' "$COLORS" > "$OUTPUT"
