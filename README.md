# EKS cluster with terraform with kublectl and aws-iam-auth

1. create a working EKS cluster on AWS
- clone this https://github.com/terraform-providers/terraform-provider-aws
- cd terraform-provider-aws/examples/eks-getting-started
- export variables:
```
export AWS_ACCESS_KEY_ID=<id>
export AWS_SECRET_ACCESS_KEY=<secret>
export AWS_DEFAULT_REGION=<region>
```      
   
- terraform init
- terraform apply
2. Get the config file
- terraform output kubeconfig | tee config
- terraform output config_map_aws_auth | tee config_map_aws_auth.yaml  

3. Move the configuration files to the location where is your script for installing kubectl, awscli and aws-iam-auth and will project will start

TO USE LOCALLY:
1. Install kubectl , aws-iam-auth and awscli with the following script:
```

#!/usr/bin/env bash  
exec 5>&1 &>/dev/null  
# from https://docs.aws.amazon.com/cli/latest/userguide/awscli-install-bundle.html 

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" 
unzip awscli-bundle.zip 
rm awscli-bundle.zip 
sudo /usr/bin/python2 awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws 
rm -fr awscli-bundle  
pushd /usr/local/bin  

# from https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html#install-kubectl-linux 
sudo curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/kubectl 
sudo chmod +x kubectl  

# from https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html 
sudo curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator 
sudo chmod +x aws-iam-authenticator  

popd  exec 1>&5

```
2.    export KUBECONFIG=config
3.    kubectl apply -f config_map_aws_auth.yaml
4.    kubectl get svc
5.    Create terraform kubernetes resource and init, apply or use the kubectl
6.    Code
```
resource "null_resource" "local_install" {
provisioner "local-exec" {
command = "bash ${path.module}/install-all.sh"
}

triggers {
timestamp = "${timestamp()}"
}
}

provider "kubernetes" {}

resource "kubernetes_replication_controller" "example" {

depends_on = ["null_resource.local_install"]

metadata {
name = "terraform-example"

labels {
test = "MyExampleApp"
}
}

spec {
selector {
test = "MyExampleApp"
}

template {
container {
image = "nginx:1.7.8"
name  = "example"

resources {
limits {
cpu  = "0.5"
memory = "512Mi"
}

requests {
cpu  = "250m"
memory = "50Mi"
}
}
}
}
}
}
```

TO USE IN TFE:

 Once the cluster is created and you have the config file :

1. Create a repo and place the config file with the terraform code inside

```
# something.tf
resource "null_resource" "local_install" {
  provisioner "local-exec" {
    command = "bash ${path.module}/install-all.sh"
  }

  triggers {
    timestamp = "${timestamp()}"
  }
}

resource "null_resource" "local_install_on_destroy" {
  provisioner "local-exec" {
    command = "bash ${path.module}/install-all.sh"
    when    = "destroy"
  }
}

provider "kubernetes" {}

resource "kubernetes_replication_controller" "example" {

  depends_on = ["null_resource.local_install"]

  metadata {
    name = "terraform-example"

    labels {
      test = "MyExampleApp"
    }
  }

  spec {
    selector {
      test = "MyExampleApp"
    }

    template {
      container {
        image = "nginx:1.7.8"
        name  = "example"

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
```

2. Connect VCS with TFE
3. create variables
```
KUBECONFIG=/terraform/config
AWS_ACCESS_KEY_ID=<id>
AWS_SECRET_ACCESS_KEY=<secret>
AWS_DEFAULT_REGION=<region>

```

For TFE you need additional piece of code in order to be able to destroy the resources later:

```
resource "null_resource" "local_install_on_destroy" {
provisioner "local-exec" {
command = "bash ${path.module}/install-all.sh"
when  = "destroy"
}
}
```
RUN
