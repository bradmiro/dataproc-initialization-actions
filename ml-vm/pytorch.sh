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
# This script sets up and installs PyTorch on a Cloud Dataproc Cluster. To use with gpus, the
# gpu initialization aciton must also be installed.

set -exo pipefail

readonly PYTORCH_VERSION='1.2'
readonly TORCHVISION_VERSION='0.4.0'
readonly PYTORCH_INSTALL_FOLDER=/opt/pytorch
readonly PYTORCH_SAMPLES_FOLDER=${PYTORCH_INSTALL_FOLDER}/examples

function err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  return 1
}

role="$(/usr/share/google/get_metadata_value attributes/dataproc-role)"
if [[ "${role}" == 'Master' ]]; then
    echo "Installing PyTorch"
    conda install pytorch=${PYTORCH_VERSION} torchvision=${TORCHVISION_VERSION} cudatoolkit=9.2 -c pytorch || err
    echo "PyTorch installed successfully."
 
    cd ${PYTORCH_SAMPLES_FOLDER}
    cat << EOF > test_install.py
    import torch
    x = torch.rand(3,3)
    EOF

    cat << EOF > test_gpu.py 
    import torch
    torch.cuda.is_available()
    EOF

else
    echo "PyTorch will only be installed on a single node."
fi