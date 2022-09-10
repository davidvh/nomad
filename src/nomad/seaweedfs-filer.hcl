# WWW naster: http://seaweedfs-master.service.consul:9333/
# WWW filer: http://seaweedfs-filer.service.consul:8888/

job "seaweedfs-filer" {
  datacenters = ["dc1"]
  type = "system"

  group "seaweedfs-filer" {
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    update {
      max_parallel      = 1
      stagger           = "2m"
    }
    
    network {
      port "http" {
        static = 8888
      }
      port "grpc" {
        static = 18888
      }
      port "s3" {
        static = 8333
      }
    }

    task "seaweedfs-filer" {
      driver = "docker"
      user = "1000:1000"
        
      config {
        image = "chrislusf/seaweedfs:3.26_large_disk"
        network_mode = "host"
        args = [
          "filer",
          "-dataCenter=${NOMAD_DC}",
          "-rack=${node.unique.name}",
          "-defaultReplicaPlacement=000",
          "-master=192.168.50.4:9333",
          "-ip=192.168.50.4",
          "-s3",
          "-port=${NOMAD_HOST_PORT_http}",
          "-s3.port=${NOMAD_HOST_PORT_s3}"
        ]

        mounts = [
          {
            type = "bind"
            source = "/data/seaweedfs-filer-data" # there should be directory in host VM
            target = "/data"
            readonly = false
            bind_options = {
              propagation = "rprivate"
            }
          }
         ]
      }

      resources {
        cpu = 512
        memory = 256
        memory_max = 1024 # W need to have memory oversubscription enabled
      }
      
      service {
        tags = ["${node.unique.name}"]
        name = "seaweedfs-filer"
        port = "http"
        check {
          type = "tcp"
          port = "http"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }
  
}