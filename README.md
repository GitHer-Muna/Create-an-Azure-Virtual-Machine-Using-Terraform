# Creating an Azure Virtual Machine Using Terraform

**A Step-by-Step Technical Guide for Aspiring DevOps Engineers**

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [What You'll Learn](#what-youll-learn)
3. [Prerequisites](#prerequisites)
4. [Architecture Overview](#architecture-overview)
5. [Step-by-Step Implementation](#step-by-step-implementation)
6. [Verification and Testing](#verification-and-testing)
7. [Resource Cleanup](#resource-cleanup)
8. [Troubleshooting](#troubleshooting)
9. [Key Learnings](#key-learnings)
10. [Next Steps](#next-steps)

---

## 🎯 Introduction

This guide demonstrates how to provision a complete Azure Virtual Machine infrastructure using Terraform, showcasing Infrastructure as Code (IaC) principles that are fundamental to modern DevOps practices.

**What is Infrastructure as Code?**

Infrastructure as Code (IaC) is the practice of managing and provisioning infrastructure through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools. Terraform is one of the most popular IaC tools.

**Why Terraform for Azure?**

- **Declarative Syntax**: Define what you want, not how to create it
- **State Management**: Tracks your infrastructure and manages dependencies
- **Idempotent**: Running the same configuration multiple times produces the same result
- **Provider Ecosystem**: Works across multiple cloud providers
- **Version Control**: Infrastructure changes can be reviewed and tracked

---

## 📚 What You'll Learn

By the end of this tutorial, you will:

- ✅ Understand Terraform's core concepts (providers, resources, variables, outputs)
- ✅ Set up a complete Azure networking infrastructure
- ✅ Deploy a Linux Virtual Machine with proper security configurations
- ✅ Use Terraform best practices for managing credentials
- ✅ Verify deployments using Azure CLI
- ✅ Clean up resources to avoid unwanted charges

---

## 🔧 Prerequisites

### Required Tools

1. **Terraform** (v1.0+)
2. **Azure CLI** (v2.0+)
3. **Active Azure Subscription**
4. **Code Editor** (VS Code recommended)
5. **Git** (for version control)

### Required Knowledge

- Basic understanding of cloud computing concepts
- Familiarity with command-line interfaces
- Basic networking knowledge (VNets, subnets, IP addresses)
- Understanding of SSH and remote access

### Azure Account Setup

You need an Azure account with:
- Active subscription
- Permissions to create resources
- Logged in via Azure CLI

---

## 🏗️ Architecture Overview

### Infrastructure Components

This Terraform configuration creates the following Azure resources:

```
┌─────────────────────────────────────────────────────────┐
│                    Resource Group                        │
│  ┌───────────────────────────────────────────────────┐  │
│  │              Virtual Network (10.0.0.0/16)        │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │      Subnet (10.0.1.0/24)                   │  │  │
│  │  │  ┌──────────────────────────────────────┐   │  │  │
│  │  │  │   Network Interface                  │   │  │  │
│  │  │  │   ┌──────────────────────────────┐   │   │  │  │
│  │  │  │   │   Linux VM (Ubuntu 18.04)    │   │   │  │  │
│  │  │  │   │   - Standard_B1s             │   │   │  │  │
│  │  │  │   │   - Password Authentication  │   │   │  │  │
│  │  │  │   └──────────────────────────────┘   │   │  │  │
│  │  │  └──────────────────────────────────────┘   │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  │                                                     │  │
│  │  Network Security Group                            │  │
│  │  - Allow SSH (Port 22)                             │  │
│  │                                                     │  │
│  │  Public IP (Static)                                │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Resource Breakdown

| Resource | Purpose | Configuration |
|----------|---------|---------------|
| **Resource Group** | Logical container for all resources | Location: East US |
| **Virtual Network** | Isolated network environment | Address Space: 10.0.0.0/16 |
| **Subnet** | Network segment within VNet | Address Prefix: 10.0.1.0/24 |
| **Public IP** | Internet-facing IP address | Allocation: Static, SKU: Standard |
| **Network Security Group** | Firewall rules | Allow: SSH (22) |
| **Network Interface** | Connects VM to network | Dynamic private IP |
| **Linux VM** | Ubuntu 18.04 LTS virtual machine | Size: Standard_B1s (1 vCPU, 1GB RAM) |

---

## 🚀 Step-by-Step Implementation

### Step 1: Project Setup

Create your project directory:

```bash
mkdir terraform-azure-vm
cd terraform-azure-vm
```

![alt text](image.png)

---

### Step 2: Install Terraform

**For Ubuntu/Debian:**

```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install Terraform
sudo apt update && sudo apt install terraform -y

# Verify installation
terraform --version
```

![alt text](image-1.png)

**For macOS:**

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform --version
```

**For Windows:**

Download from [terraform.io](https://www.terraform.io/downloads) and add to PATH.

---

### Step 3: Install Azure CLI

**For Ubuntu/Debian:**

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az --version
```

![alt text](image-2.png)

**For macOS:**

```bash
brew install azure-cli
```

**For Windows:**

Download MSI installer from [Microsoft Docs](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows)

---

### Step 4: Authenticate with Azure

```bash
az login
```

**What happens:**
1. Browser window opens
2. Sign in with Azure credentials
3. Terminal displays your subscriptions

![alt text](image-3.png)

![alt text](image-4.png)

**Alternative - Device Code Flow:**

```bash
az login --use-device-code
```

---

### Step 5: Create main.tf

Create `main.tf` with the following content:

```hcl
# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Azure-VM"
  }
}

# Create Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = "Learning"
  }
}

# Create Subnet
resource "azurerm_subnet" "main" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Public IP
resource "azurerm_public_ip" "main" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = "Learning"
  }
}

# Create Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = var.nsg_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Learning"
  }
}

# Create Network Interface
resource "azurerm_network_interface" "main" {
  name                = var.nic_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = {
    Environment = "Learning"
  }
}

# Associate NSG with Network Interface
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Create Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                  = var.vm_name
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  size                  = var.vm_size

  # Ubuntu 18.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # OS Disk
  os_disk {
    name                 = "${var.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Username and Password Authentication
  computer_name                   = var.vm_name
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  tags = {
    Environment = "Learning"
  }
}
```

**Key Concepts Explained:**

- **terraform block**: Specifies required providers and versions
- **provider block**: Configures the Azure provider
- **resource blocks**: Define infrastructure components
- **var.xxx**: References variables defined in variables.tf
- **resource references**: `azurerm_resource_group.main.location` gets the location from resource group

---

### Step 6: Create variables.tf

Create `variables.tf`:

```hcl
# Variable definitions for Azure VM deployment

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-terraform-vm"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "vnet-terraform-vm"
}

variable "subnet_name" {
  description = "Name of the Subnet"
  type        = string
  default     = "subnet-terraform-vm"
}

variable "public_ip_name" {
  description = "Name of the Public IP"
  type        = string
  default     = "pip-terraform-vm"
}

variable "nsg_name" {
  description = "Name of the Network Security Group"
  type        = string
  default     = "nsg-terraform-vm"
}

variable "nic_name" {
  description = "Name of the Network Interface Card"
  type        = string
  default     = "nic-terraform-vm"
}

variable "vm_name" {
  description = "Name of the Virtual Machine"
  type        = string
  default     = "vm-terraform-ubuntu"
}

variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the Virtual Machine"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Admin password for the Virtual Machine"
  type        = string
  sensitive   = true
}
```

**Variable Types:**
- `string`: Text values
- `sensitive`: Prevents values from being displayed in logs
- `default`: Value used if not explicitly set

---

### Step 7: Create outputs.tf

Create `outputs.tf`:

```hcl
# Output values to display after deployment

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "public_ip_address" {
  description = "Public IP address of the Virtual Machine"
  value       = azurerm_public_ip.main.ip_address
}

