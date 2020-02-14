# Spark Conf
readonly SPARK_CONF_DIR=/etc/spark/conf/spark-defaults.conf
readonly SPARK_EXTRA_JARS=/opt/spark/spark-extra-jars/ #might need to generate via forloop
WORKING_DIR=/opt

readonly REGION=us-east1
readonly INIT_ACTIONS=gs://goog-dataproc-initialization-actions-us-east1/python/

echo -e "\n#Spark Extra Install Jars stored here" >> "${SPARK_CONF_DIR}"
echo -e "spark.driver.extraClassPath=${SPARK_EXTRA_JARS}/*" >> "${SPARK_CONF_DIR}"
echo -e "spark.executor.extraClassPath=${SPARK_EXTRA_JARS}/*" >> "${SPARK_CONF_DIR}"

cd ${WORKING_DIR}
git clone https://github.com/GoogleCloudDataproc/initialization-actions
cd ${initialization-actions}

# Install pip
if command -v pip >/dev/null; then
  echo "pip is already installed."
elif command -v easy_install >/dev/null; then
  echo "Installing pip with easy_install..."
  easy_install pip
else 
  echo "Installing python-pip..."
  apt update
  apt install python-pip -y
fi

# spark-bigquery connector
bash spark-bigquery-connector.sh "${SPARK_EXTRA_JARS}"

# graphframes
bash graphframes.sh "${SPARK_EXTRA_JARS}"

# spark-deep-learning
bash spark-deep-learning.sh "${SPARK_EXTRA_JARS}"

# pytorch
bash pytorch.sh 

# # rapids
# cd dataproc

# TESTS

# cd ${WORKING_DIR}/GoogleCloudDataproc/initialization-actions/rapids



#======

# tensorframes
bash tensorframes.sh




# spark-tensorflow-connector 
bash spark-tensorflow-connector.sh

# xgboost4j-spark
bash xgboost4j-spark

# sparklyr
bash sparklyr.sh

# spark-nlp
bash spark-nlp.sh

# cloudml (?)
bash cloud-ml.sh

# ai platform data labeling service (?)
bash ai-platform-dls.sh

# bigquery connector (MapReduce)
bash bigquery-connector.sh



# CUDA
bash cuda.sh

# rapids (USE IA)
#bash rapids.sh


# PyTorch
bash pytorch.sh

# MxNet
bash mxnet.sh

# SparkBQ
bash sparkbq.sh

# H2O AI Sparkling Water
bash h2oai.sh

# DL4J
bash dl4j.sh

# Keras
bash keras.sh

# Horovod
