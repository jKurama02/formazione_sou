# Progetto Kafka - Producer e Consumer

## 📋 Descrizione del Progetto

Questo progetto implementa un sistema di messaggistica basato su **Apache Kafka** utilizzando Python. Il sistema è composto da:

- **Producer** (`producer.py`): Un'applicazione che invia messaggi JSON al topic Kafka "foobar"
- **Consumer** (`consumer.py`): Un'applicazione che riceve e processa i messaggi dal topic "foobar"
- **Broker Kafka** (`kafka_broker.yaml`): Configurazione Docker Compose per avviare Kafka e Zookeeper

## 🏗️ Architettura del Sistema

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Producer  │───▶│   Kafka     │───▶│  Consumer   │
│(producer.py)│    │  Broker     │    │(consumer.py)│
└─────────────┘    │ (localhost  │    └─────────────┘
                   │   :9092)    │
                   └─────────────┘
                          ▲
                          │
                   ┌─────────────┐
                   │  Zookeeper  │
                   │ (port 2181) │
                   └─────────────┘
```

### Componenti:

1. **Zookeeper**: Servizio di coordinamento per Kafka
2. **Kafka Broker**: Server che gestisce i topic e i messaggi
3. **Topic "foobar"**: Canale di comunicazione tra producer e consumer
4. **Producer**: Invia 10 messaggi JSON con ID e testo
5. **Consumer**: Ascolta continuamente il topic e stampa i messaggi ricevuti

## 🛠️ Come Funziona

### Producer (`producer.py`)
- Si connette al broker Kafka su `localhost:9092`
- Serializza i messaggi in formato JSON
- Invia 10 messaggi al topic "foobar" con struttura: `{"id": i, "text": "messaggio i"}`
- Attende 0.5 secondi tra ogni invio
- Assicura che tutti i messaggi siano inviati con `flush()` prima di chiudere

### Consumer (`consumer.py`)
- Si connette al broker Kafka su `localhost:9092`
- Si sottoscrive al topic "foobar"
- Configurato con gruppo "my-group" per gestione degli offset
- Inizia la lettura dall'inizio del topic (`auto_offset_reset='earliest'`)
- Rimane in ascolto continuo stampando ogni messaggio ricevuto

## 🚀 Setup e Installazione

### 1. Prerequisiti
- Python 3.7+
- Docker e Docker Compose


### 2. Preparazione dell'Ambiente Python

```bash
# Creazione dell'ambiente virtuale
python3 -m venv ./k_venv

# Attivazione dell'ambiente virtuale
source k_venv/bin/activate

# Installazione delle dipendenze
pip install kafka-python
```

### 3. Avvio del Broker Kafka

```bash
# Avvio di Kafka e Zookeeper in background
docker compose -f kafka_broker.yaml up -d

# Verifica che i container siano in esecuzione
docker ps
```

I servizi saranno disponibili su:
- **Kafka Broker**: `localhost:9092`
- **Zookeeper**: `localhost:2181`

## 🎯 Come Utilizzare il Progetto

### Scenario 1: Test Completo

1. **Avvia Kafka**:
   ```bash
   docker compose -f kafka_broker.yaml up -d
   ```

2. **Attiva l'ambiente virtuale**:
   ```bash
   source k_venv/bin/activate
   ```

3. **Avvia il Consumer** (in un terminale):
   ```bash
   python consumer.py
   ```
   
   Output atteso:
   ```
   In ascolto su 'foobar'...
   ```

4. **Avvia il Producer** (in un altro terminale):
   ```bash
   python producer.py
   ```
   
   Output atteso:
   ```
   → PALLEEE
   → Inviato: {'id': 0, 'text': 'messaggio 0'}
   → PALLEEE
   → Inviato: {'id': 1, 'text': 'messaggio 1'}
   ...
   ```

5. **Osserva il Consumer** che riceve i messaggi:
   ```
   ← Consumato: {'id': 0, 'text': 'messaggio 0'}
   ← Consumato: {'id': 1, 'text': 'messaggio 1'}
   ...
   ```

### Scenario 2: Consumer Persistente

Il consumer può rimanere in esecuzione per ricevere messaggi futuri. Esegui il producer più volte per vedere il consumer processare nuovi messaggi.

## 📊 Configurazioni Avanzate

### Configurazione Producer
- **bootstrap_servers**: Lista dei broker Kafka
- **value_serializer**: Funzione per serializzare i messaggi in JSON

### Configurazione Consumer
- **bootstrap_servers**: Lista dei broker Kafka
- **auto_offset_reset**: 'earliest' (dall'inizio) o 'latest' (messaggi nuovi)
- **enable_auto_commit**: Salvataggio automatico della posizione di lettura
- **group_id**: Identificatore del gruppo di consumer
- **value_deserializer**: Funzione per deserializzare i messaggi JSON

## 🛑 Arresto del Sistema

1. **Ferma Consumer**: `Ctrl+C` nel terminale del consumer
2. **Ferma Producer**: Si ferma automaticamente dopo 10 messaggi
3. **Ferma Kafka**:
   ```bash
   docker compose -f kafka_broker.yaml down
   ```

## 🔧 Troubleshooting

### Errore di Connessione
Se vedi errori di connessione, verifica che:
- Docker sia in esecuzione
- I container Kafka e Zookeeper siano attivi: `docker ps`
- Non ci siano altri servizi sulla porta 9092

### Topic Non Trovato
Kafka crea automaticamente il topic "foobar" al primo uso. Se hai problemi:
```bash
# Accedi al container Kafka
docker exec -it <kafka_container_name> bash

# Crea manualmente il topic
kafka-topics --create --topic foobar --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
```

### Reset Consumer Offset
Per ripartire dall'inizio:
```bash
# Cambia il group_id nel consumer.py o resetta l'offset
docker exec -it <kafka_container_name> kafka-consumer-groups --bootstrap-server localhost:9092 --reset-offsets --to-earliest --group my-group --topic foobar --execute
```

## 📁 Struttura File

```
kafka/
├── README.md              # Questa documentazione
├── producer.py            # Applicazione producer
├── consumer.py            # Applicazione consumer
├── kafka_broker.yaml      # Configurazione Docker Compose
└── k_venv/               # Ambiente virtuale Python
    ├── bin/
    ├── lib/
    └── ...
```

## 🎓 Concetti Kafka Utilizzati

- **Topic**: Canale di comunicazione denominato ("foobar")
- **Producer**: Applicazione che invia messaggi
- **Consumer**: Applicazione che riceve messaggi
- **Consumer Group**: Gruppo di consumer che condividono il carico
- **Offset**: Posizione di lettura nei messaggi del topic
- **Serialization**: Conversione oggetti Python → JSON → bytes
- **Deserialization**: Conversione bytes → JSON → oggetti Python

