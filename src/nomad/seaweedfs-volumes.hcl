# WWW naster: http://seaweedfs-master.service.consul:9333/
# WWW filer: http://seaweedfs-filer.service.consul:8888/

job "seaweedfs-volume" {
  datacenters = ["dc1"]
  type = "system"

  group "seaweedfs-volume" {
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
        static = 8082
      }
      port "grpc" {
        static = 18082
      }
    }

    task "seaweedfs-volume" {
      driver = "docker"
      user = "1000:1000"
        
      config {
        image = "chrislusf/seaweedfs:3.26_large_disk"
        network_mode = "host"
        args = [
          "volume",
          "-dataCenter=${NOMAD_DC}",
#          "-rack=${meta.rack}",
          "-rack=${node.unique.name}",
          "-mserver=192.168.50.4:9333",
          "-port=${NOMAD_PORT_http}",
          "-ip=${NOMAD_IP_http}",
          "-publicUrl=${NOMAD_ADDR_http}",
          "-preStopSeconds=1",
          "-dir=/data"
        ]
        
        mounts = [
          {
            type = "bind"
            source = "/data/seaweedfs-volume-data" # there should be directory in host VM
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
        memory = 1024
        memory_max = 4096 # W need to have memory oversubscription enabled
      }
      
      service {
        tags = ["${node.unique.name}"]
        name = "seaweedfs-volume"
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