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
# This script sets up and installs the latest versions of sparklyr and sparkbq on all nodes of your Dataproc cluster. 
# For more information on sparklyr, please refer to https://spark.rstudio.com/.
# For more information on sparkbq, please refer to https://cran.r-project.org/web/packages/sparkbq/readme/README.html.

set -euxo pipefail

readonly SPARKLYR_INSTALL_FOLDER=/opt/sparklyr
readonly SPARKLYR_SAMPLES_FOLDER=${SPARKLYR_INSTALL_FOLDER}/examples

function err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  return 1
}

apt-get update
apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev

echo "INSTALLING SPARKLYR"
Rscript -e 'install.packages("sparklyr", repo="https://cran.rstudio.com")' || err
echo "SPARKLYR INSTALLED SUCCESSFULLY"

echo "INSTALLING SPARKBQ"
Rscript -e 'install.packages("sparkbq", repo="https://cran.rstudio.com")' || err
echo "SPARKBG INSTALLED SUCCESSFULLY"

