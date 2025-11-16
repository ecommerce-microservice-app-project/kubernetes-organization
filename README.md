# E-commerce Infrastructure - Kubernetes

Este repositorio contiene los manifiestos de Kubernetes para desplegar los microservicios en diferentes ambientes.

## Estructura

```
ecommerce-kubernetes/
├── k8s/                    # Manifests Kubernetes
│   ├── namespace.yaml
│   ├── service-discovery/
│   │   └── deployment.yaml
│   ├── cloud-config/
│   │   └── deployment.yaml
│   ├── product-service/
│   │   ├── deployment.yaml
│   │   └── configmap.yaml
│   ├── order-service/
│   │   ├── deployment.yaml
│   │   └── configmap.yaml
│   ├── user-service/
│   │   ├── deployment.yaml
│   │   └── configmap.yaml
│   ├── api-gateway/
│   │   ├── deployment.yaml
│   │   └── configmap.yaml
│   ├── proxy-client/
│   │   ├── deployment.yaml
│   │   └── configmap.yaml
│   ├── README.md
│   └── HOW_IT_WORKS.md
└── README.md
```

## Separación de Responsabilidades

- **Este repositorio (`ecommerce-kubernetes`)**: Contiene los manifests de Kubernetes para desplegar los microservicios

## Uso

Ver `k8s/README.md` para instrucciones de despliegue.

## Orden de Despliegue

1. **Terraform** (desde [Repositorio de terraform](https://github.com/juanC773/ecommerce-terraform-infra)): Crear la infraestructura de Azure (AKS, VNets)
2. **Kubernetes Manifests** (este repo): Desplegar los microservicios en el cluster
