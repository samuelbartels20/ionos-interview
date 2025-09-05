# IONOS Kubernetes Platform Architecture

## Overview

This repository implements a production-ready Kubernetes platform on IONOS Cloud using GitOps principles with FluxCD. The architecture follows cloud-native best practices with comprehensive observability, security, and automation.

## 🏗️ Infrastructure Architecture

### Overall Infrastructure Diagram

The following diagram shows the complete infrastructure architecture including IONOS Cloud components, external services, and CI/CD pipeline:

```mermaid
graph TB
    subgraph "IONOS Cloud Infrastructure"
        subgraph "Datacenter: k8s-production (de/fra)"
            subgraph "Kubernetes Cluster: ionos-k8s"
                subgraph "Application Node Pool"
                    N1["Worker Node 1<br/>Intel Skylake<br/>4 cores, 20GB RAM<br/>100GB SSD"]
                    N2["Worker Node 2<br/>Intel Skylake<br/>4 cores, 20GB RAM<br/>100GB SSD"]
                    N3["Worker Node 3<br/>Intel Skylake<br/>4 cores, 20GB RAM<br/>100GB SSD"]
                end
                
                subgraph "Storage"
                    SC["Storage Class<br/>ionos-enterprise-ssd"]
                    PV1["PV: WordPress<br/>20Gi"]
                    PV2["PV: Prometheus<br/>20Gi"]
                    PV3["PV: Grafana<br/>10Gi"]
                end
            end
            
            DB["External MariaDB<br/>ma-c2l5k0mgcej7h3ip.mariadb.de-fra.ionos.com<br/>Port: 3306"]
            LB["IONOS Cloud<br/>Load Balancer"]
        end
        
        subgraph "External Services"
            CF["Cloudflare DNS<br/>samcloud.online"]
            LE["Let's Encrypt<br/>Certificate Authority"]
        end
    end
    
    subgraph "External Management"
        OP["1Password<br/>Secret Management"]
        GH["GitHub Repository<br/>samuelbartels20/ionos-interview"]
        TF["Terraform State<br/>AWS S3 Backend"]
    end
    
    subgraph "CI/CD Pipeline"
        GA["GitHub Actions<br/>Infrastructure Deploy"]
        FLUX["FluxCD<br/>GitOps Controller"]
    end
    
    %% Connections
    GH --> FLUX
    FLUX --> N1
    FLUX --> N2
    FLUX --> N3
    GA --> TF
    GA --> OP
    OP --> N1
    DB --> N1
    DB --> N2
    LB --> N1
    LB --> N2
    LB --> N3
    CF --> LB
    LE --> CF
    SC --> PV1
    SC --> PV2
    SC --> PV3
    
    %% Styling
    classDef ionos fill:#0066cc,stroke:#003d7a,stroke-width:2px,color:#fff
    classDef k8s fill:#326ce5,stroke:#1a4c8c,stroke-width:2px,color:#fff
    classDef storage fill:#ff6b35,stroke:#cc5429,stroke-width:2px,color:#fff
    classDef external fill:#28a745,stroke:#1e7e34,stroke-width:2px,color:#fff
    classDef cicd fill:#6f42c1,stroke:#5a2d91,stroke-width:2px,color:#fff
    
    class N1,N2,N3,DB,LB k8s
    class SC,PV1,PV2,PV3 storage
    class CF,LE,OP external
    class GA,FLUX,TF cicd
```

### Cloud Infrastructure (Terraform)

The platform is built on IONOS Cloud infrastructure using Terraform for Infrastructure as Code (IaC):

**Location**: Frankfurt, Germany (`de/fra`)
**Cluster**: `ionos-k8s` running Kubernetes v1.32.6

#### Core Components:

1. **Datacenter**: `k8s-production` in Frankfurt
2. **Kubernetes Cluster**: Managed IONOS Kubernetes Service
3. **Node Pool**: 3 worker nodes (Intel Skylake, 4 cores, 20GB RAM, 100GB SSD)
4. **External Database**: MariaDB managed service
5. **Load Balancer**: IONOS Cloud Load Balancer
6. **Storage**: IONOS Enterprise SSD storage class

#### Network Configuration:
- **API Access**: Restricted to specific IP (`154.161.97.168/32`)
- **Public Cluster**: Internet-accessible with security controls
- **Maintenance Window**: Sundays 10:00 UTC

