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
1. Install kubectl and aws-iam-auth with the install-all.sh script:

2.    export KUBECONFIG=config
3.    kubectl apply -f config_map_aws_auth.yaml
4.    kubectl get svc
5.    Create terraform kubernetes resource and init, apply or use the kubectl



TO USE IN TFE:

 Once the cluster is created and you have the config file :

1. Create a repo and place the desired kubernetes resources in main.tf 
2. Connect VCS with TFE
3. create variables
```
KUBECONFIG=/terraform/config
AWS_ACCESS_KEY_ID=<id>
AWS_SECRET_ACCESS_KEY=<secret>
AWS_DEFAULT_REGION=<region>

```

For TFE you need additional piece of code in order to be able to plan,create and destroy the resources since binaries need to be installed in the worker on every spin:

```
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
```
RUN
