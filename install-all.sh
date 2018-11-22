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

popd

exec 1>&5