### Terraform Providers:
- **IONOS Cloud**: Primary infrastructure provider
- **Kubernetes/Helm**: Application deployment
- **1Password**: Secret management
- **AWS**: Additional services (S3 backend)
- **TLS/Local**: Certificate and file management

## 🔄 GitOps Architecture (FluxCD)

### GitOps Workflow Diagram

This diagram illustrates the complete GitOps workflow from development to deployment:

```mermaid
graph TB
    subgraph "GitOps Workflow Architecture"
        subgraph "Source Control"
            DEV["Developer<br/>Local Changes<br/>Git Commit"]
            GH["GitHub Repository<br/>samuelbartels20/ionos-interview<br/>Main Branch"]
            PR["Pull Request<br/>Code Review<br/>CI Validation"]
        end
        
        subgraph "CI/CD Pipeline"
            GA["GitHub Actions<br/>Infrastructure Deploy<br/>Terraform + Validation"]
            WEBHOOK["GitHub Webhook<br/>Push Events<br/>Immediate Sync"]
            RENOVATE["Renovate Bot<br/>Dependency Updates<br/>Automated PRs"]
        end
        
        subgraph "FluxCD GitOps Engine"
            SC["Source Controller<br/>Git Sync<br/>OCI Registry"]
            KC["Kustomize Controller<br/>Manifest Processing<br/>Resource Management"]
            HC["Helm Controller<br/>Chart Deployment<br/>Release Management"]
            NC["Notification Controller<br/>Event Handling<br/>Webhook Management"]
        end
        
        subgraph "Kubernetes Cluster State"
            subgraph "Cluster Applications"
                FLUX_APP["FluxCD<br/>flux-system namespace<br/>GitOps Controllers"]
                OBS["Observability<br/>observability namespace<br/>Prometheus, Grafana, Loki"]
                SEC["Security<br/>security namespace<br/>External Secrets, Trivy"]
                CERT["Certificates<br/>cert-manager namespace<br/>TLS Management"]
                WP["WordPress<br/>services namespace<br/>Application Workload"]
            end
            
            subgraph "Infrastructure Components"
                NODES["Worker Nodes<br/>Application Runtime<br/>Pod Scheduling"]
                STORAGE["Persistent Storage<br/>Data Persistence<br/>Volume Management"]
                NETWORK["Network Policies<br/>Service Mesh Ready<br/>Ingress Control"]
            end
        end
        
        subgraph "Configuration Management"
            SOPS["SOPS Encryption<br/>Age Key<br/>Secret Management"]
            KUSTOMIZE["Kustomization<br/>Manifest Overlays<br/>Environment Config"]
            HELM_CHARTS["Helm Charts<br/>Application Templates<br/>Value Overrides"]
        end
        
        subgraph "External Dependencies"
            OCI["OCI Registries<br/>Helm Charts<br/>Container Images"]
            OP_VAULT["1Password Vault<br/>External Secrets<br/>Credential Management"]
            DNS["DNS Management<br/>Cloudflare<br/>Domain Configuration"]
        end
        
        subgraph "Monitoring & Feedback"
            ALERTS["FluxCD Alerts<br/>Deployment Status<br/>Reconciliation Failures"]
            METRICS["GitOps Metrics<br/>Sync Status<br/>Resource Health"]
            LOGS["FluxCD Logs<br/>Controller Activity<br/>Troubleshooting"]
        end
    end
    
    %% Development Flow
    DEV --> GH
    GH --> PR
    PR --> GA
    GA --> GH
    
    %% GitOps Sync
    GH --> WEBHOOK
    WEBHOOK --> SC
    SC --> KC
    SC --> HC
    KC --> KUSTOMIZE
    HC --> HELM_CHARTS
    
    %% Deployment Flow
    KC --> FLUX_APP
    KC --> OBS
    KC --> SEC
    KC --> CERT
    HC --> WP
    
    %% Infrastructure Management
    FLUX_APP --> NODES
    OBS --> STORAGE
    SEC --> NETWORK
    
    %% Secret Management
    SOPS --> KC
    OP_VAULT --> SEC
    SEC --> WP
    SEC --> OBS
    
    %% External Resources
    HC --> OCI
    CERT --> DNS
    
    %% Monitoring
    FLUX_APP --> ALERTS
    FLUX_APP --> METRICS
    FLUX_APP --> LOGS
    OBS --> METRICS
    
    %% Automation
    RENOVATE --> PR
    NC --> WEBHOOK
    
    %% Configuration
    KUSTOMIZE --> FLUX_APP
    KUSTOMIZE --> OBS
    KUSTOMIZE --> SEC
    HELM_CHARTS --> WP
    
    %% Feedback Loop
    ALERTS -.->|Notifications| DEV
    METRICS -.->|Dashboards| DEV
    
    %% Styling
    classDef source fill:#2ecc71,stroke:#27ae60,stroke-width:2px,color:#fff
    classDef cicd fill:#e74c3c,stroke:#c0392b,stroke-width:2px,color:#fff
    classDef flux fill:#326ce5,stroke:#1a4c8c,stroke-width:2px,color:#fff
    classDef k8s fill:#f39c12,stroke:#e67e22,stroke-width:2px,color:#fff
    classDef config fill:#9b59b6,stroke:#8e44ad,stroke-width:2px,color:#fff
    classDef external fill:#95a5a6,stroke:#7f8c8d,stroke-width:2px,color:#fff
    classDef monitoring fill:#e67e22,stroke:#d35400,stroke-width:2px,color:#fff
    
    class DEV,GH,PR source
    class GA,WEBHOOK,RENOVATE cicd
    class SC,KC,HC,NC flux
    class FLUX_APP,OBS,SEC,CERT,WP,NODES,STORAGE,NETWORK k8s
    class SOPS,KUSTOMIZE,HELM_CHARTS config
    class OCI,OP_VAULT,DNS external
    class ALERTS,METRICS,LOGS monitoring
```

