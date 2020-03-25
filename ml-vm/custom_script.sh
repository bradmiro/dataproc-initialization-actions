#!/bin/bash

set -euxo pipefail

readonly REGION=us-east1
readonly INIT_ACTIONS=gs://goog-dataproc-initialization-actions-${REGION}
readonly INIT_ACTIONS_LOCAL=/opt/init-actions
readonly JARS_DIR=/usr/lib/spark/jars
readonly CONNECTORS_DIR=/usr/local/share/google/dataproc/lib

mkdir -p ${JARS_DIR}
mkdir -p ${CONNECTORS_DIR}
mkdir -p ${INIT_ACTIONS_LOCAL}

pip_dependencies=(
  "wrapt"
)

pip_packages=(
  "google-cloud-bigquery"
  "google-cloud-datalabeling"
  "google-cloud-storage"
  "google-cloud-bigtable"
  "google-cloud-dataproc"
  "google-api-python-client"
  "mxnet"
  "tensorflow==1.15.0"
  "numpy"
  "scikit-learn"
  "keras"
  "graphframes"
  "spark-nlp"
  "xgboost"
  "sparkdl"
  "mlflow"
  "torch"
  "torchvision"
)

declare -A CONNECTOR_VERSIONS
CONNECTOR_VERSIONS=(
  ["bigquery"]="1.1.1"
  ["gcs"]="2.1.1"
  ["spark-bigquery"]="0.13.1-beta"
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

function install_init_actions() {
  gsutil cp -r ${INIT_ACTIONS}/tony ${INIT_ACTIONS_LOCAL}
  gsutil cp -r ${INIT_ACTIONS}/gpu ${INIT_ACTIONS_LOCAL}

  echo "Installing TonY"
  bash ${INIT_ACTIONS_LOCAL}/tony/tony.sh >> /dev/null 

  echo "Installing GPU Drivers"
  bash ${INIT_ACTIONS_LOCAL}/gpu/install_gpu_driver.sh
}

function install_pip() {
  echo "Installing pip..."
  apt-get -y update
  apt install python-dev python3-pip -y
  pip3 install --upgrade pip
}

function install_pip_packages() {
  echo "Installing pip packages..."
  pip3 install -U "${pip_dependencies[@]}"
  pip3 install -U "${pip_packages[@]}"
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

function install_connectors() {
  local -r CONNECTORS=(
      "bigquery"
      "gcs"
      "spark-bigquery"
  )

  for name in "${CONNECTORS[@]}"; do
    version="${CONNECTOR_VERSIONS[$name]}"
    if [[ ${name} == spark-bigquery ]]; then
      local url="gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-${version}.jar"
    fi 

    if [[ ${name} == gcs || ${name} == bigquery ]]; then
      local url="gs://hadoop-lib/${name}/${name}-connector-hadoop2-${version}.jar"
    fi

    gsutil cp "${url}" "${CONNECTORS_DIR}/"

    local jar_name=${url##*/}

    # Update or create version-less connector link
    ln -s -f "${CONNECTORS_DIR}/${jar_name}" "${CONNECTORS_DIR}/${name}-connector.jar"
  done
}

function install_sparklyr_and_sparkbq() {
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
#install_init_actions
install_connectors
install_spark_bigquery_connector
install_maven_packages
install_sparklyr_and_sparkbq

# # rapids
# cd dataproc

# # TESTS

# # cd ${WORKING_DIR}/GoogleCloudDataproc/initialization-actions/rapids


# #======

# # ai platform data labeling service (?)
# bash ai-platform-dls.sh

# # CUDA
# bash cuda.sh

# # rapids (USE IA)
# #bash rapids.sh

# # MxNet
# bash mxnet.sh

# # H2O AI Sparkling Water
# bash h2oai.sh

# # DL4J
# bash dl4j.sh

# # Horovod
