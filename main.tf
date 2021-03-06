data "external" "local_install1" {
  program = ["bash", "${path.module}/install-all.sh"]
}

resource "null_resource" "local_install" {
  provisioner "local-exec" {
    command = "bash ${path.module}/install-all.sh"
  }

  triggers = {
    timestamp = timestamp()
  }
}

resource "null_resource" "local_install_on_destroy" {
  depends_on = ["data.external.local_install1", "kubernetes_replication_controller.example"]
  provisioner "local-exec" {
    command = "bash ${path.module}/install-all.sh"
    when    = destroy
  }
    
}

provider "kubernetes" {
}

resource "kubernetes_replication_controller" "example" {
  
  depends_on = ["null_resource.local_install", "data.external.local_install1"]
  metadata {
    name = "terraform-example"
    labels = {
      test = "MyExampleApp"
    }
  }

  spec {
    selector = {
      test = "MyExampleApp"
    }
    template {
      metadata {
        labels = {
          test = "MyExampleApp"
        }
        annotations = {
          "key1" = "value1"
        }
      }

      spec {
        container {
          image = "nginx:1.7.8"
          name  = "example"

          liveness_probe {
            http_get {
              path = "/nginx_status"
              port = 8080

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

