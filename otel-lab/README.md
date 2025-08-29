# 🚀 OpenTelemetry Flask Monitoring Demo

A minimal, production-inspired example for monitoring a Flask application using **OpenTelemetry**, **Prometheus**, and **Grafana**.

---

## 📈 Data Flow Overview

```mermaid
graph TD;
    A[Flask App (app.py)] -->|OTLP gRPC| B[OpenTelemetry Collector];
    B -->|Prometheus format (9464)| C[Prometheus];
    C -->|Data source| D[Grafana];
```

---

## 🏗️ Architecture

- **Flask Application**
  - Instrumented with OpenTelemetry metrics & tracing
  - Custom metric: `hello_requests_total` (counts HTTP requests)
  - Exports data to OTLP Collector via gRPC

- **OpenTelemetry Collector**
  - Receives metrics & traces from Flask app
  - Processes, batches, and exposes metrics in Prometheus format on port **9464**
  - Logs debug info for troubleshooting

- **Prometheus**
  - Scrapes metrics from the OTEL Collector every 10 seconds
  - Stores time-series data
  - Provides data source for Grafana

- **Grafana**
  - Connects to Prometheus as a data source
  - Visualizes metrics in customizable dashboards
  - Access: [http://localhost:3000](http://localhost:3000) (default: admin/admin)

---

## 🛠️ Quickstart

1. **Avvia tutti i servizi con Podman Compose:**
   ```sh
   podman-compose up -d
   ```

2. **Access the services:**
   - Flask App: [http://localhost:5000](http://localhost:5000)
   - Prometheus: [http://localhost:9090](http://localhost:9090)
   - Grafana: [http://localhost:3000](http://localhost:3000) (admin/admin)

---

## 🤹 Test
    ```sh
   ./verify.sh
   ```

- View total requests:  
  `hello_requests_total`

---

## 📊 Example Prometheus Query

- View total requests:  
  `hello_requests_total`

---

## 📝 Notes
- All containers run on the `monitoring` network for easy service discovery.
- The collector exposes metrics for Prometheus on port **9464**.
- You can extend this setup with more exporters, receivers, or dashboards as needed.

---

Happy Observability! 🌈