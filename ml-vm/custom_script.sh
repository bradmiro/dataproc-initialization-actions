#!/bin/bash

set -euxo pipefail

readonly REGION=us-east1
readonly INIT_ACTIONS=gs://goog-dataproc-initialization-actions-us-east1/python/
readonly JARS_DIR=/usr/lib/spark/jars

pip_dependencies=(
  wrapt
)

pip_packages=(
  google-cloud-bigquery
  google-cloud-datalabeling
  google-cloud-storage
  google-cloud-bigtable
  google-cloud-dataproc
  google-api-python-client
  mxnet
  "tensorflow==1.15.0"
  numpy
  scikit-learn
  keras
  graphframes
  spark-nlp
  xgboost
  sparkdl
  mlflow
  torch
  torchvision
)

declare -A JAR_VERSIONS
JAR_VERSIONS=(
  ["graphframes"]="0.7.0-spark2.4-s_2.11"
  ["spark-deep-learning"]="1.5.0-spark2.4-s_2.11"
  ["xgboost4j-spark"]="0.90"
  ["spark-tensorflow-connector_2.11"]="1.6.0"
  ["tensorframes"]="0.8.2-s_2.11"
)

declare -A JAR_REPOS=(
  ["graphframes"]="http://dl.bintray.com/spark-packages/maven/graphframes"
  ["spark-deep-learning"]="http://dl.bintray.com/spark-packages/maven/databricks"
  ["xgboost4j-spark"]="https://repo1.maven.org/maven2/ml/dmlc"
  ["spark-tensorflow-connector_2.11"]="https://kompics.sics.se/maven/repository/org/tensorflow/"
  ["tensorframes"]="https://dl.bintray.com/spark-packages/maven/databricks"
)

# cd ${WORKING_DIR}
# git clone https://github.com/GoogleCloudDataproc/initialization-actions
# cd initialization-actions

# echo "Installing TonY"
# echo "Skipping"
# bash tony/tony.sh >> /dev/null 

# echo "Installing GPU Drivers"
# bash gpu/install_gpu_driver.sh

# echo "Installing Spark-Bigquery and Hadoop Bigquery Connector"
# bash connectors/connectors.sh <SPARK_BIGQUERY> <BIGQUERY>

function install_pip() {
  echo "Installing pip..."
  apt-get -y update
  apt install python-dev python-pip -y
  pip install --upgrade pip
}

function install_pip_packages() {
  echo "Installing pip packages..."
  pip install -U "${pip_dependencies[@]}"
  pip install -U "${pip_packages[@]}"
}

function install_from_maven() {
  local -r name=$1
  local -r version=${JAR_VERSIONS[${name}]}
  local -r repo=${JAR_REPOS[${name}]}

  url="${repo}/${name}/${version}/${name}-${version}.jar"

  local -r jar_name="${url##*/}"

  echo "Installing '${name}' from maven..."
  #curl -L -O --fail $url #wget?
  wget -nv --timeout=30 --tries=5 --retry-connrefused "${url}" -O ${JARS_DIR}/jar_name

  local -r jar_name="${url##*/}"

  ln -s -f "${JARS_DIR}/${jar_name}" "${JARS_DIR}/${name}.jar"
}

function install_maven_packages() {
  echo "Installing maven packages..."
  for package in "${!JAR_REPOS[@]}"; do
    install_from_maven "${package}"
  done
}

function install_sparklyr() {
  # sparklyr
  echo "Installing sparklyr"

  #apt-get update
  apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev

  echo "INSTALLING SPARKLYR"
  Rscript -e 'install.packages("sparklyr", repo="https://cran.rstudio.com")'
  echo "SPARKLYR INSTALLED SUCCESSFULLY"

  echo "INSTALLING SPARKBQ"
  Rscript -e 'install.packages("sparkbq", repo="https://cran.rstudio.com")'
  echo "SPARKBG INSTALLED SUCCESSFULLY"
}

install_pip
install_pip_packages
install_spark_bigquery_connector
install_maven_packages
install_sparklyr

# # rapids
# cd dataproc

# # TESTS

# # cd ${WORKING_DIR}/GoogleCloudDataproc/initialization-actions/rapids

# # bigquery connector (MapReduce)
# bash bigquery-connector.sh

# #======

# # ai platform data labeling service (?)
# bash ai-platform-dls.sh

# # CUDA
# bash cuda.sh

# # rapids (USE IA)
# #bash rapids.sh

# # MxNet
# bash mxnet.sh

# # SparkBQ
# bash sparkbq.sh

# # H2O AI Sparkling Water
# bash h2oai.sh

# # DL4J
# bash dl4j.sh

# # Horovod