### FluxCD Components

The platform uses FluxCD v2.6.4 for GitOps continuous deployment:

#### Core Controllers:
- **Source Controller**: Git repository and OCI registry management
- **Kustomize Controller**: Kubernetes manifest processing
- **Helm Controller**: Helm chart deployment
- **Notification Controller**: Event notifications and webhooks

#### GitOps Flow:
1. **Git Repository**: `ssh://git@github.com/samuelbartels20/ionos-interview.git`
2. **Branch**: `main` 
3. **Path**: `kubernetes/flux/cluster`
4. **Sync Interval**: 1 hour
5. **Webhook**: GitHub webhook for immediate sync

### Repository Structure:

```
├── infrastructure/          # Terraform IaC
├── kubernetes/
│   ├── apps/               # Application deployments
│   │   ├── cert-manager/   # Certificate management
│   │   ├── flux-system/    # FluxCD components
│   │   ├── kube-system/    # System components
│   │   ├── observability/  # Monitoring stack
│   │   ├── security/       # Security tools
│   │   └── services/       # Application services
│   ├── components/         # Shared components
│   │   └── common/         # Common resources
│   └── flux/              # FluxCD configuration
├── bootstrap/             # Initial setup
└── wordpress/            # WordPress Helm chart
```

## 🔐 Security Architecture

### Security Architecture Diagram

This comprehensive diagram shows all security layers and how they interact:

