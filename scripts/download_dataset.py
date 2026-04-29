from datasets import load_dataset
from huggingface_hub import login
from getpass import getpass
import pandas as pd
import os

print("Enter your Hugging Face token.")
hf_token = getpass("HF_TOKEN: ")

login(token=hf_token)

dataset_name = "semihGuner2002/PhishingURLsDataset"

print(f"Loading dataset: {dataset_name}")
ds = load_dataset(dataset_name, token=hf_token)

print(ds)

os.makedirs("data", exist_ok=True)

# Try to detect split
if "train" in ds:
    df = ds["train"].to_pandas()
else:
    first_split = list(ds.keys())[0]
    df = ds[first_split].to_pandas()

print("Columns:", df.columns.tolist())
print(df.head())

# Normalize expected columns
possible_url_cols = ["url", "URL", "text", "Website", "website"]
possible_label_cols = ["label", "Label", "status", "class"]

url_col = next((c for c in possible_url_cols if c in df.columns), None)
label_col = next((c for c in possible_label_cols if c in df.columns), None)

if url_col is None or label_col is None:
    raise ValueError(f"Could not find URL/label columns. Existing columns: {df.columns.tolist()}")

df = df[[url_col, label_col]].rename(columns={url_col: "url", label_col: "label"})
df = df.dropna()
df = df.drop_duplicates()

df.to_csv("data/phishing_urls_dataset.csv", index=False)

print("Saved dataset to data/phishing_urls_dataset.csv")
print("Rows:", len(df))
print(df["label"].value_counts())
