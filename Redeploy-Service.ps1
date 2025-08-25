param(
    [string]$ServiceName = "orderservice",
    [string]$ChartPath = "./orderservice-chart",
    [string]$ClusterName = "local-orderservice",
    [int]$LocalPort = 5001
)

Write-Host "=== Step 1. Build Docker image ==="
docker build -t "$ServiceName:local" "."

Write-Host "=== Step 2. Load image into kind (with fallback if needed) ==="
try {
    kind load docker-image "$ServiceName:local" --name $ClusterName -v 1
} catch {
    Write-Warning "kind load failed or slow. Using manual fallback..."
    docker save "$ServiceName:local" -o "$ServiceName.tar"
    docker cp "$ServiceName.tar" "$ClusterName-control-plane:/$ServiceName.tar"
    docker exec -it "$ClusterName-control-plane" ctr images import "/$ServiceName.tar"
    Remove-Item "$ServiceName.tar"
}

Write-Host "=== Step 3. Helm upgrade/reinstall ==="
# Force service name to be simple ($ServiceName)
helm upgrade --install $ServiceName $ChartPath `
  --set fullnameOverride=$ServiceName `
  --set nameOverride=$ServiceName `
  --set image.repository=$ServiceName `
  --set image.tag=local `
  --set service.port=$LocalPort `
  --set service.targetPort=80 `
  --set service.type=NodePort

Write-Host "=== Step 4. Delete old pods to force restart ==="
kubectl delete pod -l app.kubernetes.io/name=$ServiceName --ignore-not-found

Write-Host "=== Step 5. Port-forward service to localhost:$LocalPort ==="
Write-Host "Press Ctrl+C to stop forwarding."
kubectl port-forward svc/$ServiceName ${LocalPort}:${LocalPort}