```mermaid
graph TB
    subgraph "Security Architecture"
        subgraph "Secret Management Layer"
            OP["1Password<br/>Vault<br/>Central Secret Store"]
            OPC["1Password Connect<br/>API + Sync Containers<br/>Kubernetes Integration"]
            ESO["External Secrets<br/>Operator<br/>Secret Synchronization"]
            CSS["ClusterSecretStore<br/>onepassword-connect<br/>Cluster-wide Access"]
            SOPS["SOPS + Age<br/>Git-stored Encrypted<br/>Configuration Secrets"]
        end
        
        subgraph "Container Security"
            TRIVY["Trivy Operator<br/>Vulnerability Scanning<br/>Compliance Checks"]
            PSS["Pod Security Standards<br/>Restricted Policies<br/>Security Contexts"]
            SC["Security Contexts<br/>Non-root Containers<br/>Capability Dropping"]
        end
        
        subgraph "Network Security"
            NP["Network Policies<br/>Micro-segmentation<br/>Zero-trust Networking"]
            GW["Gateway API<br/>Modern Ingress<br/>TLS Termination"]
            CM["Cert-Manager<br/>Automated Certificates<br/>Let's Encrypt"]
        end
        
        subgraph "Access Control"
            RBAC["RBAC<br/>Role-based Access<br/>Least Privilege"]
            SA["Service Accounts<br/>Pod Identity<br/>Token Mounting"]
            API["API Server Security<br/>IP Restrictions<br/>Admission Controllers"]
        end
        
        subgraph "Applications & Workloads"
            WP["WordPress<br/>UID 1001<br/>Capabilities Dropped"]
            FLUX_SEC["FluxCD<br/>Secure GitOps<br/>SSH Key Authentication"]
            GRAF_SEC["Grafana<br/>External Secrets<br/>OAuth Integration"]
        end
        
        subgraph "Infrastructure Security"
            NODE_SEC["Node Security<br/>IONOS Hardening<br/>Restricted SSH"]
            NET_SEC["Network Isolation<br/>Private Subnets<br/>Firewall Rules"]
            STORAGE_SEC["Storage Encryption<br/>At-rest Encryption<br/>Access Controls"]
        end
        
        subgraph "Compliance & Monitoring"
            AUDIT["Audit Logging<br/>API Server Logs<br/>Security Events"]
            SCAN["Security Scanning<br/>Image Vulnerabilities<br/>Runtime Monitoring"]
            POLICY["Policy Enforcement<br/>OPA Gatekeeper Ready<br/>Compliance Validation"]
        end
        
        subgraph "External Integrations"
            CF["Cloudflare<br/>DNS Security<br/>DDoS Protection"]
            LE["Let's Encrypt<br/>Certificate Authority<br/>DNS-01 Challenge"]
            GH["GitHub<br/>SSH Key Auth<br/>Webhook Security"]
        end
    end
    
    %% Secret Flow
    OP --> OPC
    OPC --> CSS
    CSS --> ESO
    ESO --> WP
    ESO --> GRAF_SEC
    SOPS --> FLUX_SEC
    
    %% Security Enforcement
    TRIVY --> WP
    TRIVY --> GRAF_SEC
    PSS --> WP
    PSS --> FLUX_SEC
    SC --> WP
    SC --> OPC
    
    %% Network Security
    NP --> WP
    NP --> FLUX_SEC
    NP --> GRAF_SEC
    GW --> CM
    CM --> CF
    CM --> LE
    
    %% Access Control
    RBAC --> SA
    SA --> WP
    SA --> ESO
    API --> RBAC
    
    %% Monitoring & Compliance
    AUDIT --> SCAN
    SCAN --> POLICY
    TRIVY --> SCAN
    
    %% External Security
    GH --> FLUX_SEC
    CF --> GW
    LE --> CM
    
    %% Infrastructure
    NODE_SEC --> NET_SEC
    NET_SEC --> STORAGE_SEC
    STORAGE_SEC --> WP
    
    %% Styling
    classDef secrets fill:#e74c3c,stroke:#c0392b,stroke-width:2px,color:#fff
    classDef container fill:#f39c12,stroke:#e67e22,stroke-width:2px,color:#fff
    classDef network fill:#3498db,stroke:#2980b9,stroke-width:2px,color:#fff
    classDef access fill:#9b59b6,stroke:#8e44ad,stroke-width:2px,color:#fff
    classDef apps fill:#2ecc71,stroke:#27ae60,stroke-width:2px,color:#fff
    classDef infra fill:#34495e,stroke:#2c3e50,stroke-width:2px,color:#fff
    classDef compliance fill:#e67e22,stroke:#d35400,stroke-width:2px,color:#fff
    classDef external fill:#95a5a6,stroke:#7f8c8d,stroke-width:2px,color:#fff
    
    class OP,OPC,ESO,CSS,SOPS secrets
    class TRIVY,PSS,SC container
    class NP,GW,CM network
    class RBAC,SA,API access
    class WP,FLUX_SEC,GRAF_SEC apps
    class NODE_SEC,NET_SEC,STORAGE_SEC infra
    class AUDIT,SCAN,POLICY compliance
    class CF,LE,GH external
```

### Multi-Layer Security Approach

#### 1. Secret Management
- **1Password Connect**: Centralized secret management
- **External Secrets Operator**: Kubernetes secret synchronization
- **SOPS + Age**: Git-stored encrypted secrets
- **Cluster Secret Store**: Secure secret distribution

#### 2. Container Security
- **Trivy Operator**: Vulnerability scanning and compliance
- **Pod Security Standards**: Enforced security contexts
- **Non-root containers**: All workloads run as non-root
- **Capability dropping**: Minimal container privileges
- **Read-only filesystems**: Where applicable

