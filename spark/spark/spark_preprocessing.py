from pyspark.sql import SparkSession
from pyspark.sql.functions import col, length, lower, regexp_replace, rand, when

spark = SparkSession.builder.appName("CISC886 URL Spark Preprocessing").getOrCreate()

INPUT_PATH = "s3://20596366-cisc886-url-assistant/raw/phishing_urls_dataset.csv"
OUTPUT_PATH = "s3://20596366-cisc886-url-assistant/processed/"

df = spark.read.csv(INPUT_PATH, header=True, inferSchema=True)

df = df.select("url", "label").dropna()
df = df.dropDuplicates(["url"])

df = df.withColumn("url", lower(col("url")))
df = df.withColumn("url", regexp_replace(col("url"), r"\s+", ""))
df = df.withColumn("url_length", length(col("url")))

df = df.withColumn(
    "label_numeric",
    when(col("label") == 1, 1).otherwise(0)
)

df = df.orderBy(rand(seed=42))

train_df, valid_df, test_df = df.randomSplit([0.7, 0.15, 0.15], seed=42)

train_df.write.mode("overwrite").parquet(OUTPUT_PATH + "train/")
valid_df.write.mode("overwrite").parquet(OUTPUT_PATH + "valid/")
test_df.write.mode("overwrite").parquet(OUTPUT_PATH + "test/")

df.groupBy("label_numeric").count().write.mode("overwrite").csv(
    OUTPUT_PATH + "eda/label_distribution/",
    header=True
)

df.select("url_length").write.mode("overwrite").csv(
    OUTPUT_PATH + "eda/url_lengths/",
    header=True
)

split_counts = spark.createDataFrame(
    [
        ("train", train_df.count()),
        ("validation", valid_df.count()),
        ("test", test_df.count()),
    ],
    ["split", "count"]
)

split_counts.write.mode("overwrite").csv(
    OUTPUT_PATH + "eda/split_counts/",
    header=True
)

print("Spark preprocessing completed successfully.")
print("Train count:", train_df.count())
print("Validation count:", valid_df.count())
print("Test count:", test_df.count())

spark.stop()
