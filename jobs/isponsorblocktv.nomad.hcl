job "isponsorblocktv" {
  group "isponsorblocktv" {
    task "isponsorblocktv" {
      driver = "docker"

      config {
        image = "ghcr.io/dmunozv04/isponsorblocktv:v2.2.1"
        args  = ["--data", "${NOMAD_SECRETS_DIR}/config"]
      }

      resources {
        cpu    = 50
        memory = 128
      }

      template {
        data        = <<EOF
{{with nomadVar "nomad/jobs/isponsorblocktv"}}
{
  "devices": [
    {
      "screen_id": "{{.device_id.Value}}",
      "name": "Farofa",
      "offset": 0
    }
  ],
  "apikey": "",
  "skip_categories": [
    "sponsor"
  ],
  "channel_whitelist": [],
  "skip_count_tracking": true,
  "mute_ads": false,
  "skip_ads": false,
  "auto_play": false
}
{{end}}
EOF
        destination = "${NOMAD_SECRETS_DIR}/config/config.json"
      }
    }
  }
}
