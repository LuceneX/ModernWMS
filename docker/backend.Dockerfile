FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

COPY backend/ModernWMS.sln backend/
COPY backend/ModernWMS.Core/ backend/ModernWMS.Core/
COPY backend/ModernWMS.WMS/ backend/ModernWMS.WMS/
COPY backend/ModernWMS/ backend/ModernWMS/

RUN dotnet restore backend/ModernWMS/ModernWMS.csproj
RUN dotnet publish backend/ModernWMS/ModernWMS.csproj -c Release -o /out --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:7.0-jammy
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get update \
    && apt-get install -y --no-install-recommends sqlite3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /out/ ./
COPY backend/ModernWMS/Database/ensure-sqlite-schema.sh /app/ensure-sqlite-schema.sh
COPY backend/ModernWMS/Database/seed-sqlite.sql /app/seed-sqlite.sql
COPY docker/start-backend.sh /app/start-backend.sh
RUN chmod +x /app/ensure-sqlite-schema.sh /app/start-backend.sh

ENV ASPNETCORE_URLS=http://0.0.0.0:5555
ENV WMS_DB_PATH=/data/wms.db
VOLUME ["/data"]
EXPOSE 5555
ENTRYPOINT ["/app/start-backend.sh"]
