from kafka import KafkaConsumer
import json

consumer = KafkaConsumer(
    'foobar',
    bootstrap_servers=['localhost:9092'],
    auto_offset_reset='earliest',     # se non ha offset, parte dall'inizio
    enable_auto_commit=True,          # salva automaticamente l'offset
    group_id='my-group', 
    value_deserializer=lambda x: json.loads(x.decode('utf-8'))
)

print("In ascolto su 'foobar'...")
for msg in consumer:
    print(f"← Consumato: {msg.value}")