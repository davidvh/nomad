job "nginx" {
  datacenters = ["dc1"]
  type = "system"

  group "nginx" {
    network {
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx"

        network_mode = "host"
        ports = ["http", "https"]

        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      // See https://github.com/linuxserver/reverse-proxy-confs
      template {
        data = <<EOF
add_header Strict-Transport-Security    "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options              SAMEORIGIN;
add_header X-Content-Type-Options       nosniff;
add_header X-XSS-Protection             "1; mode=block";
EOF

        destination   = "local/include/server.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOF
proxy_set_header    X-Real-IP           $remote_addr;
proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
proxy_set_header    X-Forwarded-Proto   $scheme;
proxy_set_header    Host                $host;
proxy_set_header    X-Forwarded-Host    $host;
proxy_set_header    X-Forwarded-Port    $server_port;
EOF

        destination   = "local/include/location.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOF
upstream backend {
{{ range service "example" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
   listen 80;

   include conf.d/include/server.conf;

   location / {
    include conf.d/include/location.conf;

      proxy_pass http://backend;
   }
}
EOF

        destination   = "local/default.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
