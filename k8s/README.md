# Kubernetes Manifests - Guía de Despliegue

Este directorio contiene los manifiestos de Kubernetes para desplegar los microservicios en diferentes ambientes.

## Estructura

```
k8s/
├── namespace.yaml              # Namespaces para dev, stage, prod
├── service-discovery/         # Service Discovery (Eureka)
│   └── deployment.yaml
├── cloud-config/              # Cloud Config Server
│   └── deployment.yaml
├── api-gateway/               # API Gateway
│   ├── deployment.yaml
│   ├── configmap.yaml
│   ├── ingress-cert-manager.yaml  # Ingress con TLS (Cert-Manager)
│   └── README-TLS.md          # Documentación TLS
├── cert-manager/              # Cert-Manager (Let's Encrypt)
│   └── cluster-issuer.yaml
├── product-service/           # Product Service
│   ├── deployment.yaml
│   └── configmap.yaml
└── ... (resto de servicios)
```

## Orden de Despliegue

Los servicios deben desplegarse en el siguiente orden debido a las dependencias:

### 1. Namespaces

```bash
kubectl apply -f k8s/namespace.yaml
```

### 2. Service Discovery (Eureka) - Puerto 8761

```bash
# Reemplazar <REGISTRY> y <NAMESPACE> según ambiente
sed -i 's|<REGISTRY>|docker.io/juanc7773|g' k8s/service-discovery/deployment.yaml
sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/service-discovery/deployment.yaml
kubectl apply -f k8s/service-discovery/deployment.yaml
```

### 3. Cloud Config - Puerto 9296

```bash
sed -i 's|<REGISTRY>|docker.io/juanc7773|g' k8s/cloud-config/deployment.yaml
sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/cloud-config/deployment.yaml
sed -i 's|<PROFILE>|prod|g' k8s/cloud-config/deployment.yaml
kubectl apply -f k8s/cloud-config/deployment.yaml
```

### 4. API Gateway - Puerto 8080

```bash
# Aplicar ConfigMap
sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/api-gateway/configmap.yaml
sed -i 's|<PROFILE>|prod|g' k8s/api-gateway/configmap.yaml
kubectl apply -f k8s/api-gateway/configmap.yaml

# Aplicar Deployment
sed -i 's|<REGISTRY>|docker.io/juanc7773|g' k8s/api-gateway/deployment.yaml
sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/api-gateway/deployment.yaml
kubectl apply -f k8s/api-gateway/deployment.yaml

# Opcional: Configurar TLS con Cert-Manager (ver k8s/api-gateway/README-TLS.md)
```

### 5. Microservicios de Negocio

```bash
# Product Service - Puerto 8500
kubectl apply -f k8s/product-service/configmap.yaml
sed -i 's|<REGISTRY>|docker.io/juanc7773|g' k8s/product-service/deployment.yaml
sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/product-service/deployment.yaml
kubectl apply -f k8s/product-service/deployment.yaml

# Order Service - Puerto 8300
kubectl apply -f k8s/order-service/configmap.yaml
sed -i 's|<REGISTRY>|docker.io/juanc7773|g' k8s/order-service/deployment.yaml
sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/order-service/deployment.yaml
kubectl apply -f k8s/order-service/deployment.yaml

# User Service - Puerto 8700
kubectl apply -f k8s/user-service/configmap.yaml
sed -i 's|<REGISTRY>|docker.io/juanc7773|g' k8s/user-service/deployment.yaml
sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/user-service/deployment.yaml
kubectl apply -f k8s/user-service/deployment.yaml

# Shipping Service - Puerto 8600
kubectl apply -f k8s/shipping-service/configmap.yaml
sed -i 's|<REGISTRY>|docker.io/juanc7773|g' k8s/shipping-service/deployment.yaml
sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/shipping-service/deployment.yaml
kubectl apply -f k8s/shipping-service/deployment.yaml

# Payment Service - Puerto 8400
kubectl apply -f k8s/payment-service/configmap.yaml
sed -i 's|<REGISTRY>|docker.io/juanc7773|g' k8s/payment-service/deployment.yaml
sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/payment-service/deployment.yaml
kubectl apply -f k8s/payment-service/deployment.yaml

# Favourite Service - Puerto 8800
kubectl apply -f k8s/favourite-service/configmap.yaml
sed -i 's|<REGISTRY>|docker.io/juanc7773|g' k8s/favourite-service/deployment.yaml
sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/favourite-service/deployment.yaml
kubectl apply -f k8s/favourite-service/deployment.yaml
```

