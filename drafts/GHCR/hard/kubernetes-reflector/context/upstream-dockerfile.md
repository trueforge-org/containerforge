# emberstack/kubernetes-reflector Dockerfile (upstream)

Source URL(s) + date: https://raw.githubusercontent.com/emberstack/kubernetes-reflector/b26ca679e185e5da9c2ae100ea049e251701c606/src/ES.Kubernetes.Reflector/Dockerfile · fetched 2026-11-27 (pinned commit)

## Build
- Base (final): `mcr.microsoft.com/dotnet/aspnet:10.0`
- SDK build: `mcr.microsoft.com/dotnet/sdk:10.0` (`--platform=$BUILDPLATFORM`)
- build: `dotnet build src/ES.Kubernetes.Reflector/ES.Kubernetes.Reflector.csproj -c Release`
- publish: `dotnet publish ... -o /app/publish --no-build /p:UseAppHost=false`
- Final stage copies /app/publish to /app

## Runtime
- `USER app` (base image non-root user)
- WORKDIR /app
- `EXPOSE 8080`
- `ENTRYPOINT ["dotnet", "ES.Kubernetes.Reflector.dll"]`

## Gotchas
- .NET 10 ASP.NET runtime base.
- No ENV defaults in Dockerfile.
- GitHub releases/latest API call failed (rate limit), so the asset/tag list is not captured. Tag 10.0.81 comes from the chart values.
