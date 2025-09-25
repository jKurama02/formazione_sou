from kafka import KafkaProducer
import json
import time

# connection to broker on localhost:9092 (standard) and JSON serialization of messages
producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)


topic = "foobar"

for i in range(10):
    msg = {"id": i, "text": f"messaggio {i}"}
    print(f"→ PALLEEE")
    producer.send(topic, value=msg)
    print(f"→ Inviato: {msg}")
    time.sleep(0.5)

producer.flush()  # ensure all messages are sent
producer.close()