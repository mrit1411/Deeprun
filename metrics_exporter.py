# metrics_exporter.py
from flask import Flask, Response
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Example metric
ollama_request_count = Counter('ollama_requests_total', 'Total Ollama requests')

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

@app.route('/fake-inference')  # fake LLM endpoint for demo
def fake_inference():
    ollama_request_count.inc()
    return "Fake response"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9101)
