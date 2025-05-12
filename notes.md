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
- [ ] managed identity


```
az acr login --name ktstagingacr
docker build --platform=linux/amd64 -t ktstagingacr.azurecr.io/ktsite1:latest c:/dev/webapp/.      
docker push ktstagingacr.azurecr.io/ktsite1:latest
```
