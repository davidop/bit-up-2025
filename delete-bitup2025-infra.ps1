param(
    [string]$Location           = "northeurope",
    [string]$TemplateFile       = "main.bicep",
    [string]$ParameterFile      = "main.bicepparam",
    [string]$DeploymentName     = "bicep-bitup2025-deployment",
    [string]$StoragePrefix      = "demostg",
    [string]$SubscriptionId     = "d1836173-d451-4210-b565-5cb14f7b2e7e"
)

# Comprobar que la CLI de Azure (az) está instalada
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error "No se encuentra la CLI de Azure ('az'). Instala la Azure CLI y vuelve a intentarlo."
    exit 1
}

# Comprobar si el usuario está logueado en az
az account show > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "No parece que estés logueado en Azure (az). Iniciando sesión..."
    az login | Out-Null
}

# Establecer suscripción activa
Write-Host "Usando suscripción: $SubscriptionId"
az account set --subscription $SubscriptionId

Write-Host "Eliminando el grupo rg-owasp-juiceshop-bitup2025..."
az group delete --name rg-owasp-juiceshop-bitup2025 --yes --no-wait
Write-Host "Eliminacion lanzado. Revisa la salida de 'az' para confirmar el estado."
Write-Host "Eliminando peerings en la red hub..."
az network vnet peering delete --name "vnet-bitup2025-hub-northeu-01-to-vnet-bitup2025-appgw-ne" --resource-group "rg-connectivity-bitup2025" --vnet-name "vnet-bitup2025-hub-northeu-01"
az network vnet peering delete --name "vnet-bitup2025-hub-northeu-01-to-vnet-bitup2025-webapp-juice-shop-ne" --resource-group "rg-connectivity-bitup2025" --vnet-name "vnet-bitup2025-hub-northeu-01"
Write-Host "Eliminacion lanzado. Revisa la salida de 'az' para confirmar el estado."