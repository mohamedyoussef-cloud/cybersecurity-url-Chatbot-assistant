# Cybersecurity URL Chatbot Assistant

This project builds an end-to-end cloud-based cybersecurity URL analysis assistant.  
It classifies URLs as either safe/benign or phishing/malicious using a fine-tuned lightweight language model.

## Pipeline

1. Dataset loading from Hugging Face
2. Data preprocessing using Apache Spark on AWS EMR
3. Fine-tuning using Unsloth QLoRA on Google Colab
4. Model export to GGUF
5. Deployment on AWS EC2 using Ollama
6. Web interface using OpenWebUI

## Technologies

- AWS EC2
- AWS S3
- AWS EMR
- Terraform
- Apache Spark / PySpark
- Hugging Face Datasets
- Unsloth
- LoRA / QLoRA
- Ollama
- OpenWebUI

## Dataset

Dataset: `semihGuner2002/PhishingURLsDataset`

The dataset contains URL samples with binary labels:

- `0`: safe / benign
- `1`: phishing / malicious

The dataset is downloaded using:

```bash
python scripts/download_dataset.py


Spark Preprocessing

The PySpark script is located at: spark/spark_preprocessing.py

It performs:

URL normalization
duplicate removal
train / validation / test split
EDA output generation
saving processed data to S3


Fine-Tuning

The fine-tuning notebook is located at: notebooks/fine_tuning_url_assistant.ipynb

The model was fine-tuned using:

Base model: Llama 3.2 1B Instruct 4-bit
Method: QLoRA / PEFT
LoRA rank: 16
Learning rate: 2e-4
Max steps: 250

Deployment

Deployment commands are documented in: deployment/ec2_ollama_openwebui_commands.md

The fine-tuned model was exported to GGUF and deployed using Ollama as: urlsec:latest

OpenWebUI was used as the browser-based chat interface.


Example Output

Input: http://paypal-login-verification-security.com/update/account

Output:

Classification: phishing/malicious
Risk level: high
Reason: The URL pattern is associated with phishing or malicious behavior in the dataset.


Security Notes

Secrets and large files are excluded from GitHub:

Hugging Face tokens
AWS credentials
Terraform state
dataset CSV files
GGUF model files
ZIP model archives

