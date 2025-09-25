# Guida: Installazione Prometheus Stack e gestione immagini hello-prometheus

## 1. Installazione dello stack Prometheus con Helm

Per monitorare applicazioni su Kubernetes, è consigliato installare lo stack Prometheus tramite Helm. Ecco i comandi da eseguire:

```sh
helm repo add prometheus https://prometheus-community.github.io/helm-charts/
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
```

### Cosa ottieni dopo l'installazione
- **Prometheus**: raccolta e storage delle metriche dal cluster e dalle applicazioni.
- **Alertmanager**: gestione degli alert e notifiche.
- **Grafana**: dashboard per visualizzare le metriche raccolte.
- **NodeExporter**: metriche hardware/software dai nodi del cluster.
- **ServiceMonitor/PodMonitor**: risorse per monitorare servizi e pod custom.

Puoi accedere a Grafana tramite port-forward:
```sh
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```
Poi visita http://localhost:3000 nel browser.

---

## 2. Creazione, tag e push dell'immagine hello-prometheus

Questa guida spiega come costruire, taggare e pubblicare l'immagine Docker `hello-prometheus` su Docker Hub, e come utilizzarla nel file `config.yaml` per il deployment su Kubernetes.

### a. Build dell'immagine
Assicurati di avere un `Dockerfile` nella directory del progetto. Poi esegui:
```sh
docker build -t hello-prometheus .
```

### b. Tag dell'immagine
Sostituisci `<tuo-username>` con il tuo username Docker Hub:
```sh
docker tag hello-prometheus <tuo-username>/hello-prometheus:v1
```

### c. Login su Docker Hub
```sh
docker login
```

### d. Push dell'immagine
```sh
docker push <tuo-username>/hello-prometheus:v1
```

### Utilizzo nel file config.yaml
Nel manifest Kubernetes (`config.yaml`), usa il percorso completo dell'immagine:
```yaml
image: <tuo-username>/hello-prometheus:v1
```
Questo permette al cluster di scaricare l'immagine dal registry pubblico.

### Flusso di lavoro
1. Costruisci e tagga l'immagine localmente.
2. Fai il push su Docker Hub.
3. Aggiorna il file `config.yaml` con il percorso dell'immagine.
4. Applica il manifest:
   ```sh
   kubectl apply -f config.yaml
   ```
5. Kubernetes scarica l'immagine e crea il pod.

### Note
- Se aggiorni l'immagine, incrementa il tag (es. `v2`) e aggiorna anche il manifest.
- Assicurati che il nome/tag nel manifest corrisponda a quello pubblicato.

---

## Collegamento tra ServiceMonitor e Prometheus Stack: parti cruciali e funzionamento

Perché il ServiceMonitor `flask-app` venga correttamente rilevato e monitorato dallo stack Prometheus, sono fondamentali alcuni elementi di configurazione:

### 1. Label di selezione
- Il ServiceMonitor deve avere una label (es. `release: prometheus`) che corrisponde al selector configurato nello stack Prometheus (di solito nel `values.yaml` di kube-prometheus-stack).
- Esempio:
  ```yaml
  metadata:
    labels:
      release: prometheus
  ```
- Questo permette al Prometheus Operator di "vedere" il ServiceMonitor e aggiungerlo alla configurazione di scraping.

### 2. Selector del ServiceMonitor
- Il campo `spec.selector.matchLabels` deve corrispondere alle label del Service che espone la Flask app.
- Esempio:
  ```yaml
  spec:
    selector:
      matchLabels:
        app: flask-app
  ```
- Così il ServiceMonitor seleziona il Service giusto da monitorare.

### 3. Nome della porta
- Nel Service, la porta deve avere un nome (es. `metrics`) che viene usato dal ServiceMonitor:
  ```yaml
  ports:
  - port: 321
    name: metrics
  ```
- Nel ServiceMonitor:
  ```yaml
  endpoints:
  - port: metrics
    path: /metrics
    interval: 10s
  ```
- Questo collega l'endpoint `/metrics` esposto dalla Flask app alla configurazione di Prometheus.

### 4. Namespace
- Il ServiceMonitor deve essere nel namespace dove Prometheus Operator lo cerca (di solito lo stesso del Prometheus o quello configurato nel values.yaml).

