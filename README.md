# Infra automation with OpenTofu

This repository stores OpenTofu files to automate provisioning the AWS infrastructure.

## How to run OpenTofu

On the project root (meaning, one level higher than this README file), type the following command:

```
# (for dev)
$ make tofu_dev

# (for prod)
$ make tofu_prod
```

If you haven't run `tofu init` yet, you might need to do it beforehand.

