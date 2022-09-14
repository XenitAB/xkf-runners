# xkf-runners

Code to build Azure images for Github Actions Runners and Azure Devops Agent Pools. The images will be published
to a shared image gallery. The shared image gallery is expected to be set up with image definitions for `azdo-agent`
and `github-runner`.

## Build images

### Authentication through Azure CLI

Make sure that `az login` is done before running a build:

```Bash
PKR_VAR_use_azure_cli_auth=true \
PKR_VAR_version=x.x.x \
PKR_VAR_resource_group=xxxxxxxxxx \
make azdo-agent
```

### Using Service Principal

```Bash
PKR_VAR_client_id=xxxxxxxxxx \
PKR_VAR_client_secret=xxxxxxxxxx \
PKR_VAR_subscription_id=xxxxxxxxxx \
PKR_VAR_resource_group=xxxxxxxxxx \
PKR_VAR_version=x.x.x \
make github-runner
```