#### 3. Network Security
- **Network Policies**: Micro-segmentation between namespaces
- **Gateway API**: Modern ingress with security controls
- **TLS Everywhere**: End-to-end encryption
- **Cert-Manager**: Automated certificate lifecycle

#### 4. Access Control
- **RBAC**: Role-based access control
- **Service Accounts**: Least privilege principle
- **API Server Security**: Restricted access by IP
- **Admission Controllers**: Policy enforcement

### Certificate Management

**Cert-Manager** with Let's Encrypt integration:
- **DNS-01 Challenge**: Cloudflare DNS validation
- **Automated Renewal**: 90-day certificate lifecycle
- **ClusterIssuer**: Production Let's Encrypt issuer
- **Wildcard Certificates**: `*.samcloud.online`

##  Observability Architecture

### Observability Stack Diagram

This diagram shows the complete observability architecture with data flow and integrations:

```mermaid
graph TB
    subgraph "Observability Architecture"
        subgraph "Data Collection Layer"
            subgraph "Metrics Collection"
                PROM["Prometheus<br/>Metrics Storage<br/>TSDB"]
                NE["Node Exporter<br/>System Metrics"]
                KSM["Kube-State-Metrics<br/>K8s Object Metrics"]
                AE["Apache Exporter<br/>WordPress Metrics"]
                BE["Blackbox Exporter<br/>Endpoint Monitoring"]
            end
            
            subgraph "Log Collection"
                ALLOY["Grafana Alloy<br/>OpenTelemetry Collector<br/>Log Processing"]
                LOKI["Loki<br/>Log Aggregation<br/>Storage"]
            end
        end
        
        subgraph "Processing & Alerting"
            AM["AlertManager<br/>Alert Routing<br/>Notification Management"]
            SO["Silence Operator<br/>Alert Suppression"]
        end
        
        subgraph "Visualization Layer"
            GRAF["Grafana<br/>Dashboards & Queries<br/>Unified Observability"]
        end
        
        subgraph "External Integrations"
            SLACK["Slack<br/>Notifications"]
            EMAIL["Email<br/>Alerts"]
            WEBHOOK["Webhooks<br/>Custom Integrations"]
        end
        
        subgraph "Monitored Applications"
            WP["WordPress<br/>Application Metrics"]
            FLUX["FluxCD<br/>GitOps Metrics"]
            CERT["Cert-Manager<br/>Certificate Metrics"]
            TRIVY["Trivy Operator<br/>Security Metrics"]
        end
        
        subgraph "Infrastructure Monitoring"
            NODES["Kubernetes Nodes<br/>Resource Usage"]
            PODS["Pods & Containers<br/>Performance Metrics"]
            NET["Network<br/>Traffic & Latency"]
            STORAGE["Storage<br/>IOPS & Capacity"]
        end
    end
    
    %% Data Flow - Metrics
    NE --> PROM
    KSM --> PROM
    AE --> PROM
    BE --> PROM
    WP --> AE
    FLUX --> PROM
    CERT --> PROM
    TRIVY --> PROM
    NODES --> NE
    PODS --> KSM
    NET --> PROM
    STORAGE --> PROM
    
    %% Data Flow - Logs
    WP --> ALLOY
    FLUX --> ALLOY
    PODS --> ALLOY
    ALLOY --> LOKI
    
    %% Alerting Flow
    PROM --> AM
    AM --> SO
    AM --> SLACK
    AM --> EMAIL
    AM --> WEBHOOK
    
    %% Visualization
    PROM --> GRAF
    LOKI --> GRAF
    AM --> GRAF
    
    %% Service Monitors
    PROM -.->|ServiceMonitor| WP
    PROM -.->|ServiceMonitor| FLUX
    PROM -.->|ServiceMonitor| CERT
    PROM -.->|ServiceMonitor| TRIVY
    
    %% Styling
    classDef metrics fill:#e74c3c,stroke:#c0392b,stroke-width:2px,color:#fff
    classDef logs fill:#f39c12,stroke:#e67e22,stroke-width:2px,color:#fff
    classDef alerts fill:#e67e22,stroke:#d35400,stroke-width:2px,color:#fff
    classDef viz fill:#9b59b6,stroke:#8e44ad,stroke-width:2px,color:#fff
    classDef apps fill:#3498db,stroke:#2980b9,stroke-width:2px,color:#fff
    classDef infra fill:#2ecc71,stroke:#27ae60,stroke-width:2px,color:#fff
    classDef external fill:#95a5a6,stroke:#7f8c8d,stroke-width:2px,color:#fff
    
    class PROM,NE,KSM,AE,BE metrics
    class ALLOY,LOKI logs
    class AM,SO alerts
    class GRAF viz
    class WP,FLUX,CERT,TRIVY apps
    class NODES,PODS,NET,STORAGE infra
    class SLACK,EMAIL,WEBHOOK external
```

