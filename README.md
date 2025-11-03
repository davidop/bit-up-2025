# BitUp 2025 - Azure Infrastructure as Code

This repository contains Azure Bicep templates for deploying a secure, production-ready Azure infrastructure with hub-and-spoke network topology, including an OWASP Juice Shop workload demonstration.

## 🏗️ Architecture Overview

The infrastructure implements a **hub-and-spoke network architecture** with the following components:

### Hub Network (Connectivity)
- **Azure Firewall**: Central network security with forced tunneling
- **VPN Gateway**: Point-to-site VPN for secure remote access
- **Private DNS Zones**: Internal DNS resolution
- **Network Watcher**: Network monitoring and diagnostics

### Spoke Network (OWASP Juice Shop Workload)
- **Application Gateway with WAF**: Web application firewall protection
- **Azure Web App**: Containerized OWASP Juice Shop application
- **Private Endpoints**: Secure connectivity without public exposure
- **Virtual Network Integration**: Secure outbound connectivity

### Management & Monitoring
- **Log Analytics Workspaces**: Centralized logging
- **Diagnostic Settings**: Comprehensive monitoring across all resources
- **Flow Logs**: Network traffic analysis
- **Storage Accounts**: Network watcher logs and diagnostics

## 📁 Repository Structure

```
.
├── main.bicep                          # Main orchestration template
├── main.bicepparam                     # Parameters file
├── deploy-bitup2025-infra.ps1         # Deployment script
├── delete-bitup2025-infra.ps1         # Cleanup script
├── subscriptionCommands.ps1            # Subscription utilities
├── modules/                            # Reusable Bicep modules
│   ├── appgw-waf-template.bicep       # Application Gateway with WAF
│   ├── azfirewall-template.bicep      # Azure Firewall
│   ├── azprivatedns-template.bicep    # Private DNS Zones
│   ├── flowlog-template.bicep         # Network flow logs
│   ├── loganalytics-*.bicep           # Log Analytics workspaces
│   ├── networkwatcher-*.bicep         # Network Watcher components
│   ├── peering-template.bicep         # Virtual network peering
│   ├── privatendpoint-template.bicep  # Private endpoints
│   ├── publicipaddress-template.bicep # Public IP addresses
│   ├── resourcegroup-template.bicep   # Resource groups
│   ├── storage*.bicep                 # Storage accounts
│   ├── vnet-*.bicep                   # Virtual networks
│   ├── vpngateway-*.bicep             # VPN Gateway
│   └── webapp-template.bicep          # Web App (container)
├── submains/                           # Scoped deployment templates
│   ├── connectivity-main.bicep        # Hub/connectivity layer
│   ├── management-main.bicep          # Monitoring layer
│   └── owaspjuiceshop-main.bicep     # Workload layer
└── presentation/                       # Documentation/slides
```

## 🚀 Prerequisites

Before deploying, ensure you have:

1. **Azure CLI** installed ([Download](https://learn.microsoft.com/cli/azure/install-azure-cli))
2. **Azure subscription** with appropriate permissions
3. **Bicep CLI** (installed automatically with Azure CLI)
4. **PowerShell** (for deployment scripts)

## 📝 Configuration

1. **Update Parameters**: Edit `main.bicepparam` to customize:
   - Location/region
   - Network address spaces
   - Resource naming
   - Azure AD tenant ID for VPN
   - Firewall rules
   - Container image for Juice Shop

2. **Update Deployment Script**: Modify `deploy-bitup2025-infra.ps1`:
   ```powershell
   param(
       [string]$Location           = "northeurope",
       [string]$SubscriptionId     = "your-subscription-id"
   )
   ```

## 🎯 Deployment

### Quick Deployment

Run the deployment script:

```powershell
.\deploy-bitup2025-infra.ps1
```

### Manual Deployment

```powershell
# Login to Azure
az login

# Set subscription
az account set --subscription "your-subscription-id"

# Deploy infrastructure
az deployment sub create \
  --name "bicep-bitup2025-deployment" \
  --location "northeurope" \
  --template-file "main.bicep" \
  --parameters "main.bicepparam"
```

### What Gets Deployed

The deployment creates:
- 3 Resource Groups (connectivity, management, workload)
- Hub virtual network with Azure Firewall and VPN Gateway
- Spoke virtual networks with Application Gateway and Web App
- Private DNS zones and virtual network links
- Log Analytics workspaces with diagnostic settings
- Storage accounts for Network Watcher
- Private endpoints for secure connectivity

## 🧹 Cleanup

To remove all deployed resources:

```powershell
.\delete-bitup2025-infra.ps1
```

## 🔐 Security Features

- **Zero Trust Network**: All traffic inspected by Azure Firewall
- **WAF Protection**: Application Gateway with OWASP rule set
- **Private Endpoints**: No public exposure of backend services
- **Forced Tunneling**: All internet traffic through firewall
- **VPN Access**: Secure P2S VPN with Azure AD authentication
- **Network Segmentation**: Hub-and-spoke isolation
- **Diagnostic Logging**: Comprehensive audit trail

## 📊 Monitoring

The infrastructure includes:
- Azure Monitor integration
- Log Analytics workspaces for each layer
- Diagnostic settings on all critical resources
- Network Watcher flow logs
- Application Insights ready integration

## 🛠️ Customization

### Adding New Workloads

1. Create a new submain in `submains/`
2. Add parameters to `main.bicep` and `main.bicepparam`
3. Create required modules or reuse existing ones
4. Add peering to hub network

### Modifying Firewall Rules

Edit the `fwNetworkRulesList` and `fwApplicationRulesList` in `main.bicepparam`:

```bicep
param fwNetworkRulesList = [
  {
    name: 'your-rule-name'
    sourceAddresses: ['10.20.0.0/16']
    destinationAddresses: ['*']
    destinationPorts: ['443']
    protocols: ['TCP']
  }
]
```

## 📚 Resources

- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Hub-spoke network topology](https://learn.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Azure Firewall Documentation](https://learn.microsoft.com/azure/firewall/)
- [Azure Application Gateway WAF](https://learn.microsoft.com/azure/web-application-firewall/ag/ag-overview)

## 📄 License

This project is provided as-is for educational and demonstration purposes.

## 👥 Contributing

Contributions are welcome! Please submit pull requests or open issues for any improvements.

---

**Note**: This infrastructure includes the OWASP Juice Shop application for security training and testing purposes. Do not expose it to the public internet without proper security controls.
