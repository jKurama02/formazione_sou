from flask import Flask
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry import trace

# NUOVO: Setup metriche
from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter

# Setup tracing (come prima)
trace.set_tracer_provider(TracerProvider())
otlp_exporter = OTLPSpanExporter(endpoint="http://otel-collector:4317", insecure=True)
trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(otlp_exporter))

# Setup metric (new)
metric_exporter = OTLPMetricExporter(endpoint="http://otel-collector:4317", insecure=True)
metric_reader = PeriodicExportingMetricReader(exporter=metric_exporter, export_interval_millis=5000)
metrics.set_meter_provider(MeterProvider(metric_readers=[metric_reader]))

# Create meter and custom metric
meter = metrics.get_meter(__name__)
hello_counter = meter.create_counter(
    name="hello_requests_total",
    description="Numero totale di richieste all'endpoint hello",
    unit="1"
)

# La tua app originale
app = Flask(__name__)

# Instrumenta Flask
FlaskInstrumentor().instrument_app(app)

@app.route('/')
def hello():
    hello_counter.add(1, {"endpoint": "/"})
    return 'hello world sou'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)