### Monitoring Stack (Prometheus Ecosystem)

#### Core Components:

1. **Kube-Prometheus-Stack**
   - **Prometheus**: Metrics collection and storage
   - **Alertmanager**: Alert routing and management
   - **Grafana**: Visualization and dashboards
   - **Node Exporter**: System metrics
   - **Kube-State-Metrics**: Kubernetes object metrics

2. **Grafana Alloy** (OpenTelemetry Collector)
   - **Log Collection**: Pod and container logs
   - **Metrics Processing**: Prometheus metrics pipeline
   - **Trace Collection**: Distributed tracing

3. **Loki** (Log Aggregation)
   - **Log Storage**: Efficient log storage
   - **LogQL**: Powerful query language
   - **Retention**: Configurable log retention
   - **Grafana Integration**: Unified observability

4. **Additional Exporters**
   - **Blackbox Exporter**: Endpoint monitoring
   - **Apache Exporter**: Web server metrics
   - **Custom ScrapeConfigs**: External service monitoring

#### Monitoring Targets:
- **Infrastructure**: Nodes, pods, containers
- **Applications**: WordPress, databases, services
- **Network**: Ingress, services, endpoints
- **Security**: Trivy scan results, cert status
- **External**: PiKVM, ZigBee controller, 1Password

### Alerting Strategy

**AlertManager Configuration**:
- **Route**: `alertmanager.samcloud.online`
- **Storage**: 20Gi persistent volume
- **Integration**: External notification systems
- **Silence Operator**: Automated alert suppression

### Log Management

**Centralized Logging Pipeline**:
```
Pod Logs → Alloy → Loki → Grafana
```

**Log Processing**:
- **Structured Logging**: JSON format preferred
- **Label Enrichment**: Namespace, pod, container metadata
- **Filtering**: Noise reduction and sampling
- **Retention**: Configurable per namespace

## 🗄️ Storage Architecture

### Storage Architecture Diagram

This diagram illustrates the complete storage architecture including provisioning, backup, and monitoring:

