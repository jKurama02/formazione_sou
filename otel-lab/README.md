# 🚀 OpenTelemetry Flask Monitoring Demo

A minimal, production-inspired example for monitoring a Flask application using **OpenTelemetry**, **Prometheus**, and **Grafana**.

---

## 📈 Data Flow Overview

1. **Flask App** generates metrics and traces using OpenTelemetry.
2. Metrics and traces are sent to the **OpenTelemetry Collector** via OTLP/gRPC.
3. The Collector exposes metrics in Prometheus format on port **9464**.
4. **Prometheus** scrapes metrics from the Collector.
5. **Grafana** visualizes the data collected by Prometheus in interactive dashboards.

![Flow](./otel-lab/scr1.png)
![Flow](./otel-lab/scr2.png)


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