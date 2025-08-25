# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project
COPY OrderService.sln ./
COPY OrderService/OrderService.csproj OrderService/

# Restore
RUN dotnet restore OrderService.sln

# Copy everything
COPY . ./

# Publish
RUN dotnet publish OrderService/OrderService.csproj -c Release -o /app

# Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app ./
ENV ASPNETCORE_URLS=http://+:80
ENTRYPOINT ["dotnet", "OrderService.dll"]
