
#!/bin/bash

echo "🔍 Verifying OpenTelemetry Stack"

# Test Flask app
echo -n "Flask app: "
curl -s http://localhost:5000/ > /dev/null && echo "✅ OK" || echo "❌ FAIL"

# Generate traffic
echo "Generating traffic..."
for i in {1..5}; do curl -s http://localhost:5000/ > /dev/null; done

# Test OTel metrics
echo -n "OTel metrics: "
curl -s http://localhost:9464/metrics | grep -q "hello_requests_total" && echo "✅ OK" || echo "❌ FAIL"

# Test Prometheus
echo -n "Prometheus: "
curl -s http://localhost:9090/-/healthy > /dev/null && echo "✅ OK" || echo "❌ FAIL"

# Test Grafana
echo -n "Grafana: "
curl -s http://localhost:3000/api/health > /dev/null && echo "✅ OK" || echo "❌ FAIL"

echo "🎉 Verification complete!"
echo "Access Grafana: http://localhost:3000 (admin/admin)"