output "vm_name" {
  description = "Name of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "ssh_connection_string" {
  description = "SSH connection command"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
  sensitive   = true
}
```

**Why Outputs?**
- Display important information after deployment
- Can be used by other Terraform configurations
- Marked as `sensitive` to protect credentials

---

### Step 8: Create terraform.tfvars

Create `terraform.tfvars` (this file contains your actual values):

```hcl
# Variable values for deployment

resource_group_name = "rg-terraform-vm"
location            = "East US"
vnet_name           = "vnet-terraform-vm"
subnet_name         = "subnet-terraform-vm"
public_ip_name      = "pip-terraform-vm"
nsg_name            = "nsg-terraform-vm"
nic_name            = "nic-terraform-vm"
vm_name             = "vm-terraform-ubuntu"
vm_size             = "Standard_B1s"

# IMPORTANT: Replace with your own secure credentials
admin_username = "azureuser"
admin_password = "YourSecurePassword123!"
```

**⚠️ Security Warning:**
- Change the password to something secure
- Password must be 12-72 characters
- Must include uppercase, lowercase, numbers, and special characters
- This file will NOT be committed to git (protected by .gitignore)

---

### Step 9: Create .gitignore

Create `.gitignore` to protect sensitive files:

```
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files (contains passwords)
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore tfplan files
*tfplan*

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Ignore Mac .DS_Store files
.DS_Store
```

**Why This Matters:**
- Prevents committing passwords to GitHub
- Protects state files that contain infrastructure details
- Industry best practice for Terraform projects

---

### Step 10: Initialize Terraform

```bash
terraform init
```

**What happens:**
- Downloads Azure provider plugin
- Creates `.terraform` directory
- Creates `.terraform.lock.hcl` (dependency lock file)

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "~> 3.0"...
- Installing hashicorp/azurerm v3.x.x...
Terraform has been successfully initialized!
```

