#!/bin/bash

set -e

echo "🚀 Iniciando minikube..."
minikube start

echo "📂 Creando namespace 'treasure-hunt'..."
kubectl create namespace treasure-hunt || echo "Namespace ya existe, continuando..."

PERSONAS=( "bayron" "alejandro" "camilo" "dianam" "elkin" "juandavid" "juanMV" "julianp" "santiago" "yisus" )

echo "📄 Aplicando secretos y despliegues..."
for nombre in "${PERSONAS[@]}"; do
  kubectl apply -f "sd-$nombre/${nombre}secret.yaml" -n treasure-hunt
  kubectl apply -f "sd-$nombre/${nombre}deployment.yaml" -n treasure-hunt
done

echo "⏳ Esperando a que los Deployments estén listos..."
for nombre in "${PERSONAS[@]}"; do
  deployment="treasure-$nombre"
  echo "Esperando deployment $deployment..."
  kubectl rollout status deployment/$deployment -n treasure-hunt --timeout=120s
done

echo "🔌 Iniciando port-forwarding en background..."
puerto=8080
for nombre in "${PERSONAS[@]}"; do
  svc="treasure-$nombre"
  echo "Forwarding $svc en puerto $puerto..."
  kubectl -n treasure-hunt port-forward svc/$svc $puerto:80 &
  puerto=$((puerto+1))
done

echo "✅ Todo listo. Los servicios están expuestos en los puertos 8080-8089."
