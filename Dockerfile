# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy csproj and restore dependencies
COPY DotNetCoreApp/*.csproj ./DotNetCoreApp/
RUN dotnet restore DotNetCoreApp/DotNetCoreApp.csproj

# Copy the remaining files and build the project
COPY DotNetCoreApp/. ./DotNetCoreApp/
WORKDIR /app/DotNetCoreApp
RUN dotnet publish -c Release -o out

# Stage 2: Create the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/DotNetCoreApp/out ./

# Expose the application port
EXPOSE 5000

# Define the entry point for the application
ENTRYPOINT ["dotnet", "DotNetCoreApp.dll"]
