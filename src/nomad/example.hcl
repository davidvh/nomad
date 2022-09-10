# This declares a job named "docs". There can be exactly one
# job declaration per job file.
job "docs" {
  region = "global"
  datacenters = ["dc1"]

  # Run this job as a "service" type. Each job type has different
  # properties. See the documentation below for more examples.
  type = "service"

  # Specify this job to have rolling updates, two-at-a-time, with
  # 30 second intervals.
  update {
    stagger      = "30s"
    max_parallel = 2
  }

  # A group defines a series of tasks that should be co-located
  # on the same client (host). All tasks within a group will be
  # placed on the same host.
  group "webs" {
    count = 1

    volume "example-seaweedfs-volume" {
      type            = "csi"
      source          = "example-seaweedfs-volume"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }

    network {
      # This requests a dynamic port named "http". This will
      # be something like "46283", but we refer to it via the
      # label "http".
      port "http" { to = 80 }
    }

    # The service block tells Nomad how to register this service
    # with Consul for service discovery and monitoring.
    service {
      name = "example"
      # This tells Consul to monitor the service on the port
      # labelled "http". Since Nomad allocates high dynamic port
      # numbers, we use labels to refer to them.
      port = "http"

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    # Create an individual task (unit of work). This particular
    # task utilizes a Docker container to front a web application.
    task "frontend" {
      # Specify the driver to be "docker". Nomad supports
      # multiple drivers.
      driver = "docker"

      # Configuration is specific to each driver.
      config {
        image = "linuxserver/heimdall:2.4.13"
        ports = ["http"]
      }

      # It is possible to set environment variables which will be
      # available to the task when it runs.
      env {
        PUID = "1000"
        PGID = "1000"
        TZ = "US/Pacific"
      }

      volume_mount {
        volume = "example-seaweedfs-volume"
        destination = "/config"
      }

      # Specify the maximum resources required to run the task,
      # include CPU and memory.
      resources {
        cpu    = 500 # MHz
        memory = 128 # MB
      }
    }
  }
}