```mermaid
graph TB
    subgraph "Storage Architecture"
        subgraph "IONOS Cloud Storage"
            ESS["Enterprise SSD<br/>High Performance<br/>Multi-zone Redundancy"]
            SC["Storage Class<br/>ionos-enterprise-ssd<br/>Dynamic Provisioning"]
            SNAP["Snapshot Service<br/>Point-in-time Backups<br/>Cross-region Replication"]
        end
        
        subgraph "Kubernetes Storage Layer"
            CSI["CSI Driver<br/>IONOS Cloud<br/>Volume Management"]
            PVC1["PVC: WordPress<br/>20Gi<br/>ReadWriteOnce"]
            PVC2["PVC: Prometheus<br/>20Gi<br/>ReadWriteOnce"]
            PVC3["PVC: Loki<br/>50Gi<br/>ReadWriteOnce"]
            PVC4["PVC: Grafana<br/>10Gi<br/>ReadWriteOnce"]
            PVC5["PVC: AlertManager<br/>20Gi<br/>ReadWriteOnce"]
        end
        
        subgraph "Application Data"
            WP_DATA["WordPress Data<br/>/bitnami/wordpress<br/>Content & Uploads"]
            PROM_DATA["Prometheus Data<br/>/prometheus<br/>Metrics TSDB"]
            LOKI_DATA["Loki Data<br/>/loki<br/>Log Storage"]
            GRAF_DATA["Grafana Data<br/>/var/lib/grafana<br/>Dashboards & Config"]
            AM_DATA["AlertManager Data<br/>/alertmanager<br/>Alert State"]
        end
        
        subgraph "Backup Strategy"
            DAILY["Daily Snapshots<br/>Automated Schedule<br/>2:00 AM UTC"]
            RETENTION["Retention Policy<br/>30 Days<br/>Point-in-time Recovery"]
            CROSS_REGION["Cross-region Backup<br/>Disaster Recovery<br/>RTO: 4h, RPO: 24h"]
        end
        
        subgraph "Performance & Monitoring"
            METRICS["Storage Metrics<br/>IOPS, Latency<br/>Capacity Usage"]
            ALERTS["Storage Alerts<br/>Disk Full<br/>Performance Degradation"]
            EXPANSION["Dynamic Expansion<br/>Online Resize<br/>No Downtime"]
        end
        
        subgraph "External Storage"
            DB_STORAGE["MariaDB Storage<br/>External Managed<br/>IONOS DBaaS"]
            BACKUP_STORAGE["Backup Storage<br/>S3 Compatible<br/>Long-term Retention"]
        end
    end
    
    %% Storage Provisioning
    ESS --> SC
    SC --> CSI
    CSI --> PVC1
    CSI --> PVC2
    CSI --> PVC3
    CSI --> PVC4
    CSI --> PVC5
    
    %% Data Mounting
    PVC1 --> WP_DATA
    PVC2 --> PROM_DATA
    PVC3 --> LOKI_DATA
    PVC4 --> GRAF_DATA
    PVC5 --> AM_DATA
    
    %% Backup Flow
    PVC1 --> DAILY
    PVC2 --> DAILY
    PVC3 --> DAILY
    PVC4 --> DAILY
    PVC5 --> DAILY
    DAILY --> RETENTION
    RETENTION --> CROSS_REGION
    CROSS_REGION --> BACKUP_STORAGE
    
    %% Monitoring
    CSI --> METRICS
    METRICS --> ALERTS
    PVC1 --> EXPANSION
    PVC2 --> EXPANSION
    PVC3 --> EXPANSION
    
    %% External
    DB_STORAGE -.->|External| WP_DATA
    SNAP --> BACKUP_STORAGE
    
    %% Volume Details
    WP_DATA -.->|"Mount: /bitnami/wordpress<br/>Size: 20Gi<br/>Access: RWO"| PVC1
    PROM_DATA -.->|"Mount: /prometheus<br/>Size: 20Gi<br/>Access: RWO"| PVC2
    LOKI_DATA -.->|"Mount: /loki<br/>Size: 50Gi<br/>Access: RWO"| PVC3
    GRAF_DATA -.->|"Mount: /var/lib/grafana<br/>Size: 10Gi<br/>Access: RWO"| PVC4
    AM_DATA -.->|"Mount: /alertmanager<br/>Size: 20Gi<br/>Access: RWO"| PVC5
    
    %% Styling
    classDef storage fill:#e74c3c,stroke:#c0392b,stroke-width:2px,color:#fff
    classDef k8s fill:#326ce5,stroke:#1a4c8c,stroke-width:2px,color:#fff
    classDef data fill:#f39c12,stroke:#e67e22,stroke-width:2px,color:#fff
    classDef backup fill:#2ecc71,stroke:#27ae60,stroke-width:2px,color:#fff
    classDef monitoring fill:#9b59b6,stroke:#8e44ad,stroke-width:2px,color:#fff
    classDef external fill:#95a5a6,stroke:#7f8c8d,stroke-width:2px,color:#fff
    
    class ESS,SC,SNAP storage
    class CSI,PVC1,PVC2,PVC3,PVC4,PVC5 k8s
    class WP_DATA,PROM_DATA,LOKI_DATA,GRAF_DATA,AM_DATA data
    class DAILY,RETENTION,CROSS_REGION backup
    class METRICS,ALERTS,EXPANSION monitoring
    class DB_STORAGE,BACKUP_STORAGE external
```

### Storage Classes

**Primary**: `ionos-enterprise-ssd`
- **Type**: IONOS Enterprise SSD
- **Performance**: High IOPS, low latency
- **Availability**: Multi-zone redundancy
- **Backup**: Snapshot-based backup

### Persistent Volume Strategy

#### Application Storage:
- **WordPress**: 20Gi for content and uploads
- **Prometheus**: 20Gi for metrics storage
- **Loki**: Configurable log retention
- **Grafana**: Configuration and dashboard storage

#### Backup Strategy:
- **Automated Snapshots**: Daily backups
- **Retention**: 30-day retention policy
- **Cross-region**: Disaster recovery ready
- **Application-aware**: Database consistency


## 🚀 Application Architecture

### WordPress Deployment

