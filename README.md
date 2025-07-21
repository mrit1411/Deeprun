## ✅ 1. Prerequisites

### Skills/Tools:

* **Cloud Platform:** AWS 
* **Containers & Orchestration:** Docker, Kubernetes
* **IaC:** Terraform, Helm
* **Monitoring:** Prometheus, Grafana
* **Security:** TLS, IAM, RBAC, API Gateway

### Account Setup:

* AWS
* GitHub
* DockerHub

---

## ✅ 2. Theoretical Architecture

### High-Level Design:

```
            +---------------------------+
            |       End Users (UI)      |
            +---------------------------+
                         |
                         v
            +---------------------------+
            |       Ingress/ALB         |
            +---------------------------+
                         |
                         v
         +--------------+--------------+
         |        Kubernetes Service    |
         +--------------+--------------+
                         |
                         v
        +-------------------------------+
        |  Ollama Deployment (ReplicaSet)|
        |  + Gemma 3 Model (via Docker)  |
        |  + OLLAMA_NUM_PARALLEL=N       |
        +-------------------------------+
                         |
                         v
     +----------------------------------------+
     | Prometheus Exporter + Grafana (Sidecar)|
     +----------------------------------------+
```

---

## ✅ 3. Step-by-Step Deployment (AWS + Kubernetes + Terraform)

### Step 1: Provision GPU Nodes (AWS)

#### Terraform (EC2 for EKS workers):

* Instance Type: `g4dn.xlarge` or `g5.xlarge` (GPU-enabled)
* AMI: Use Amazon Linux 2 EKS-optimized GPU AMI
* Region: `us-east-1` (cheaper GPU zones)

> 💰 **Estimated Cost**:
> `g4dn.xlarge` ≈ \$0.526/hour
> `EBS 100GB` ≈ \$10/month
> Total ≈ \$400–500/month for 3 nodes

---

### Step 2: Build Ollama Docker Image

```dockerfile
# Dockerfile
FROM ollama/ollama:latest
RUN ollama pull gemma:3b
```

Push to DockerHub or local registry.

---

### Step 3: Kubernetes Deployment (`ollama-deployment.yaml`)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      containers:
        - name: ollama
          image: yourrepo/ollama-gemma:latest
          env:
            - name: OLLAMA_NUM_PARALLEL
              value: "4"
          ports:
            - containerPort: 11434
```

> 🧠 `OLLAMA_NUM_PARALLEL=4` allows 4 concurrent inferences per pod.

---

### Step 4: Service & Ingress

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ollama-service
spec:
  selector:
    app: ollama
  ports:
    - port: 80
      targetPort: 11434
  type: LoadBalancer
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ollama-ingress
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ollama-service
                port:
                  number: 80
```

---

### Step 5: Auto-Scaling (HPA)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ollama-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ollama
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
```

---

### Step 6: Monitoring with Prometheus + Grafana

* Add a sidecar metrics exporter in the same pod (see `metrics_exporter.py`)
* Create a `ServiceMonitor`
* Add dashboards in Grafana

> 💰 **Prometheus & Grafana Cost:** Free on self-hosted; \$49/month on Grafana Cloud Pro

---

### Step 7: Security and Access

* Secure Ollama endpoint with TLS (`cert-manager`)
* Add OAuth2 proxy or API Gateway (e.g., AWS API Gateway)
* Use IAM roles + Kubernetes RBAC

---

### Step 8: Load Testing

Use `locustfile.py`:

```python
from locust import HttpUser, task
class OllamaLoadTest(HttpUser):
    @task
    def infer(self):
        self.client.post("/api/generate", json={"prompt": "Hello!"})
```

Run:

```bash
locust -f locustfile.py --headless -u 50 -r 10 --host=http://<OLLAMA_URL>
```

---

## ✅ 4. Optional Enhancements

| Feature             | Description                                          |
| ------------------- | ---------------------------------------------------- |
| **Caching**         | Save recent prompts/outputs with Redis               |
| **Multi-Region HA** | Use Route 53 + global load balancer                  |
| **IaC**             | Use Terraform for infra + Helm charts for deployment |
| **CI/CD**           | Use GitHub Actions for push/deploy automation        |

---

## ✅ 5. Total Cost Estimate (AWS – Production-Grade)

| Component             | Units | Rate                | Monthly Cost |
| --------------------- | ----- | ------------------- | ------------ |
| EC2 GPU (g4dn.xlarge) | 3     | \~\$0.53/hr         | \~\$1,134    |
| EBS (100GB each)      | 3     | \~\$0.10/GB         | \~\$30       |
| Load Balancer         | 1     | \~\$0.025/hr        | \~\$18       |
| Data Transfer         | 100GB | \~\$0.09/GB         | \~\$9        |
| EKS + Control Plane   | 1     | Free on self-hosted | \$0          |

> 💡**Total**: \~\$1,191/month (baseline)
> Use **Minikube + ngrok** for free-tier local testing

---

## ✅ 6. Interview-Ready Talking Points

* **Scalability**: "I implemented autoscaling using HPA based on CPU usage, with horizontal scaling up to 10 replicas."
* **Concurrency**: "I configured `OLLAMA_NUM_PARALLEL=4` per pod to enable multi-user queries simultaneously."
* **Monitoring**: "I used Prometheus + Grafana with sidecar exporters to monitor request rate, latency, and GPU utilization."
* **Security**: "Access is restricted via API Gateway and OAuth2 proxy, and all communication is encrypted with TLS."
* **IaC**: "All infrastructure is provisioned using Terraform and Helm, enabling one-command deployments."

---
