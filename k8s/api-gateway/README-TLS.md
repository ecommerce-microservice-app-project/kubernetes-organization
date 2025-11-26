# Configuración TLS para API Gateway

Este directorio contiene la configuración para habilitar TLS (HTTPS) en el API Gateway usando Cert-Manager y Let's Encrypt.

## Implementación Actual

### ✅ Configuración Implementada

- **Ingress Controller**: NGINX Ingress Controller instalado
- **Cert-Manager**: Instalado y configurado
- **ClusterIssuer**: Configurado para Let's Encrypt (producción)
- **Ingress**: Configurado con TLS y anotaciones de Cert-Manager
- **Certificado**: Obtenido automáticamente y renovado cada 60 días

### 📋 Archivos

- `ingress-cert-manager.yaml`: Ingress con configuración de Cert-Manager
- `../cert-manager/cluster-issuer.yaml`: ClusterIssuer para Let's Encrypt

## Configuración Actual

**Dominio**: `api.alianzadelamagiaeterna.com`  
**IP del Ingress Controller**: `35.188.149.59`  
**Certificado**: Let's Encrypt (válido, sin advertencias)  
**Renovación**: Automática cada 60 días

## Estructura

```
api-gateway/
├── deployment.yaml              # Deployment (Service: ClusterIP)
├── ingress-cert-manager.yaml    # Ingress con TLS y Cert-Manager
└── README-TLS.md               # Este archivo

../cert-manager/
└── cluster-issuer.yaml         # ClusterIssuer para Let's Encrypt
```

## Cómo Funciona

### Flujo de Cert-Manager

1. **Cert-Manager** detecta el Ingress con anotación `cert-manager.io/cluster-issuer`
2. **Crea un Certificate** automáticamente
3. **Solicita certificado** a Let's Encrypt usando HTTP-01 challenge
4. **Crea pods solver** temporales para validar el dominio
5. **Obtiene el certificado** y lo almacena en un Secret
6. **Ingress usa el certificado** del Secret para HTTPS
7. **Renovación automática** cada 60 días

### Flujo de Tráfico HTTPS

```
┌─────────────┐
│  Navegador  │
│  (Cliente)  │
└──────┬──────┘
       │ HTTPS (cifrado)
       │ https://api.alianzadelamagiaeterna.com
       ▼
┌──────────────────┐
│ Ingress Controller│ ← Termina TLS aquí (descifra HTTPS)
│  (NGINX)          │   Puerto: 443 (HTTPS)
│  IP: 35.188.149.59│
└──────┬───────────┘
       │ HTTP (interno, sin cifrar)
       │ api-gateway:8080
       ▼
┌─────────────┐
│ API Gateway │ ← El mismo API Gateway de siempre
│  (puerto 8080)│   No cambia nada aquí
└─────────────┘
```

**Nota importante**: El API Gateway NO se duplica. Es el mismo servicio, solo cambia cómo se accede:
- **Antes**: `http://IP:8080` (HTTP directo)
- **Ahora**: `https://dominio.com` (HTTPS vía Ingress)

## Verificación

```bash
# Verificar certificado
kubectl get certificate -n ecommerce-prod

# Verificar Ingress
kubectl get ingress -n ecommerce-prod api-gateway-ingress

# Verificar Secret TLS
kubectl get secret api-gateway-tls -n ecommerce-prod

# Ver detalles del certificado
kubectl describe certificate api-gateway-tls -n ecommerce-prod
```

## Pruebas

```bash
# Probar HTTPS
curl https://api.alianzadelamagiaeterna.com/actuator/health

# Probar con navegador
# Abrir: https://api.alianzadelamagiaeterna.com/actuator/health
```

## Troubleshooting

### Certificado no se obtiene

1. Verificar DNS:
   ```bash
   nslookup api.alianzadelamagiaeterna.com
   # Debe resolver a: 35.188.149.59
   ```

2. Verificar Ingress Controller:
   ```bash
   kubectl get pods -n ingress-nginx
   kubectl get svc -n ingress-nginx ingress-nginx-controller
   ```

3. Verificar challenges:
   ```bash
   kubectl get challenges -n ecommerce-prod
   kubectl describe challenge <challenge-name> -n ecommerce-prod
   ```

4. Verificar pods solver:
   ```bash
   kubectl get pods -n ecommerce-prod | grep solver
   ```

### Renovar certificado manualmente

```bash
# Eliminar certificado para forzar renovación
kubectl delete certificate api-gateway-tls -n ecommerce-prod
# Cert-Manager lo recreará automáticamente
```

## Notas Importantes

1. **DNS**: El dominio debe apuntar a la IP del Ingress Controller (no del Service del API Gateway)
2. **Service Type**: El Service del API Gateway debe ser `ClusterIP` (no `LoadBalancer`)
3. **Renovación**: Los certificados se renuevan automáticamente, no requiere intervención manual
4. **Tolerations**: Los pods solver tienen tolerations configuradas en el ClusterIssuer para funcionar en nodos con taints
