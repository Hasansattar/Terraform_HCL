
## Folder structure



```python
├── main.tf # Main Terraform resources file 
├── provider.tf #  Configure the AWS provider
├── variables.tf # Variables used in the configuration (optional) 
├── outputs.tf # Outputs from the resources (optional) 
└── config # custom configuration for development, production and staging
  └── development.tfvars # developemnt configuration code
  └── production.tfvars # production configuration code
  └── staging.tfvars # staging configuration code
```

### Steps for Creating Terraform Infrastructure
1- Make main file **main.tf** 

2- Put Aws provider into **provider.tf**  
 you can add multiple providers in this configuration

3- Run **terraform init** for initialization

4-  **terraform --help** 
Check complete detail with flag --help

5- Run **terraform plan**

6- Run **terraform apply**


### Add Ec2 Instance into main.tf and put their variables belongs to variables.tf, and output of Instance store in output.tf

7 - RUN **terraform validate**
validate the code

8- Run **terraform plan**
Confirmation the plan of resource creation

9- Run **terraform apply**
Apply the plan

10- Run **terraform destroy**
Destroy the resources



**NOTE:**  Set your environment variables:  
In your terminal, you can export the AWS credentials like this: 
Environment variables should be start with **TF_VAR_your_variable_name**
```python
export TF_VAR_AWS_ACCESS_KEY_ID="ACCESS_KEY"
export TF_VAR_AWS_SECRET_ACCESS_KEY="SECRET_ACCESS"
```


#### Config file for staging,production and development environment

11- RUN **terraform plan -var-file="config/production.tfvars"**

#### Check the Outputs
12-RUN **teraform output**