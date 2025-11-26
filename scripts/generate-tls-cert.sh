#!/bin/bash

# Script para generar certificado TLS autofirmado para API Gateway
# Uso: ./generate-tls-cert.sh <API_GATEWAY_IP> [namespace]

set -e

if [ $# -lt 1 ]; then
    echo "Uso: $0 <API_GATEWAY_IP> [namespace]"
    echo "Ejemplo: $0 130.213.254.34 ecommerce-prod"
    exit 1
fi

API_GATEWAY_IP=$1
NAMESPACE=${2:-ecommerce-prod}
SECRET_NAME="api-gateway-tls"
CERT_DIR="./certs"
CERT_FILE="$CERT_DIR/tls.crt"
KEY_FILE="$CERT_DIR/tls.key"

echo "🔐 Generando certificado TLS autofirmado para API Gateway..."
echo "   IP: $API_GATEWAY_IP"
echo "   Namespace: $NAMESPACE"

# Crear directorio para certificados si no existe
mkdir -p "$CERT_DIR"

# Generar certificado autofirmado
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$KEY_FILE" \
  -out "$CERT_FILE" \
  -subj "/CN=$API_GATEWAY_IP" \
  -addext "subjectAltName=IP:$API_GATEWAY_IP"

echo "✅ Certificado generado en $CERT_DIR/"

# Crear o actualizar Secret en Kubernetes
echo "📦 Creando Secret en Kubernetes..."

kubectl create secret tls "$SECRET_NAME" \
  --cert="$CERT_FILE" \
  --key="$KEY_FILE" \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅ Secret '$SECRET_NAME' creado/actualizado en namespace '$NAMESPACE'"
echo ""
echo "📝 Próximos pasos:"
echo "   1. Actualizar ingress.yaml con la IP: $API_GATEWAY_IP"
echo "   2. Aplicar ingress.yaml: kubectl apply -f k8s/api-gateway/ingress.yaml"
echo ""
echo "⚠️  NOTA: Los navegadores mostrarán una advertencia de seguridad porque"
echo "   el certificado es autofirmado. Esto es normal para certificados sin CA."