---

### Step 11: Validate Configuration

```bash
terraform validate
```

**Expected Output:**
```
Success! The configuration is valid.
```

**If you see errors:**
- Check for syntax errors in .tf files
- Ensure all required variables are defined
- Verify sensitive outputs are marked correctly

---

### Step 12: Format Code

```bash
terraform fmt
```

**What it does:**
- Automatically formats your .tf files
- Ensures consistent style
- Best practice before committing code

---

### Step 13: Plan Deployment

```bash
terraform plan
```

**What happens:**
- Terraform analyzes your configuration
- Shows what will be created/changed/destroyed
- No actual changes are made yet

**Expected Output:**
```
Terraform will perform the following actions:

  # azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "rg-terraform-vm"
      ...
    }

  # ... (6 more resources)

Plan: 7 to add, 0 to change, 0 to destroy.
```

**Review Carefully:**
- Verify resource names are correct
- Check that location is appropriate
- Confirm VM size fits your budget

---

### Step 14: Apply Configuration (Deploy!)

```bash
terraform apply
```

When prompted, type `yes` to confirm.

![alt text](image-5.png)

![alt text](image-6.png)

**What happens:**
- Creates all 7 Azure resources
- Takes 5-10 minutes to complete
- Displays outputs when finished

**Expected Output:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.main: Creating...
azurerm_resource_group.main: Creation complete after 2s
azurerm_virtual_network.main: Creating...
...
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

public_ip_address = "xx.xx.xx.xx"
resource_group_name = "rg-terraform-vm"
vm_name = "vm-terraform-ubuntu"
```

---

## ✅ Verification and Testing

### Step 15: View Outputs

```bash
terraform output
```

![alt text](image-7.png)

**Display specific output:**

```bash
terraform output public_ip_address
```

---

### Step 16: Verify with Azure CLI

```bash
az vm list -d --query "[].{Name:name, Status:powerState}" --output table
```

![alt text](image-8.png)

**Expected Output:**
```
Name                  Status
--------------------  ---------
vm-terraform-ubuntu   VM running
```

**Additional verification commands:**

```bash
# List all resources in resource group
az resource list --resource-group rg-terraform-vm --output table

# Get VM details
az vm show --name vm-terraform-ubuntu --resource-group rg-terraform-vm

# Get public IP
az network public-ip show --name pip-terraform-vm --resource-group rg-terraform-vm --query ipAddress
```

---

### Step 17: Test SSH Connection (Optional)

⚠️ **Security Note:** Only do this if you need to verify VM access.

```bash
ssh azureuser@<your-public-ip>
```

Replace `<your-public-ip>` with the IP from terraform output.

**First-time connection:**
- You'll see a fingerprint warning - type `yes`
- Enter the password from your terraform.tfvars

**Once connected:**
```bash
# Check OS version
cat /etc/os-release

# Check hostname
hostname

# Exit SSH
exit
```

---

## 🧹 Resource Cleanup

**⚠️ IMPORTANT:** Always destroy resources when you're done to avoid charges!

### Step 18: Destroy Infrastructure

```bash
terraform destroy
```

Type `yes` when prompted.

![alt text]({3FE610A0-1ACE-4EF1-AF69-8F49E709EEF3}.png)

![alt text](image-10.png)

**What happens:**
- Deletes all 7 resources in reverse dependency order
- Takes 3-5 minutes
- Cannot be undone!

**Expected Output:**
```
Terraform will perform the following actions:

  # azurerm_linux_virtual_machine.main will be destroyed
  # ... (6 more resources)

Plan: 0 to add, 0 to change, 7 to destroy.

Do you really want to destroy all resources?
  Enter a value: yes