### 6. Proxy Client - Puerto 8900

```bash
kubectl apply -f k8s/proxy-client/configmap.yaml
sed -i 's|<REGISTRY>|docker.io/juanc7773|g' k8s/proxy-client/deployment.yaml
sed -i 's|<NAMESPACE>|ecommerce-prod|g' k8s/proxy-client/deployment.yaml
kubectl apply -f k8s/proxy-client/deployment.yaml
```

## Variables de Entorno Requeridas

Antes de desplegar, asegúrate de configurar:

- `<REGISTRY>`: Registry de contenedores (ej: `docker.io/juanc7773`, `ghcr.io/usuario`)
- `<NAMESPACE>`: Namespace según ambiente (`ecommerce-dev`, `ecommerce-stage`, `ecommerce-prod`)
- `<PROFILE>`: Perfil Spring (`dev`, `stage`, `prod`)

## Verificación

Verificar que los servicios estén corriendo:

```bash
# Ver pods
kubectl get pods -n ecommerce-prod

# Ver servicios
kubectl get svc -n ecommerce-prod

# Ver logs
kubectl logs -n ecommerce-prod -l app=product-service -f

# Verificar Service Discovery
kubectl port-forward -n ecommerce-prod svc/service-discovery 8761:8761
# Luego abrir http://localhost:8761 en el navegador
```

## Health Checks

Todos los servicios tienen health checks configurados:
- **Liveness Probe**: `/actuator/health` o `/service-name/actuator/health`
- **Readiness Probe**: `/actuator/health` o `/service-name/actuator/health`

## Recursos

Cada servicio tiene límites de recursos configurados para optimizar el uso en clusters con recursos limitados:

| Servicio | Requests | Limits |
|----------|----------|--------|
| Service Discovery | 50m CPU, 128Mi RAM | 500m CPU, 512Mi RAM |
| Cloud Config | 50m CPU, 128Mi RAM | 500m CPU, 512Mi RAM |
| API Gateway | 100m CPU, 256Mi RAM | 500m CPU, 512Mi RAM |
| Product Service | 50m CPU, 128Mi RAM | 500m CPU, 512Mi RAM |
| Order Service | 50m CPU, 128Mi RAM | 500m CPU, 512Mi RAM |
| User Service | 25m CPU, 64Mi RAM | 500m CPU, 512Mi RAM |
| Shipping Service | 25m CPU, 64Mi RAM | 500m CPU, 512Mi RAM |
| Payment Service | 25m CPU, 64Mi RAM | 500m CPU, 512Mi RAM |
| Favourite Service | 50m CPU, 128Mi RAM | 500m CPU, 512Mi RAM |
| Proxy Client | 100m CPU, 256Mi RAM | 500m CPU, 512Mi RAM |

## Seguridad

### TLS (Transport Layer Security)

El API Gateway está configurado con TLS para comunicación HTTPS.

- **Ingress con TLS**: Terminación TLS en el Ingress Controller (NGINX)
- **Cert-Manager**: Gestión automática de certificados
- **Let's Encrypt**: Certificados SSL/TLS gratuitos y automáticos
- **Renovación Automática**: Los certificados se renuevan automáticamente

**Configuración actual:**
- Dominio: `api.alianzadelamagiaeterna.com`
- Certificado: Obtenido automáticamente por Cert-Manager
- HTTPS: Disponible en puerto 443

Ver [api-gateway/README-TLS.md](./api-gateway/README-TLS.md) para más detalles.

## Notas Importantes

1. **Tolerations**: Los deployments incluyen tolerations para taints de GKE (`environment=production`, `components.gke.io/gke-managed-components`)
2. **Revision History**: `revisionHistoryLimit: 2` configurado para limitar ReplicaSets antiguos
3. **Service Type**: API Gateway usa `ClusterIP` (el Ingress Controller maneja el tráfico externo)
