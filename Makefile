tofu_prod:
	tofu workspace select prod && tofu apply -var-file="tfvars/prod.tfvars"
tofu_dev:
	tofu workspace select dev && tofu apply -var-file="tfvars/dev.tfvars"
tofu_dev_destroy:
	tofu workspace select dev && tofu destroy -var-file="tfvars/dev.tfvars"

