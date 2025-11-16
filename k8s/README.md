# Kubernetes Manifests para E-commerce Microservices

Este directorio contiene los manifiestos de Kubernetes para desplegar los microservicios en diferentes ambientes.

## Estructura

```
k8s/
├── namespace.yaml              # Namespaces para dev, stage, prod
├── service-discovery/         # Service Discovery (Eureka)
│   └── deployment.yaml
├── cloud-config/              # Cloud Config Server
│   └── deployment.yaml
├── product-service/           # Product Service
│   ├── deployment.yaml
│   └── configmap.yaml
└── README.md
```

## Orden de Despliegue

Los servicios deben desplegarse en el siguiente orden debido a las dependencias:

1. **Namespaces** (primero)
   ```bash
   kubectl apply -f k8s/namespace.yaml
   ```

2. **Service Discovery** (Eureka) - Puerto 8761
   ```bash
   # Reemplazar <REGISTRY> con tu registry de contenedores
   sed -i 's|<REGISTRY>|ghcr.io/tu-usuario|g' k8s/service-discovery/deployment.yaml
   kubectl apply -f k8s/service-discovery/deployment.yaml
   ```

3. **Cloud Config** - Puerto 9296
   ```bash
   sed -i 's|<REGISTRY>|ghcr.io/tu-usuario|g' k8s/cloud-config/deployment.yaml
   kubectl apply -f k8s/cloud-config/deployment.yaml
   ```

4. **Product Service** - Puerto 8500
   ```bash
   kubectl apply -f k8s/product-service/configmap.yaml
   sed -i 's|<REGISTRY>|ghcr.io/tu-usuario|g' k8s/product-service/deployment.yaml
   kubectl apply -f k8s/product-service/deployment.yaml
   ```

## Variables de Entorno Requeridas

Antes de desplegar, asegúrate de configurar:

- `<REGISTRY>`: Registry de contenedores (ej: ghcr.io, docker.io, azurecr.io)
- Configuraciones de Azure (para GitHub Actions):
  - `AZURE_CREDENTIALS`: Service Principal JSON
  - `AZURE_RESOURCE_GROUP`: Nombre del resource group
  - `AZURE_AKS_CLUSTER`: Nombre del cluster AKS

## Verificación

Verificar que los servicios estén corriendo:

```bash
# Ver pods
kubectl get pods -n ecommerce-dev

# Ver servicios
kubectl get svc -n ecommerce-dev

# Ver logs
kubectl logs -n ecommerce-dev -l app=product-service -f

# Verificar Service Discovery
kubectl port-forward -n ecommerce-dev svc/service-discovery 8761:8761
# Luego abrir http://localhost:8761 en el navegador
```

## Health Checks

Todos los servicios tienen health checks configurados:
- Liveness Probe: `/actuator/health`
- Readiness Probe: `/actuator/health`

## Recursos

Cada servicio tiene límites de recursos configurados:
- Service Discovery: 256Mi-512Mi RAM, 250m-500m CPU
- Cloud Config: 256Mi-512Mi RAM, 250m-500m CPU
- Product Service: 512Mi-1Gi RAM, 250m-500m CPU

