@echo off
echo 🖥️ Starting Kubernetes Dashboard...
echo.
echo 📋 Instructions:
echo 1. This will start kubectl proxy
echo 2. Open your browser to: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
echo 3. Run ./access-dashboard.ps1 in another terminal to get the login token
echo.
echo 🚀 Starting proxy... (Press Ctrl+C to stop)
echo.
kubectl proxy