**High Availability WordPress**:
- **Replicas**: 2 pods with anti-affinity
- **Node Distribution**: Required separate node placement
- **Database**: External MariaDB managed service
- **Storage**: 20Gi persistent volume
- **Caching**: Redis integration ready
- **Monitoring**: Prometheus ServiceMonitor

#### WordPress Security:
- **Non-root**: UID 1001 execution
- **Capabilities**: All dropped
- **Network Policy**: Restricted communication
- **Secrets**: External secret management
- **Updates**: Controlled via GitOps

### System Components

#### Kube-System Namespace:
- **Metrics Server**: Resource usage metrics
- **Reloader**: Automatic pod restart on config changes
- **Spegel**: Container image caching

#### Flux-System Namespace:
- **FluxCD Controllers**: GitOps automation
- **Webhook Receiver**: GitHub integration
- **Source Repositories**: Chart and manifest sources

## 🔧 Operational Architecture

### Automation and CI/CD

#### GitHub Actions:
- **Infrastructure**: Terraform plan/apply
- **Secret Management**: 1Password integration
- **Security Scanning**: Trivy and tfsec
- **Validation**: Terraform and YAML linting

#### FluxCD Automation:
- **Continuous Deployment**: Git-to-cluster sync
- **Drift Detection**: Configuration compliance
- **Rollback**: Automatic failure recovery
- **Multi-tenancy**: Namespace isolation

### Maintenance and Updates

#### Automated Updates:
- **Renovate**: Dependency updates
- **Image Updates**: Container image automation
- **Helm Charts**: Version management
- **Kubernetes**: Cluster version updates

#### Maintenance Windows:
- **Cluster**: Sundays 10:00 UTC
- **Database**: Sundays 09:00 UTC
- **Applications**: Rolling updates
- **Certificates**: Automatic renewal

### Disaster Recovery

#### Backup Strategy:
- **Infrastructure**: Terraform state backup
- **Applications**: Persistent volume snapshots
- **Secrets**: 1Password vault backup
- **Configuration**: Git repository backup

#### Recovery Procedures:
- **RTO**: 4 hours (Recovery Time Objective)
- **RPO**: 24 hours (Recovery Point Objective)
- **Runbooks**: Documented procedures
- **Testing**: Regular DR drills

## Scalability and Performance

### Horizontal Scaling

#### Application Scaling:
- **HPA**: Horizontal Pod Autoscaler ready
- **VPA**: Vertical Pod Autoscaler capable
- **Node Scaling**: Manual node pool scaling
- **Storage**: Dynamic volume expansion

#### Performance Optimization:
- **Resource Limits**: Proper resource allocation
- **Caching**: Redis and CDN integration
- **Database**: Connection pooling
- **Images**: Multi-stage builds and caching

### Monitoring and Alerting

#### Key Metrics:
- **Resource Utilization**: CPU, memory, storage
- **Application Performance**: Response time, error rate
- **Infrastructure Health**: Node status, network
- **Security Events**: Vulnerability alerts, access logs

#### Alert Thresholds:
- **Critical**: Service down, security breach
- **Warning**: High resource usage, certificate expiry
- **Info**: Deployment status, backup completion

##  Troubleshooting and Debugging

### Observability Tools

#### Log Analysis:
```bash
# View application logs
kubectl logs -f deployment/wordpress -n services

# Query logs in Loki
{namespace="services",app="wordpress"} |= "error"
```

#### Metrics Queries:
```promql
# WordPress response time
http_request_duration_seconds{job="wordpress"}

# Pod resource usage
container_memory_usage_bytes{pod=~"wordpress-.*"}
```

#### Health Checks:
- **Liveness Probes**: Application health
- **Readiness Probes**: Traffic readiness
- **Startup Probes**: Slow-starting applications

### Common Issues and Solutions

#### Pod Scheduling:
- **Anti-affinity**: Ensure sufficient nodes
- **Resource Constraints**: Check node capacity
- **Taints/Tolerations**: Node scheduling rules

#### Storage Issues:
- **PVC Binding**: Storage class availability
- **Volume Expansion**: Dynamic resize support
- **Backup Restoration**: Snapshot recovery

#### Network Problems:
- **DNS Resolution**: CoreDNS configuration
- **Service Discovery**: Endpoint availability
- **Ingress**: Gateway and route configuration

### Security Monitoring

#### Threat Detection:
- **Trivy Scans**: Vulnerability assessment
- **Falco**: Runtime security monitoring
- **Audit Logs**: API server activity

