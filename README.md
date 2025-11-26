# E-commerce Infrastructure - Kubernetes

Este repositorio contiene los manifiestos de Kubernetes para desplegar los microservicios en diferentes ambientes (dev, stage, prod).

## Estructura

```
kubernetes-organization/
├── k8s/                          # Manifests Kubernetes
│   ├── namespace.yaml            # Namespaces para dev, stage, prod
│   ├── service-discovery/        # Service Discovery (Eureka)
│   │   ├── deployment.yaml
│   │   └── rbac.yaml             # RBAC: ServiceAccount, Role, RoleBinding
│   ├── cloud-config/             # Cloud Config Server
│   │   ├── deployment.yaml
│   │   └── rbac.yaml
│   ├── api-gateway/              # API Gateway
│   │   ├── deployment.yaml
│   │   ├── configmap.yaml
│   │   ├── rbac.yaml
│   │   ├── ingress-cert-manager.yaml  # Ingress con TLS (Cert-Manager)
│   │   └── README-TLS.md         # Documentación TLS
│   ├── cert-manager/             # Cert-Manager (Let's Encrypt)
│   │   └── cluster-issuer.yaml
│   ├── product-service/          # Product Service
│   │   ├── deployment.yaml
│   │   ├── configmap.yaml
│   │   └── rbac.yaml
│   ├── order-service/            # Order Service
│   │   ├── deployment.yaml
│   │   ├── configmap.yaml
│   │   └── rbac.yaml
│   ├── user-service/             # User Service
│   │   ├── deployment.yaml
│   │   ├── configmap.yaml
│   │   └── rbac.yaml
│   ├── shipping-service/         # Shipping Service
│   │   ├── deployment.yaml
│   │   ├── configmap.yaml
│   │   └── rbac.yaml
│   ├── payment-service/          # Payment Service
│   │   ├── deployment.yaml
│   │   ├── configmap.yaml
│   │   └── rbac.yaml
│   ├── favourite-service/        # Favourite Service
│   │   ├── deployment.yaml
│   │   ├── configmap.yaml
│   │   └── rbac.yaml
│   ├── proxy-client/             # Proxy Client
│   │   ├── deployment.yaml
│   │   ├── configmap.yaml
│   │   └── rbac.yaml
│   ├── RBAC.md                   # Documentación RBAC
│   └── README.md                 # Guía de despliegue
├── scripts/                      # Scripts de utilidad
│   └── generate-tls-cert.sh      # Generar certificados autofirmados
└── README.md                     # Este archivo
```

## Características Implementadas

### 🔐 Seguridad

- **RBAC (Role-Based Access Control)**: Cada servicio tiene ServiceAccount con permisos mínimos necesarios
- **TLS/HTTPS**: API Gateway configurado con Cert-Manager y Let's Encrypt para certificados automáticos
- **Escaneo de Vulnerabilidades**: Trivy integrado en pipelines CI/CD

### 📦 Componentes

- **Service Discovery**: Eureka para registro de servicios
- **Cloud Config**: Configuración centralizada (opcional)
- **API Gateway**: Punto de entrada único con enrutamiento y balanceo de carga
- **Microservicios de Negocio**: Product, Order, User, Shipping, Payment, Favourite
- **Proxy Client**: Cliente frontend

## Uso

Ver `k8s/README.md` para instrucciones detalladas de despliegue.

## Orden de Despliegue

1. **Terraform** (repositorio separado): Crear infraestructura (GKE/AKS, VNets)
2. **Kubernetes Manifests** (este repo): Desplegar microservicios en el cluster

## Documentación

- **Despliegue**: Ver `k8s/README.md`
- **RBAC**: Ver `k8s/RBAC.md`
- **TLS**: Ver `k8s/api-gateway/README-TLS.md`
