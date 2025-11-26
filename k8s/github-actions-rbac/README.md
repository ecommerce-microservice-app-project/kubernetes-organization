# RBAC para GitHub Actions - GCP Production

Este directorio contiene el manifest necesario para dar permisos al ServiceAccount de GitHub Actions en **GCP Production** para que pueda crear recursos RBAC (Roles, RoleBindings, ServiceAccounts) en los namespaces.

**Nota**: RBAC se aplica **solo en producción (GCP)**. Dev y Stage no requieren RBAC automático.

## Problema

Los pipelines de GitHub Actions fallan al intentar aplicar RBAC porque el ServiceAccount de GCP no tiene permisos para crear Roles y RoleBindings:

```
Error from server (Forbidden): error when creating "rbac.tmp.yaml": 
roles.rbac.authorization.k8s.io is forbidden: User "github-actions-prod@tfg-prod-478914.iam.gserviceaccount.com" 
cannot create resource "roles" in API group "rbac.authorization.k8s.io" 
in the namespace "ecommerce-prod": requires one of ["container.roles.create"] permission(s).
```

## Solución

Aplicar este manifest **UNA VEZ** manualmente en el cluster para dar permisos al ServiceAccount de GitHub Actions.

## Pasos

### 1. El email ya está configurado
El manifest `github-actions-rbac.yaml` ya tiene el email correcto:
- `github-actions-prod@tfg-prod-478914.iam.gserviceaccount.com`

### 2. Aplicar el manifest

**Valores confirmados**:
- **Cluster Name**: `gke-prod-cluster`
- **Location**: `us-central1-a`
- **Project ID**: `tfg-prod-478914`

```bash
# Conectarse al cluster de GCP
gcloud container clusters get-credentials gke-prod-cluster \
  --location us-central1-a \
  --project tfg-prod-478914

# Aplicar el manifest
kubectl apply -f k8s/github-actions-rbac/github-actions-rbac.yaml
```

### 3. Verificar

```bash
# Verificar ClusterRole
kubectl get clusterrole github-actions-rbac-manager

# Verificar ClusterRoleBinding
kubectl get clusterrolebinding github-actions-rbac-manager-binding

# Ver detalles
kubectl describe clusterrolebinding github-actions-rbac-manager-binding
```

## Permisos Otorgados

El ClusterRole `github-actions-rbac-manager` otorga:

- **Roles**: `get`, `list`, `create`, `update`, `patch`, `delete`
- **RoleBindings**: `get`, `list`, `create`, `update`, `patch`, `delete`
- **ServiceAccounts**: `get`, `list`, `create`, `update`, `patch`, `delete`

Estos permisos son **solo para recursos RBAC**, no dan acceso a otros recursos del cluster.

## Seguridad

- Los permisos son **limitados** a recursos RBAC
- Solo afectan a los ServiceAccounts especificados
- No dan acceso a recursos sensibles (secrets, pods, etc.)

## Notas

- Este manifest debe aplicarse **UNA VEZ** manualmente
- No está en los pipelines porque requiere permisos de administrador
- Si cambias el ServiceAccount de GitHub Actions, actualiza este manifest

