#!/bin/bash

# start-ollama-ngrok.sh

# Step 1: Start Minikube tunnel in background (Windows PowerShell call)
start_minikube() {
  echo "🔁 Starting Minikube tunnel in background..."
  powershell.exe -Command "Start-Process -NoNewWindow -FilePath 'minikube.exe' -ArgumentList 'tunnel'"
  sleep 8
}

# Step 2: Port forward ollama-service to localhost:30332
start_port_forward() {
  echo "🔁 Forwarding ollama-service port to localhost:30100..."
  kubectl port-forward service/ollama-service 30100:80 &
  PORT_FORWARD_PID=$!
  echo "✅ Port-forward PID: $PORT_FORWARD_PID"
  sleep 5
}

# Step 3: Start ngrok tunnel to the forwarded port
start_ngrok() {
  echo "🌐 Starting ngrok tunnel to http://localhost:30100..."
  ngrok http 30100
}

# Start steps
start_minikube
start_port_forward
start_ngrok
