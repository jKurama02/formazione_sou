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

Questo processo garantisce che il deployment e il monitoring funzionino su qualsiasi cluster Kubernetes, locale o remoto.
