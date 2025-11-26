# Configuración TLS para API Gateway

Este directorio contiene la configuración para habilitar TLS (HTTPS) en el API Gateway.

## Opciones de Implementación

### Opción 1: Ingress con TLS (Recomendado)

Usa un Ingress Controller (ej: NGINX) para manejar TLS y enrutamiento.

**Ventajas:**
- Terminación TLS en el Ingress (menos carga en el pod)
- Fácil de actualizar certificados
- Mejor para producción

**Requisitos:**
- Ingress Controller instalado en el cluster
- Certificado TLS (autofirmado o de CA)

**Pasos:**

1. **Generar certificado autofirmado:**
   ```bash
   cd kubernetes-organization
   chmod +x scripts/generate-tls-cert.sh
   ./scripts/generate-tls-cert.sh <API_GATEWAY_IP> <NAMESPACE>
   ```
   Ejemplo:
   ```bash
   ./scripts/generate-tls-cert.sh 130.213.254.34 ecommerce-prod
   ```

2. **Actualizar ingress.yaml:**
   - Reemplazar `<API_GATEWAY_IP>` con la IP real
   - Reemplazar `<NAMESPACE>` con el namespace (ecommerce-prod, ecommerce-stage, etc.)

3. **Aplicar configuración:**
   ```bash
   kubectl apply -f k8s/api-gateway/ingress.yaml
   ```

4. **Cambiar Service de LoadBalancer a ClusterIP:**
   - El Ingress manejará el tráfico externo
   - El Service puede ser ClusterIP

### Opción 2: TLS en la Aplicación (Spring Boot)

Configurar TLS directamente en Spring Boot.

**Ventajas:**
- No requiere Ingress Controller
- Control total sobre la configuración TLS

**Desventajas:**
- Más complejo de gestionar
- Certificados deben estar en el contenedor

**Configuración en Spring Boot:**
```yaml
# application.yml
server:
  ssl:
    enabled: true
    key-store: classpath:keystore.p12
    key-store-password: ${SSL_KEYSTORE_PASSWORD}
    key-store-type: PKCS12
```

## Certificados

### Certificado Autofirmado (Sin Dominio)

- ✅ Funciona con IPs
- ⚠️ Navegadores mostrarán advertencia de seguridad
- ✅ Útil para pruebas/demos

### Certificado de CA (Con Dominio)

- ✅ Sin advertencias en navegadores
- ✅ Requiere dominio + DNS configurado
- ✅ Let's Encrypt (gratis) con Cert-Manager

## Verificación

Después de aplicar la configuración:

```bash
# Verificar Ingress
kubectl get ingress -n <NAMESPACE>

# Verificar Secret TLS
kubectl get secret api-gateway-tls -n <NAMESPACE>

# Probar HTTPS (ignorar advertencia de certificado)
curl -k https://<API_GATEWAY_IP>/
```

## Notas Importantes

1. **Advertencia de Certificado Autofirmado:**
   - Los navegadores mostrarán "Tu conexión no es privada"
   - Esto es normal y esperado
   - Para producción, usar certificado de CA (Let's Encrypt)

2. **Ingress Controller:**
   - Verificar que el Ingress Controller esté instalado
   - Ajustar `ingressClassName` y anotaciones según el controller

3. **Renovación de Certificados:**
   - Certificados autofirmados: regenerar manualmente
   - Con Cert-Manager: renovación automática

