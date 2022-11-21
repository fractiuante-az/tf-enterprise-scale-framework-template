# tf-enterprise-scale-framework-template
A template to jumpstart your cloud journey with azure enterprise scale framework

## Project Setup with Terraform

```bash
cd terraform/environments/dev

tf init
tf plan -var-file=./shared.tfvars 
tf apply -var-file=./shared.tfvars --auto-approve

f apply -var-file=./shared.tfvars --auto-approve -destroy 
```