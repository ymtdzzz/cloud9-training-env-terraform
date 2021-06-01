Cloud9 environment for new employees training with Terraform

```
# clone this repo and cd
$ cd cloud9-training-env-terraform

# 
$ git submodule add https://github.com/hashicorp/terraform-provider-aws.git aws_provider
$ cd aws_provider
$ git fetch origin pull/19195/head:f-aws_cloud9_environment_ec2-ssm_support
$ git checkout f-aws_cloud9_environment_ec2-ssm_support
```
