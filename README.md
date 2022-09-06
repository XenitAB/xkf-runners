# xmf-runners

Images for Github Actions Runners and Azure Devops Agent Pools

## Build images

### Authebtication through Azure CLI

Make sure that `az login` is done before running a build:

```Bash
PKR_VAR_use_azure_cli_auth=true \
PKR_VAR_resource_group=rxxxxxxxxxx \
make azdo-agent
```

### Using Service Principal

runner/README.md)

```Bash
PKR_VAR_client_id=xxxxxxxxxx \
PKR_VAR_client_secret=oxxxxxxxxxx \
PKR_VAR_subscription_id=xxxxxxxxxx \
PKR_VAR_resource_group=xxxxxxxxxx \
make azdo-agent
```
