# Imagen base pura: Debian 13 (Trixie)
FROM debian:13

WORKDIR /app

# 1. Instalar dependencias del sistema requeridas en Debian 13
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    libicu-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar .NET 10 directamente dentro de Debian 13 usando el instalador oficial de Microsoft
RUN curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 10.0 --install-dir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# 3. Configurar variables de entorno de .NET
ENV DOTNET_ROOT=/usr/share/dotnet \
    PATH=$PATH:/usr/share/dotnet \
    DOTNET_RUNNING_IN_CONTAINER=true \
    ASPNETCORE_URLS=http://+:6050

# 4. Copiar código fuente y compilar la aplicación dentro de Debian 13
COPY TecNM.Api.csproj ./
RUN dotnet restore TecNM.Api.csproj

COPY . ./
RUN dotnet publish TecNM.Api.csproj -c Release -o /app/out

WORKDIR /app/out

# Puerto interno solicitado
EXPOSE 6050

# Comando para arrancar el backend en Debian 13
ENTRYPOINT ["dotnet", "TecNM.Api.dll"]
