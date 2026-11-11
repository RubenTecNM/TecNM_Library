FROM mcr.microsoft.com/dotnet/sdk:10.0-noble AS build
WORKDIR /src
COPY TecNM.Api.csproj ./
RUN dotnet restore TecNM.Api.csproj
COPY . ./
RUN dotnet publish TecNM.Api.csproj -c Release --no-restore -o /out /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0-noble
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /out ./
USER $APP_UID
EXPOSE 8081
ENTRYPOINT ["dotnet", "TecNM.Api.dll"]
