# ¿Cómo Product Service usa los Manifests de Kubernetes?

## Arquitectura: Repositorios Separados

**Importante**: Este proyecto usa **múltiples repositorios Git**:
- Cada microservicio es un repositorio independiente
- `ecommerce-infra` es un repositorio separado con los manifests de Kubernetes

## Flujo del Pipeline

### 1. Push al Repositorio de Product Service
Cuando haces push a la rama `develop` o `dev` en el repositorio `ecommerce-product-service`:

```bash
git push origin develop
```

### 2. GitHub Actions Detecta el Cambio
El workflow `.github/workflows/ci-cd-dev.yml` en el repositorio de product-service se activa porque:
```yaml
on:
  push:
    branches:
      - develop
      - dev
    paths:
      - 'ecommerce-product-service/**'  # Solo si hay cambios aquí
```

### 3. Pipeline Ejecuta los Pasos

#### Paso A: Checkout del Repositorio de Product Service
```yaml
- name: Checkout code
  uses: actions/checkout@v4  # Repo: ecommerce-product-service
```
**Resultado**: El código fuente de product-service está disponible

#### Paso A.1: Checkout del Repositorio de Infraestructura
```yaml
- name: Checkout infrastructure repository
  uses: actions/checkout@v4
  with:
    repository: ${{ secrets.INFRA_REPO }}
    path: infra  # Se clona en la carpeta "infra"
```
**Resultado**: Los manifests de Kubernetes están disponibles en `infra/k8s/`

#### Paso B: Build y Test
```yaml
- name: Build with Maven
  working-directory: ./ecommerce-product-service
  run: mvn clean package
```
**Resultado**: Se compila el código del microservicio

#### Paso C: Build Docker Image
```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    context: ./ecommerce-product-service
```
**Resultado**: Se construye la imagen Docker y se sube al registry

#### Paso D: Deploy a Kubernetes
```yaml
- name: Deploy to Kubernetes
  run: |
    kubectl apply -f ecommerce-infra/k8s/product-service/deployment.yaml
```
**Resultado**: 
1. Lee el manifest desde `ecommerce-infra/k8s/product-service/deployment.yaml`
2. Reemplaza `<REGISTRY>` con el registry real
3. Aplica el deployment a Kubernetes

## Diagrama del Flujo

```
┌─────────────────────────────────────────────────┐
│  GitHub Repository (Monorepo)                   │
│                                                 │
│  ├── .github/workflows/                        │
│  │   └── product-service-dev.yml               │
│  ├── ecommerce-product-service/                │
│  │   ├── src/                                  │
│  │   ├── pom.xml                               │
│  │   └── Dockerfile                            │
│  └── ecommerce-infra/                          │
│      └── k8s/                                  │
│          └── product-service/                  │
│              ├── deployment.yaml                │
│              └── configmap.yaml                │
└─────────────────────────────────────────────────┘
           │
           │ git push
           ▼
┌─────────────────────────────────────────────────┐
│  GitHub Actions Runner                          │
│                                                 │
│  1. checkout@v4                                │
│     → Descarga TODO el repo                    │
│                                                 │
│  2. Build en ./ecommerce-product-service       │
│     → Compila el código                        │
│                                                 │
│  3. Build Docker Image                         │
│     → Crea imagen: ghcr.io/.../product-service │
│                                                 │
│  4. Checkout Infra Repo                       │
│     → Clona: ecommerce-infra repo              │
│     → Path: infra/                             │
│                                                 │
│  5. Deploy Kubernetes                          │
│     → Lee: infra/k8s/product-service/...       │
│     → Aplica: kubectl apply -f ...            │
└─────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────┐
│  Azure Kubernetes Service (AKS)                 │
│                                                 │
│  Namespace: ecommerce-dev                      │
│  ├── Deployment: product-service               │
│  └── Service: product-service                   │
└─────────────────────────────────────────────────┘
```

## Puntos Clave

### ¿Por qué funciona con repositorios separados?
Porque el workflow hace checkout de **dos repositorios**:
1. El repositorio del microservicio (product-service)
2. El repositorio de infraestructura (ecommerce-infra)

### ¿Dónde están los manifests?
En el repositorio `ecommerce-infra` en `k8s/product-service/` - Centralizados para todos los servicios.

### Ventajas de esta Estructura
- ✅ **Separación de responsabilidades**: Código separado de infraestructura
- ✅ **Versionado independiente**: Cada servicio se versiona por separado
- ✅ **CI/CD independiente**: Cada servicio puede tener su propio pipeline
- ✅ **Centralización de infraestructura**: Un solo lugar para todos los manifests
- ✅ **Facilita la consistencia**: Cambios en infraestructura se aplican desde un solo repo

### Configuración Requerida
Para que funcione, necesitas configurar en GitHub Secrets:
- `INFRA_REPO`: Nombre del repositorio de infraestructura (ej: `usuario/ecommerce-infra`)
- `INFRA_REPO_TOKEN`: Token para acceso (si el repo es privado o está en otra org)

