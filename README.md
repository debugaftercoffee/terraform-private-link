# terraform_private_link
Example of how to use private link to securely connect to PaaS services. The module `private_endpoint_with_dns` creates a Private DNS Zone and Private Endpoint to the PaaS resource. If the PaaS resource has multiple endpoints, or has multiple regions, then there will be a DNS entry for each endpoint or region in the Private DNS Zone. 

To initialize the project run:
```
terraform init
```

Edit `test-env.tfvars` to set the name of the resource group and location of resources. The run `terraform apply` referencing the file you edited:
```
terraform apply --var-file test-env.tfvars
```

To delete all resources run:
```
terraform destroy --var-file test-env.tfvars
```