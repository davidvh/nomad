# WWW naster: http://seaweedfs-master.service.consul:9333/
# WWW filer: http://seaweedfs-filer.service.consul:8888/

job "seaweedfs" {
  datacenters = ["dc1"]
  type = "service"

  group "seaweedfs-master" {
    count = 1

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    
    update {
      max_parallel = 1
      stagger      = "5m"
      canary       = 0
    }
    
    migrate {
      min_healthy_time = "2m"
    }
    
    # See https://github-wiki-see.page/m/seaweedfs/seaweedfs/wiki/FAQ for grpc port explanation
    network {
      port "http" {
        static = 9334
        to = 9333
      }
      port "grpc" {
        static = 19334
        to = 19333
      }
    }

    task "seaweedfs-master" {
      driver = "docker"
      env {
        WEED_MASTER_VOLUME_GROWTH_COPY_1 = "1"
        WEED_MASTER_VOLUME_GROWTH_COPY_2 = "2"
        WEED_MASTER_VOLUME_GROWTH_COPY_OTHER = "1"
      }
      config {
        image = "chrislusf/seaweedfs:3.26_large_disk"
        network_mode = "host"
        ports = ["http","grpc"]
        args = [
          "-v=1", "master",
          "-volumeSizeLimitMB=100",
          "-resumeState=false",
          "-ip=${NOMAD_IP_http}",
          "-port=${NOMAD_HOST_PORT_http}",
          "-mdir=${NOMAD_TASK_DIR}/master"
        ]
      }

      resources {
        cpu = 128
        memory = 128
      }
      
      service {
        tags = ["${node.unique.name}"]
        name = "seaweedfs-master"
        port = "http"
        check {
          type = "tcp"
          port = "http"
          interval = "10s"
          timeout = "2s"
        }
      }

      service {
        tags = ["${node.unique.name}"]
        name = "seaweedfs-master-grpc"
        port = "grpc"
        check {
          type = "tcp"
          port = "grpc"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }

}