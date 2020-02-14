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
# This script installs the tensorframes library. More information can be found here: https://github.com/databricks/tensorframes

set -exo pipefail

readonly TENSORFRAMES_INSTALL_FOLDER='/opt/tensorframes'
readonly TENSORFRAMES_VERSION='0.7.0'

readonly PYTHON_VERSION='3.6'

function err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  return 1
}

function download_and_build_tensorframes() { 
    mkdir "${TENSORFRAMES_INSTALL_FOLDER}"
    cd "${TENSORFRAMES_INSTALL_FOLDER}"
    git clone https://github.com/databricks/tensorframes || err "Tensorframes repo not available."
    #TODO Switch to branch 0.7.0
    conda create -q -n tensorframes-environment python="${PYTHON_VERSION}" || err "Could not create conda environment."
    conda activate tensorframes-environment
    pip install --user -r python/requirements.txt
    build/sbt tfs_testing/assembly
    build/sbt distribution/sp/Dist
    ln -s "${PWD}"/target/testing/scala-2.11/tensorframes-assembly-0.7.0-SNAPSHOT.jar /opt/tensorframes-assembly-0.7.0-SNAPSHOT.jar
}

funtion 