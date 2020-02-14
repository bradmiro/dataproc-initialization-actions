#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS-IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This script builds the spark-bigquery connector into the Cloud Dataproc cluster.

set -euxo pipefail

readonly SPARK_DEEP_LEARNING_INSTALL_FOLDER="$1"
readonly SPARK_DEEP_LEARNING_LOCATION=http://dl.bintray.com/spark-packages/maven/databricks/spark-deep-learning/1.5.0-spark2.4-s_2.11/spark-deep-learning-1.5.0-spark2.4-s_2.11.jar # 0.13.0

gsutil cp "${SPARK_BIGQUERY_CONNECTOR_LOCATION}" "${SPARK_DEEP_LEARNING_INSTALL_FOLDER}"
