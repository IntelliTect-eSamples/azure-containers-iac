- Review general flow
- Assume 1 Server with multiple databases
- Storage account(s)
    - 1 with containers
    - 1 for each use
- Reliability and redundancy concerns? Stick with zone redundant for now.

- git and github, Justin

--- 

- document approach to adding and such

To dos
- [x] push an image
- [x] log analytics
- [ ] backend

- [ ] optional container deploy/chicken v egg

```
az acr login --name kbtstagingacr.azurecr.io
docker build --platform=linux/amd64 -t kbtstagingacr.azurecr.io/ktsite1:latest c:/dev/webapp/.      
docker push kbtstagingacr.azurecr.io/ktsite1:latest
```

https://learn.microsoft.com/en-us/azure/container-apps/storage-mounts?tabs=smb&pivots=azure-cli#azure-files