...
Destroy complete! Resources: 7 destroyed.
```

---

### Step 19: Verify Cleanup

```bash
az vm list -d --query "[].{Name:name, Status:powerState}" --output table
```

Should return empty or not show your VM.

```bash
az resource list --resource-group rg-terraform-vm
```

Should return an error (resource group doesn't exist).

---

## 🐛 Troubleshooting

### Common Issues and Solutions

#### Issue 1: "Error: building account" during apply

**Cause:** Azure CLI not logged in or expired session

**Solution:**
```bash
az login
az account show
```

---

#### Issue 2: "Error: A resource with the ID already exists"

**Cause:** Resources from previous deployment still exist

**Solution:**
```bash
terraform destroy
# Wait for completion
terraform apply
```

---

#### Issue 3: "Error: Insufficient Regional Quota"

**Cause:** Your subscription doesn't have capacity for the VM size

**Solution:**
- Change VM size in terraform.tfvars to smaller size (e.g., Standard_B1s)
- Or request quota increase from Azure portal

---

#### Issue 4: "Error: Password does not meet complexity requirements"

**Cause:** Password in terraform.tfvars is too simple

**Solution:**
- Use at least 12 characters
- Include uppercase, lowercase, numbers, and symbols
- Example: `Terraform@Azure2024!`

---

#### Issue 5: Terraform state is locked

**Cause:** Previous terraform operation was interrupted

**Solution:**
```bash
# Wait 15 minutes for lock to auto-release
# OR force unlock (use carefully!)
terraform force-unlock <lock-id>
```

---

#### Issue 6: "Error: Output refers to sensitive values"

**Cause:** Output contains sensitive variables but not marked sensitive

**Solution:** Add `sensitive = true` to the output block in outputs.tf

---

## 🎓 Key Learnings

### Terraform Concepts Mastered

1. **Providers**: How to configure cloud provider connections
2. **Resources**: Defining infrastructure components
3. **Variables**: Parameterizing configurations for reusability
4. **Outputs**: Exposing important values post-deployment
5. **State Management**: How Terraform tracks infrastructure
6. **Dependencies**: Implicit dependencies through resource references

### Azure Concepts Learned

1. **Resource Groups**: Logical containers for Azure resources
2. **Virtual Networks**: Isolated network environments
3. **Subnets**: Network segmentation within VNets
4. **Network Security Groups**: Firewall rule management
5. **Public IPs**: Internet-facing addresses
6. **Virtual Machines**: Compute resources in the cloud

### DevOps Best Practices

1. ✅ **Infrastructure as Code**: All infrastructure defined in version-controlled files
2. ✅ **Secret Management**: Sensitive data protected via .gitignore and sensitive variables
3. ✅ **Idempotency**: Same configuration produces same result
4. ✅ **Declarative Configuration**: Describe desired state, not steps
5. ✅ **Resource Tagging**: Organized resources with metadata
6. ✅ **Cost Management**: Remember to destroy unused resources

---

## 🚀 Next Steps

### Beginner Level

1. **Modify the configuration:**
   - Change VM size to Standard_B2s (2 vCPUs)
   - Deploy to a different region (West US)
   - Add more NSG rules (allow HTTP port 80)

2. **Add more outputs:**
   - Private IP address
   - VM size
   - OS disk name

### Intermediate Level

3. **Enhance security:**
   - Use SSH keys instead of passwords
   - Implement Azure Key Vault for secrets
   - Restrict NSG to specific IP addresses

4. **Add monitoring:**
   - Enable boot diagnostics
   - Add Azure Monitor alerts
   - Configure log analytics

### Advanced Level

5. **Multi-environment setup:**
   - Create dev/staging/prod workspaces
   - Use Terraform modules
   - Implement remote state with Azure Storage

6. **CI/CD Integration:**
   - Automate with GitHub Actions
   - Implement terraform plan on pull requests
   - Auto-apply on merge to main

7. **Advanced networking:**
   - Add load balancer
   - Create VM scale sets
   - Implement VNet peering

---

## 📚 Additional Resources

### Official Documentation

- [Terraform Documentation](https://www.terraform.io/docs)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)

### Learning Resources

- [HashiCorp Learn - Terraform](https://learn.hashicorp.com/terraform)
- [Microsoft Learn - Azure](https://docs.microsoft.com/en-us/learn/azure/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### Community

- [Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-core)
- [Azure Reddit Community](https://reddit.com/r/AZURE)
- [DevOps Stack Exchange](https://devops.stackexchange.com/)

---

## 📝 License

This project is open source and available under the MIT License.

---

## 💬 Feedback

Found this helpful? Have suggestions? Feel free to:
- ⭐ Star this repository
- 🐛 Open an issue for bugs
- 💡 Submit a pull request for improvements
- 📧 Reach out on LinkedIn

---

**Happy Learning! 🎉**

Remember: The best way to learn is by doing. Don't just copy-paste - understand each resource, experiment with different configurations, and break things (in a safe environment)!

---

*Last Updated: November 2025*
