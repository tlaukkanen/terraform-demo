# Terraform on Azure Example

This is a simple example on how Terraform could be used to provision Azure resources. This example provisions app service with SQL database.

## Prerequisites

Make sure you have at least the following installed on your machine:

 - Terraform
 - Azure CLI

You can install these for example with Chocolatey:

  ```
  choco install terraform azure-cli -y
  ```

## Usage

To test these with your Azure subscription you should follow the Terraform workflow of: `init`→`plan`→`apply`

First initialize Terraform in this folder
```
> terraform init
```

Then produce a plan for changing resources to match the current configuration.
```
> terraform plan
```

Apply the changes described by the plan
```
> terraform apply
```

Checkout the Terraform documentation for more details:
* [Terraform on Azure](https://learn.hashicorp.com/tutorials/terraform/infrastructure-as-code?in=terraform/azure-get-started) (at HashiCorp Learn)
* [Terraform Azure Provider examples](https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples/) in GitHub


