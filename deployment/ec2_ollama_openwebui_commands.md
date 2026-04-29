
# EC2 Deployment Commands

## Install Ollama

```bash
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable ollama
sudo systemctl restart ollama




Create Ollama Model from GGUF

unzip -o real-gguf-only.zip

cat > Modelfile <<'EOF'
FROM /home/ubuntu/url-cybersecurity-gguf_gguf/Llama-3.2-1B-Instruct.Q4_K_M.gguf

SYSTEM """
You are a cybersecurity URL analysis assistant.
Classify URLs as safe/benign or phishing/malicious.
Always answer using this exact format:

Classification:
Risk level:
Reason:
"""
EOF

ollama create urlsec -f Modelfile
ollama list




Test API

curl http://localhost:11434/api/generate -d '{
  "model": "urlsec",
  "prompt": "Classify this URL: http://paypal-login-verification-security.com/update/account Return: Classification Risk level Reason",
  "stream": false
}'





Install and Run OpenWebUI

sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu

docker run -d \
  --name open-webui \
  --restart always \
  -p 3000:8080 \
  --add-host=host.docker.internal:host-gateway \
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
  -v open-webui:/app/backend/data \
  ghcr.io/open-webui/open-webui:main


