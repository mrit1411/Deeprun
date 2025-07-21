# Deeprun


## ✅ **Phase 1: Initial Objective**

Aimed to set up a **scalable, monitorable Ollama-based LLM serving system** using Docker, Kubernetes, Prometheus, Grafana.

---

## 🧱 **Phase 2: Local Docker & Ollama Setup**

### 🔧 Tools Involved:

* **Docker**
* **Ollama (custom image)**
* **Custom `metrics_exporter.py`**

### 📦 Setup Steps:

1. Created a custom Docker image: `ollama-gemma:latest`

   * Included Ollama and exposed port `11434`
   * Added environment variable: `OLLAMA_NUM_PARALLEL=4`

2. Wrote a **custom metrics exporter** (`metrics_exporter.py`)

   * Exposed application metrics at `/metrics` using `prometheus_client`
   * You were initially told to use `node-exporter`, which was **incorrect**, and later fixed to use your own exporter.

3. Built another image: `ollama-metrics-exporter:latest`

---

## ☸️ **Phase 3: Kubernetes Deployment (Minikube + Git Bash)**

### 🗂️ Files Created:

* `ollama-deployment.yaml` – included **2 containers**:

  * `ollama-gemma:latest` (main app)
  * `ollama-metrics-exporter:latest` (custom exporter)
* `ollama-service.yaml` – LoadBalancer exposing:

  * Port `80 → 11434`
  * Port `9101 → 9101`

### ⚠️ Issues Encountered:

* **`spec.spec` decoding error** in YAML:
  🔧 *Fix:* Adjusted indentation — ensured `spec.template.spec` is correctly nested.
* **Pod not exposing metrics**:
  🔧 *Fix:* Switched from `node-exporter` to your own custom exporter image.

---

## 📊 **Phase 4: Prometheus & Grafana Setup**

### 🛠️ Tools:

* `kube-prometheus-stack` Helm chart
* Prometheus Operator
* Grafana

### 🧭 Actions Taken:

* Installed `kube-prometheus-stack` via Helm
* Verified Prometheus UI at `localhost:9090`
* Accessed Grafana dashboard via NodePort

### 📡 Metrics Scraping Setup:

* Created a `ServiceMonitor` for `ollama-service`:

  ```yaml
  apiVersion: monitoring.coreos.com/v1
  kind: ServiceMonitor
  ...
  selector:
    matchLabels:
      app: ollama
  ```

* Validated Prometheus `/targets` showed status `UP` for `ollama-exporter`

---

## 🎨 **Phase 5: Grafana Dashboard**

### ⚙️ Configuration:

* Logged into Grafana (admin/admin)
* Added Prometheus data source (`http://prometheus-kube-prometheus-prometheus.monitoring:9090`)
* Created custom dashboard:

  * Visualized: request count, response time, container CPU/mem
* **Exported dashboard JSON** (optional)

---


### ⚠️ Issues Resolved:

* **Grafana dashboard not found**
  🔧 *Fix:* Created and exported a dashboard manually and added it to `grafana-dashboards/`

* **Prometheus Pod stuck in PodInitializing**
  🔧 *Fix:* Waited, checked logs, validated `init-config-reloader` completed, and verified `prometheus` and `config-reloader` containers started correctly.


---

## 🧾 Summary Table

| Component        | Tool/Service                   | Installed How?        | Issue/Fix                                                        |
| ---------------- | ------------------------------ | --------------------- | ---------------------------------------------------------------- |
| Ollama App       | Docker, K8s                    | Manual + Dockerfile   | Pod failed initially; `spec.spec` issue fixed                    |
| Metrics Exporter | Python + Prometheus            | Custom image          | Used `prometheus_client`; `/metrics` 404 until exporter replaced |
| Kubernetes       | Minikube                       | Manual via Git Bash   | Corrected YAMLs, ServiceMonitor                                  |
| Prometheus       | Helm (`kube-prometheus-stack`) | `helm install`        | Pod stuck at init; resolved with wait + validation               |
| Grafana          | Helm + UI config               | Access via NodePort   | Added Prometheus DS + custom dashboard                           |

---
