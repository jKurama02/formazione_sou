from flask import Flask
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# UNA sola metrica
REQUEST_COUNT = Counter('requests_total', 'Total requests')

@app.route('/')
def hello():
    REQUEST_COUNT.inc()
    return 'hello world sou'

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=321)

#  docker run -d -p 321:321 --name flask-app hello-prometheus