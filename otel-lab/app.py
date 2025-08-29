from flask import Flask
from opentelemetry.instrumentation.flask import FlaskInstrumentor

from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter

# Setup metric (new)
metric_exporter = OTLPMetricExporter(endpoint="http://otel-collector:4317", insecure=True)
metric_reader = PeriodicExportingMetricReader(exporter=metric_exporter, export_interval_millis=5000)
metrics.set_meter_provider(MeterProvider(metric_readers=[metric_reader]))

# Create meter and custom metric
meter = metrics.get_meter(__name__)
hello_counter = meter.create_counter(
    name="hello_requests_total",
    description="Total number of hello requests",
    unit="1"
)

# My flask app
app = Flask(__name__)


@app.route('/')
def hello():
    hello_counter.add(1, {"endpoint": "/"})
    return 'hello world sou'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)