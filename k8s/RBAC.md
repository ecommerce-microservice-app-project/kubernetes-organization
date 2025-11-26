# Configuración RBAC (Role-Based Access Control)

Este documento explica la configuración RBAC implementada para todos los microservicios.

## ¿Qué es RBAC?

RBAC (Role-Based Access Control) es un mecanismo de seguridad de Kubernetes que controla qué acciones pueden realizar los pods dentro del cluster.

## Estructura Implementada

Para cada servicio, se ha creado:

1. **ServiceAccount**: Identidad del pod dentro del cluster
2. **Role**: Define permisos específicos en un namespace
3. **RoleBinding**: Asocia el ServiceAccount con el Role

## Archivos por Servicio

Cada servicio tiene un archivo `rbac.yaml` en su directorio:

```
k8s/
├── api-gateway/
│   └── rbac.yaml
├── service-discovery/
│   └── rbac.yaml
├── product-service/
│   └── rbac.yaml
└── ...
```

## Permisos Otorgados

Cada Role otorga permisos mínimos necesarios:

- **ConfigMaps**: `get`, `list` - Para leer configuración
- **Services**: `get`, `list` - Para service discovery
- **Endpoints**: `get`, `list` - Para service discovery
- **Pods**: `get`, `list` - Para health checks internos

## Aplicación

Los archivos RBAC deben aplicarse **antes** de los deployments:

```bash
# Aplicar RBAC
kubectl apply -f k8s/api-gateway/rbac.yaml

# Luego aplicar deployment (que referencia el ServiceAccount)
kubectl apply -f k8s/api-gateway/deployment.yaml
```

## Orden de Despliegue con RBAC

1. **Namespaces**
   ```bash
   kubectl apply -f k8s/namespace.yaml
   ```

2. **RBAC para cada servicio** (en orden de dependencias)
   ```bash
   kubectl apply -f k8s/service-discovery/rbac.yaml
   kubectl apply -f k8s/cloud-config/rbac.yaml
   kubectl apply -f k8s/api-gateway/rbac.yaml
   # ... resto de servicios
   ```

3. **Deployments** (referencian los ServiceAccounts)
   ```bash
   kubectl apply -f k8s/service-discovery/deployment.yaml
   # ... resto de servicios
   ```

## Verificación

Verificar que los ServiceAccounts se crearon correctamente:

```bash
# Listar ServiceAccounts en un namespace
kubectl get serviceaccounts -n ecommerce-prod

# Ver detalles de un ServiceAccount
kubectl describe serviceaccount api-gateway-sa -n ecommerce-prod

# Verificar que el pod está usando el ServiceAccount
kubectl describe pod <pod-name> -n ecommerce-prod | grep ServiceAccount
```

## Beneficios

1. **Principio de Mínimo Privilegio**: Cada servicio solo tiene los permisos necesarios
2. **Seguridad**: Reduce el impacto de un compromiso
3. **Auditoría**: Fácil rastrear qué servicios tienen qué permisos
4. **Cumplimiento**: Mejora el cumplimiento de políticas de seguridad

## Notas Importantes

- Los ServiceAccounts son específicos por namespace
- Los Roles están limitados a un namespace (no ClusterRoles)
- Si un servicio necesita más permisos, actualizar su `rbac.yaml`
- Los deployments ya están configurados para usar los ServiceAccounts

