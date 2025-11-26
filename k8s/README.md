# Kubernetes Manifests para E-commerce Microservices

Este directorio contiene los manifiestos de Kubernetes para desplegar los microservicios en diferentes ambientes.

## Estructura

```
k8s/
├── namespace.yaml              # Namespaces para dev, stage, prod
├── service-discovery/         # Service Discovery (Eureka)
│   ├── deployment.yaml
│   └── rbac.yaml              # RBAC: ServiceAccount, Role, RoleBinding
├── cloud-config/              # Cloud Config Server
│   ├── deployment.yaml
│   └── rbac.yaml
├── api-gateway/               # API Gateway
│   ├── deployment.yaml
│   ├── rbac.yaml
│   ├── ingress.yaml           # Ingress con TLS
│   ├── tls-secret.yaml        # Template para Secret TLS
│   └── README-TLS.md          # Documentación TLS
├── product-service/           # Product Service
│   ├── deployment.yaml
│   ├── configmap.yaml
│   └── rbac.yaml
├── RBAC.md                    # Documentación RBAC
└── README.md
```

## Orden de Despliegue

Los servicios deben desplegarse en el siguiente orden debido a las dependencias:

1. **Namespaces** (primero)
   ```bash
   kubectl apply -f k8s/namespace.yaml
   ```

2. **RBAC** (antes de los deployments)
   ```bash
   # Aplicar RBAC para cada servicio
   kubectl apply -f k8s/service-discovery/rbac.yaml
   kubectl apply -f k8s/cloud-config/rbac.yaml
   kubectl apply -f k8s/api-gateway/rbac.yaml
   # ... resto de servicios
   ```
   Ver [RBAC.md](./RBAC.md) para más detalles.

3. **Service Discovery** (Eureka) - Puerto 8761
   ```bash
   # Reemplazar <REGISTRY> y <NAMESPACE> según ambiente
   sed -i 's|<REGISTRY>|ghcr.io/tu-usuario|g' k8s/service-discovery/deployment.yaml
   sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/service-discovery/deployment.yaml
   kubectl apply -f k8s/service-discovery/deployment.yaml
   ```

4. **Cloud Config** - Puerto 9296
   ```bash
   sed -i 's|<REGISTRY>|ghcr.io/tu-usuario|g' k8s/cloud-config/deployment.yaml
   sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/cloud-config/deployment.yaml
   kubectl apply -f k8s/cloud-config/deployment.yaml
   ```

5. **API Gateway** - Puerto 8080
   ```bash
   sed -i 's|<REGISTRY>|ghcr.io/tu-usuario|g' k8s/api-gateway/deployment.yaml
   sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/api-gateway/deployment.yaml
   kubectl apply -f k8s/api-gateway/deployment.yaml
   
   # Opcional: Configurar TLS (ver k8s/api-gateway/README-TLS.md)
   ```

6. **Product Service** - Puerto 8500
   ```bash
   kubectl apply -f k8s/product-service/configmap.yaml
   sed -i 's|<REGISTRY>|ghcr.io/tu-usuario|g' k8s/product-service/deployment.yaml
   sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/product-service/deployment.yaml
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
- Service Discovery: 128Mi-512Mi RAM, 50m-500m CPU
- Cloud Config: 128Mi-512Mi RAM, 50m-500m CPU
- Product Service: 128Mi-512Mi RAM, 50m-500m CPU

## Seguridad

### RBAC (Role-Based Access Control)

Todos los servicios tienen configurado RBAC con permisos mínimos necesarios.

- **ServiceAccount**: Identidad del pod
- **Role**: Permisos en el namespace
- **RoleBinding**: Asocia ServiceAccount con Role

Ver [RBAC.md](./RBAC.md) para más detalles.

### TLS (Transport Layer Security)

El API Gateway puede configurarse con TLS para comunicación HTTPS.

- **Ingress con TLS**: Terminación TLS en el Ingress Controller
- **Certificados autofirmados**: Para pruebas sin dominio
- **Cert-Manager**: Para certificados automáticos (Let's Encrypt)

Ver [api-gateway/README-TLS.md](./api-gateway/README-TLS.md) para más detalles.

