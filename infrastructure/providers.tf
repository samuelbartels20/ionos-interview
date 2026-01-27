terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # IONOS Cloud Provider
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "~> 6.7.0"
    }

    # Random Provider
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.0"
    }
    # Helm Provider
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.0"
    }
    # Kubernetes Provider
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    # TLS Provider
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }

    # Local Provider
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
    # OnePassword Provider
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1.2"
    }
    # AWS Provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.11.0"
    }

  }

} 