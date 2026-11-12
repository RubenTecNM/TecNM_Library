# Stage 1: Compilación de la aplicación .NET 10
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY TecNM.Api.csproj ./
RUN dotnet restore TecNM.Api.csproj
COPY . ./
RUN dotnet publish TecNM.Api.csproj -c Release --no-restore -o /app

# Stage 2: Runtime sobre Debian 13
FROM debian:13 AS final
WORKDIR /app

# Dependencias para ejecutar el runtime de .NET 10 en Debian 13
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libicu-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar runtime de .NET 10
COPY --from=build /usr/share/dotnet /usr/share/dotnet
ENV DOTNET_ROOT=/usr/share/dotnet \
    PATH=$PATH:/usr/share/dotnet \
    DOTNET_RUNNING_IN_CONTAINER=true \
    ASPNETCORE_URLS=http://+:6050

COPY --from=build /app ./

EXPOSE 6050
ENTRYPOINT ["dotnet", "TecNM.Api.dll"]
