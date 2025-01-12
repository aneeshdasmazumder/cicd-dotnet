# Stage 1: Build the application
# Use an official .NET SDK image for building and compiling the application.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy only the .csproj file(s) and restore dependencies.
# This step is optimized for caching; Docker will reuse the cache if the project file hasn't changed.
COPY DotNetCoreApp/*.csproj ./DotNetCoreApp/
RUN dotnet restore DotNetCoreApp/DotNetCoreApp.csproj

# Copy the remaining source files into the container.
# This step is separated to optimize caching when source files change.
COPY DotNetCoreApp/. ./DotNetCoreApp/
WORKDIR /app/DotNetCoreApp

# Build and publish the application.
# Produces an optimized, self-contained application for production.
RUN dotnet publish -c Release -o out --no-restore

# Stage 2: Create the runtime image
# Use the official ASP.NET runtime image, optimized for running ASP.NET Core apps.
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Copy the published application from the build stage.
COPY --from=build /app/DotNetCoreApp/out ./out

# Set the user to a non-root user (optional for enhanced security).
# USER appuser

# Expose the application port.
EXPOSE 5000

# Define the entry point for the application.
ENTRYPOINT ["dotnet", "./out/DotNetCoreApp.dll"]
