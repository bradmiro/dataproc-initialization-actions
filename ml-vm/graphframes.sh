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
# This script downloads the graphframes jar and pip installs the Python client.

set -euxo pipefail

readonly GRAPHFRAMES_VERSION=0.7.0-spark2.4-s_2.11
readonly GRAPHFRAMES_INSTALL_FOLDER="$1"

curl -L -O http://dl.bintray.com/spark-packages/maven/graphframes/graphframes/"${GRAPHFRAMES_VERSION}"/graphframes-"${GRAPHFRAMES_VERSION}".jar

mv graphframes-"${GRAPHFRAMES_VERSION}".jar "${GRAPHFRAMES_INSTALL_FOLDER}"

pip install graphframes #0.6