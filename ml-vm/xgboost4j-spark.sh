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
# This script installs xgboost4j on all nodes of a Cloud Dataproc cluster

readonly INSTALL_FOLDER="$1"
readonly VERSION=0.90
readonly URL=https://search.maven.org/remotecontent?filepath=ml/dmlc/xgboost4j-spark/"${VERSION}"/xgboost4j-spark-"${VERSION}".jar

curl -L -O "${URL}"

mv xgboost4j-spark-"${VERSION}".jar "${INSTALL_FOLDER}"

