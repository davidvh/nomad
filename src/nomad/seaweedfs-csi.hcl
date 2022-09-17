# WWW naster: http://seaweedfs-master.service.consul:9333/
# WWW filer: http://seaweedfs-filer.service.consul:8888/

job "seaweedfs-csi" {
  datacenters = ["dc1"]
  type = "system"

  group "mounts" {
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

    task "seaweedfs-mount" {
      driver = "docker"
        
      config {
        image = "chrislusf/seaweedfs:3.26_large_disk"
        args = [
          "mount",
          "--filer=192.168.50.4:8888",
          "--dir=/mounted/fast",
          "--filer.path=/",
        ]
        
        mount {
          type = "bind"
          target = "/mounted"
          source = "/mnt/cluster"
          readonly = false
          bind_options {
            propagation = "shared"
          }
        }

         privileged = true
      }

      resources {
        cpu = 512
        memory = 512
        memory_max = 2048 # W need to have memory oversubscription enabled
      }
    }
  }
}
