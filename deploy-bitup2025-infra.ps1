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

# Desplegar plantilla Bicep a nivel suscripción
Write-Host "Desplegando '$TemplateFile' a nivel suscripción con despliegue '$DeploymentName' (location: $Location)..."
az deployment sub create `
    --name $DeploymentName `
    --location $Location `
    --template-file $TemplateFile `
    --parameters $ParameterFile `
    --query "{status:properties.provisioningState, finishTime:properties.timestamp}" `
    --output table

Write-Host "Despliegue lanzado. Revisa la salida de 'az' para confirmar el estado."
