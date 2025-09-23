# Documentazione del progetto

Questo progetto è stato realizzato come esercitazione pratica sul deployment in ambiente Kubernetes/OpenShift, seguendo il subject proposto. Di seguito vengono descritti i principali step, obiettivi raggiunti e dettagli tecnici.

## 1. Deployment Openshift
- Studio approfondito della composizione dei manifest per Deployment e DeploymentConfig, con analisi delle differenze tra i due oggetti.
- Creazione di un deployment per installare Nginx con footprint minimale, utilizzando file YAML dedicati (`nginx.yaml`).
- Configurazione dei volumi per la gestione sicura di certificati e chiavi SSL tramite Secret e ConfigMap.
- Esporre Nginx tramite un Service di tipo NodePort per l'accesso esterno.

## 2. Gestione CSR e Certificati
- Generazione di una ROOT CA self-signed locale tramite OpenSSL, per simulare una CA interna.
- Creazione di una Certificate Signing Request (CSR) per Nginx, necessaria per ottenere un certificato valido.
- Rilascio dei certificati richiesti dal CSR tramite la ROOT CA generata, con firma e verifica dei certificati.
- I certificati (`nginx-cert.pem`), chiavi (`nginx-key.pem`) e CSR sono gestiti nella cartella `nginx-ssl/`.
- Configurazione di Nginx per l'utilizzo dei certificati SSL generati, tramite il file `nginx-ssl.conf`.

## 3. Gestione Resource Quotas
- Studio approfondito del manifest che descrive una ResourceQuota, con spiegazione dei campi principali (`spec.hard`).
- Applicazione di quote sulle risorse, ad esempio limitando il numero massimo di pod nel namespace (`pods: "5"`).
- Verifica del funzionamento delle quote: tentativi di superamento delle soglie generano errori e impediscono la creazione di nuove risorse.
- Utilizzo di comandi `kubectl` per monitorare e validare l'applicazione delle quote.

## 4. Gestione Prometheus Stack
- Installazione dello stack Prometheus tramite Helm chart ufficiale, seguendo la documentazione del progetto.
- Analisi degli elementi dello stack:
  - **Prometheus**: raccolta e storage delle metriche.
  - **AlertManager**: gestione degli alert e notifiche.
  - **Grafana**: visualizzazione delle metriche tramite dashboard.
  - **NodeExporter**: esportazione delle metriche dai nodi del cluster.
- Test del BlackBox Exporter per il monitoraggio di endpoint HTTP, simulando health check esterni.
- Esplorazione e comprensione delle dashboard installate dall'operator, con analisi delle metriche principali.

---

### Struttura del progetto
- `nginx.yaml`: Manifest per deployment, service e resource quota di Nginx.
- `nginx-ssl/`: Certificati, chiavi e CSR per Nginx.
- `nginx-ssl.conf`: Configurazione SSL per Nginx.
- `README.md`: Documentazione del progetto.

### Note
Il progetto è pensato per essere un esempio pratico e didattico, utile per comprendere i concetti chiave di deployment, gestione certificati, risorse e monitoring in Kubernetes/OpenShift. Ogni step è documentato e può essere riutilizzato come base per ambienti di test o produzione.