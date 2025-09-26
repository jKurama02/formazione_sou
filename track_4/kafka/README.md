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

## 📈 Monitoraggio Lag tra Consumer e Producer

### Comando di Descrizione del Consumer Group

Per monitorare lo stato del tuo consumer group, puoi usare il seguente comando:

```bash
docker exec -it <kafka_container_name> kafka-consumer-groups --bootstrap-server localhost:9092 --group my-group --describe
```

### Cosa fa questo comando

Questo comando fornisce informazioni dettagliate sul consumer group "my-group", mostrando:

- **TOPIC**: Il nome del topic (foobar)
- **PARTITION**: Numero della partizione del topic
- **CURRENT-OFFSET**: L'offset dell'ultimo messaggio processato dal consumer
- **LOG-END-OFFSET**: L'offset dell'ultimo messaggio disponibile nel topic
- **LAG**: Numero di messaggi non ancora processati dal consumer
- **CONSUMER-ID**: Identificativo del consumer attivo
- **HOST**: Host dove è in esecuzione il consumer
- **CLIENT-ID**: ID del client consumer

### Esempio di Output

```
GROUP           TOPIC   PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG  CONSUMER-ID                     HOST         CLIENT-ID
my-group        foobar  0          10              10              0    consumer-1-abc123def456         /172.17.0.1  consumer-1
```

### Cos'è il LAG?

Il **LAG** (ritardo) è un indicatore fondamentale che rappresenta:

- **Definizione**: Numero di messaggi che il consumer non ha ancora processato
- **Calcolo**: `LAG = LOG-END-OFFSET - CURRENT-OFFSET`
- **Interpretazione**:
  - **LAG = 0**: Il consumer è aggiornato, ha processato tutti i messaggi disponibili
  - **LAG > 0**: Ci sono messaggi in attesa di essere processati
  - **LAG crescente**: Il consumer non riesce a tenere il passo con la produzione di messaggi

### Esempi Pratici di LAG

1. **Consumer aggiornato** (ideale):
   ```
   CURRENT-OFFSET: 15, LOG-END-OFFSET: 15, LAG: 0
   ```
   Il consumer ha processato tutti i 15 messaggi disponibili.

2. **Consumer in ritardo**:
   ```
   CURRENT-OFFSET: 12, LOG-END-OFFSET: 18, LAG: 6
   ```
   Ci sono 6 messaggi in attesa di essere processati.

3. **Consumer fermo** (problema):
   ```
   CURRENT-OFFSET: 5, LOG-END-OFFSET: 25, LAG: 20
   ```
   Il consumer non sta processando messaggi, accumulando ritardo.

### Utilizzo per il Debugging

Usa questo comando per:
- **Verificare** se il consumer sta processando messaggi
- **Identificare** problemi di performance (LAG elevato)
- **Monitorare** l'utilizzo delle partizioni
- **Controllare** che i consumer siano attivi

