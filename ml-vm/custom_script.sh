set -e

# Spark Conf
readonly SPARK_CONF=/etc/spark/conf/spark-defaults.conf
readonly SPARK_EXTRA_JARS=/opt/spark/spark-extra-jars/
readonly WORKING_DIR=/opt
readonly REGION=us-east1
readonly INIT_ACTIONS=gs://goog-dataproc-initialization-actions-us-east1/python/

mkdir -p ${SPARK_EXTRA_JARS}

cd ${WORKING_DIR}
git clone https://github.com/GoogleCloudDataproc/initialization-actions
cd initialization-actions

echo "Installing TonY"
echo "Skipping"
bash tony/tony.sh >> /dev/null 

echo "Installing GPU Drivers"
bash gpu/install_gpu_driver.sh

# Go home
cd ${WORKING_DIR}

pip_dependenciess=(
  wrapt
)

pip_packages = (
  google-cloud-bigquery
  google-cloud-datalabeling
  google-cloud-storage
  google-cloud-bigtable
  google-cloud-dataproc
  google-api-python-client
  mxnet
  tensorflow==1.15.0
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

function install_pip() {
  echo "Installing pip..."
  apt-get -y update
  apt install python-dev python-pip -y
  pip install --upgrade pip
}

function install_pip_packages() {
  echo "Installing pip packages"
  pip install -U ${pip_dependencies[@]}
  pip install -U ${pip_packages[@]}
}


function install_spark_bigquery_connector() {
  echo "Installing spark-bigquery-connector"
  readonly SPARK_BIGQUERY_CONNECTOR_LOCATION=gs://spark-lib/bigquery/spark-bigquery-latest.jar
  gsutil cp "${SPARK_BIGQUERY_CONNECTOR_LOCATION}" "${SPARK_EXTRA_JARS}/spark-bigquery-latest.jar"
}

function install_graphframes() {
  echo "Installing graphframes"
  readonly GRAPHFRAMES_VERSION=0.7.0-spark2.4-s_2.11
  readonly GRAPHFRAMES_INSTALL_FOLDER="$1"

  curl -L -O http://dl.bintray.com/spark-packages/maven/graphframes/graphframes/"${GRAPHFRAMES_VERSION}"/graphframes-"${GRAPHFRAMES_VERSION}".jar

  mv "graphframes-${GRAPHFRAMES_VERSION}.jar" "${SPARK_EXTRA_JARS}/graphframes-${GRAPHFRAMES_VERSION}.jar"
}

function install_spark_deep_learning() {
  echo "Installing spark-deep-learning"
  readonly SPARK_DEEP_LEARNING_LOCATION=http://dl.bintray.com/spark-packages/maven/databricks/spark-deep-learning/1.5.0-spark2.4-s_2.11/spark-deep-learning-1.5.0-spark2.4-s_2.11.jar # 0.13.0

  curl -L -O "${SPARK_DEEP_LEARNING_LOCATION}"

  mv "spark-deep-learning-1.5.0-spark2.4-s_2.11.jar" "${SPARK_EXTRA_JARS}/spark-deep-learning-1.5.0-spark2.4-s_2.11.jar"
}

function install_xgboost4j() {
  echo "Installing xgboost4jspark (and xgboost)"
  readonly VERSION=0.90
  readonly URL=https://search.maven.org/remotecontent?filepath=ml/dmlc/xgboost4j-spark/"${VERSION}"/xgboost4j-spark-"${VERSION}".jar

  curl -L -O "${URL}"
  mv "xgboost4j-spark-${VERSION}.jar" "${SPARK_EXTRA_JARS}/xgboost4j-spark-${VERSION}.jar"
}


function install_sparklyr() {
  # sparklyr
  echo "Installing sparklyr"
  readonly SPARKLYR_INSTALL_FOLDER=/opt/sparklyr
  readonly SPARKLYR_SAMPLES_FOLDER=${SPARKLYR_INSTALL_FOLDER}/examples

  #apt-get update
  apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev

  echo "INSTALLING SPARKLYR"
  Rscript -e 'install.packages("sparklyr", repo="https://cran.rstudio.com")'
  echo "SPARKLYR INSTALLED SUCCESSFULLY"

  echo "INSTALLING SPARKBQ"
  Rscript -e 'install.packages("sparkbq", repo="https://cran.rstudio.com")'
  echo "SPARKBG INSTALLED SUCCESSFULLY"
}
#install_r > /dev/null
#bash sparklyr.sh


#bash spark-nlp.sh

function edit_spark_conf() {
  class_path=""
  for jar in ${SPARK_EXTRA_JARS}/*; do
      class_path="${class_path}:${jar}"
  done

  if grep -q "spark.driver.extraClassPath" "${SPARK_CONF}"; then
      grep -q "spark.driver.extraClassPath" | sed -i "s/$/${classpath}" "${SPARK_CONF}"
  else
      echo -e "\n#Spark Driver Extra Jars stored here" >> "${SPARK_CONF}"
      echo -e "spark.driver.extraClassPath=${class_path}" >> "${SPARK_CONF}"
  fi

  if grep -q "spark.executor.extraClassPath" "${SPARK_CONF}"; then
      grep -q "spark.executor.extraClassPath" | sed -i "s/$/${classpath}" "${SPARK_CONF}"
  else
      echo -e "\n#Spark Executor Extra Jars stored here" >> "${SPARK_CONF}"
      echo -e "spark.executor.extraClassPath=${class_path}" >> "${SPARK_CONF}"
  fi
}

install_pip
install_pip_packages
install_spark_bigquery_connector
install_graphframes
install_spark_deep_learning
install_xgboost4j
install_sparklyr
edit_spark_conf

# # rapids
# cd dataproc

# # TESTS

# # cd ${WORKING_DIR}/GoogleCloudDataproc/initialization-actions/rapids

# # bigquery connector (MapReduce)
# bash bigquery-connector.sh

# #======

# # tensorframes
# bash tensorframes.sh


# # spark-tensorflow-connector 
# bash spark-tensorflow-connector.sh

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

# # Keras
# bash keras.sh

# # Horovod
