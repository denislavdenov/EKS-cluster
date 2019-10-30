#!/usr/bin/env bash

set -x

#exec 5>&1 &>/dev/null

# from https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html#install-kubectl-linux
curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/kubectl
chmod +x kubectl

# from https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator
chmod +x aws-iam-authenticator

sudo cp aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
sudo cp kubectl /usr/local/bin/kubectl
hash -r

export PATH=$PATH:/terraform


#exec 1>&5

cat <<EOF
{
  "run": "yes"
}
EOF
