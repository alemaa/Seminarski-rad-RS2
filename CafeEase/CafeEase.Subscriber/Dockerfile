FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore "CafeEase.Subscriber/CafeEase.Subscriber.csproj"

FROM build AS publish
RUN dotnet publish "CafeEase.Subscriber/CafeEase.Subscriber.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CafeEase.Subscriber.dll"]
