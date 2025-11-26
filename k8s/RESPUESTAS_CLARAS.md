# Respuestas Claras: RBAC y TLS

## ❓ Pregunta 1: ¿Si hago push en todos los repositorios, ya se aplicaría RBAC?

### Respuesta: **NO** ❌

**¿Por qué?**
- Los pipelines actuales **solo aplican** `deployment.yaml` y `configmap.yaml`
- Los pipelines **NO aplican** `rbac.yaml`

**¿Qué pasa cuando haces push?**
1. ✅ El código se compila
2. ✅ La imagen Docker se construye y sube
3. ✅ El `deployment.yaml` se aplica (con el ServiceAccount configurado)
4. ❌ El `rbac.yaml` **NO se aplica**

**Resultado:**
- El deployment intenta usar el ServiceAccount `api-gateway-sa`
- Pero el ServiceAccount **no existe** en Kubernetes
- Kubernetes crea un ServiceAccount por defecto (sin permisos RBAC)
- **Funciona, pero sin los beneficios de RBAC**

### ✅ Solución: Actualizar los Pipelines

Necesito agregar un paso en los pipelines para aplicar `rbac.yaml` **antes** del deployment.

**¿Quieres que actualice los pipelines ahora?** (Sí/No)

---

## ❓ Pregunta 2: Para probar TLS, ¿qué hay que hacer?

### Respuesta: Pasos simples

TLS requiere 3 cosas:
1. **Ingress Controller** instalado (como NGINX)
2. **Certificado TLS** generado
3. **Ingress** aplicado

### Paso a Paso para Probar TLS

#### Paso 1: Verificar si tienes Ingress Controller

```bash
# Conectarte al cluster
gcloud container clusters get-credentials gke-prod-cluster --location us-central1-a --project tfg-prod-478914

# Verificar Ingress Controller
kubectl get ingressclass
```

**Si NO aparece nada:**
- ❌ No tienes Ingress Controller
- Necesitas instalarlo primero (depende de tu proveedor de cloud)

**Si aparece algo (ej: `nginx`):**
- ✅ Tienes Ingress Controller
- Continúa al Paso 2

#### Paso 2: Obtener la IP del API Gateway

```bash
# Ver la IP del LoadBalancer
kubectl get svc api-gateway -n ecommerce-prod

# Deberías ver algo como:
# NAME          TYPE           EXTERNAL-IP      PORT(S)
# api-gateway   LoadBalancer   130.213.254.34   8080:XXXXX/TCP
```

**Anota la IP:** `130.213.254.34` (ejemplo)

#### Paso 3: Generar Certificado

```bash
# Ir al directorio de kubernetes-organization
cd kubernetes-organization

# Hacer el script ejecutable (solo la primera vez)
chmod +x scripts/generate-tls-cert.sh

# Generar certificado (reemplaza con tu IP real)
./scripts/generate-tls-cert.sh 130.213.254.34 ecommerce-prod
```

**Esto hace:**
- ✅ Genera certificado autofirmado
- ✅ Crea el Secret `api-gateway-tls` en Kubernetes

#### Paso 4: Actualizar ingress.yaml

Editar `kubernetes-organization/k8s/api-gateway/ingress.yaml`:

```yaml
# Cambiar estas líneas:
hosts:
  - <API_GATEWAY_IP>  # ← Cambiar por: 130.213.254.34
```

Y también:
```yaml
namespace: <NAMESPACE>  # ← Cambiar por: ecommerce-prod
```

#### Paso 5: Aplicar Ingress

```bash
kubectl apply -f k8s/api-gateway/ingress.yaml
```

#### Paso 6: Verificar

```bash
# Ver el Ingress
kubectl get ingress -n ecommerce-prod

# Probar HTTPS (ignorar advertencia de certificado)
curl -k https://130.213.254.34/
```

### ⚠️ Importante sobre TLS

**Certificado Autofirmado:**
- ✅ Funciona con HTTPS
- ⚠️ Navegadores mostrarán "Tu conexión no es privada"
- ✅ Esto es normal y esperado
- ✅ Puedes hacer clic en "Avanzado" → "Continuar"

**Para producción real:**
- Necesitas un dominio
- Usar Cert-Manager + Let's Encrypt
- Certificados válidos sin advertencias

---

## 📋 Resumen

| | ¿Se aplica automáticamente? | ¿Qué falta? |
|---|---|---|
| **RBAC** | ❌ NO | Actualizar pipelines para aplicar `rbac.yaml` |
| **TLS** | ❌ NO | Aplicar manualmente (Ingress Controller + certificado) |

## 🎯 Recomendación

1. **RBAC**: Actualizar pipelines para aplicarlo automáticamente
2. **TLS**: Solo si necesitas HTTPS (opcional)