---

### Come funziona il collegamento
1. Il Prometheus Operator installato con kube-prometheus-stack osserva tutte le risorse ServiceMonitor nel cluster.
2. Filtra i ServiceMonitor che hanno la label `release: prometheus` (o quella configurata).
3. Per ogni ServiceMonitor, cerca i Service con le label corrispondenti e la porta nominata `metrics`.
4. Genera la configurazione di scraping per Prometheus, che inizia a raccogliere le metriche dall'endpoint `/metrics` esposto dalla Flask app.
5. Le metriche sono disponibili in Prometheus e visualizzabili in Grafana.

**In sintesi:**
- Label, selector e nome porta sono le chiavi per il collegamento automatico tra ServiceMonitor e Prometheus.
- Il Prometheus Operator gestisce tutto in modo dinamico, senza bisogno di configurare manualmente Prometheus.

---

## 3. Monitoraggio esterno con Blackbox Exporter

Blackbox Exporter permette di monitorare servizi esterni (es. siti web, API) tramite probe HTTP, HTTPS, DNS, TCP, ICMP. Nel progetto viene usato per verificare la raggiungibilità e lo stato di servizi come Google.

### Cos'è Blackbox Exporter
- È un componente di Prometheus che effettua probe su endpoint esterni, simulando richieste HTTP/HTTPS e altri protocolli.
- Ritorna metriche sullo stato (successo/fallimento, tempo di risposta, ecc.) che Prometheus raccoglie e Grafana può visualizzare.

### Configurazione nel progetto
- Il file `blackbox.yaml` definisce i moduli di probe, ad esempio:
  ```yaml
  modules:
    http_2xx:
      prober: http
      timeout: 5s
      http:
        valid_status_codes: [200, 301, 302]
        method: GET
        fail_if_not_ssl: true
        fail_if_ssl: false
  ```
- Nel file `config.yaml` è presente una risorsa `Probe` che usa Blackbox Exporter per monitorare Google:
  ```yaml
  apiVersion: monitoring.coreos.com/v1
  kind: Probe
  metadata:
    name: google-blackbox
    namespace: monitoring
    labels:
      release: prometheus
  spec:
    jobName: google-blackbox
    interval: 30s
    module: http_2xx
    prober:
      url: blackbox-exporter-prometheus-blackbox-exporter.monitoring.svc.cluster.local:9115
      scheme: http
    targets:
      staticConfig:
        static:
          - https://www.google.com
  ```
- La label `release: prometheus` permette al Prometheus Operator di rilevare la risorsa Probe.

### Come funziona il flusso
1. Prometheus Operator rileva la risorsa Probe grazie alla label.
2. La Probe invia richieste HTTP/HTTPS a Google (o altri target definiti).
3. Blackbox Exporter valuta la risposta (status code, SSL, ecc.) secondo le regole del modulo.
4. Le metriche generate sono raccolte da Prometheus e visualizzabili in Grafana.

### Come testare Blackbox Exporter
1. **Verifica la configurazione:**
   - Controlla che `blackbox.yaml` sia corretto e che il modulo usato nella Probe (`http_2xx`) sia presente.
   - Assicurati che la Probe in `config.yaml` punti al servizio corretto di Blackbox Exporter.
2. **Applica la configurazione su Kubernetes:**
   ```sh
   kubectl apply -f config.yaml
   ```
3. **Controlla lo stato della Probe:**
   ```sh
   kubectl get probes -n monitoring
   kubectl describe probe google-blackbox -n monitoring
   ```
4. **Verifica le metriche in Prometheus/Grafana:**
   - Accedi a Grafana (vedi istruzioni sopra) e cerca dashboard o query relative a `probe_success`, `probe_duration_seconds`, ecc.
   - Puoi anche interrogare Prometheus direttamente:
     - Query esempio: `probe_success{job="google-blackbox"}`

### Note pratiche
- Puoi aggiungere altri target nella sezione `static` della Probe per monitorare più servizi.
- Modifica i moduli in `blackbox.yaml` per personalizzare le regole di probe (timeout, status code, SSL, ecc.).
- Blackbox Exporter è utile per monitorare endpoint esterni, API pubbliche, servizi di terze parti, e per testare la disponibilità da diversi cluster.

---
