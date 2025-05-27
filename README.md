# NBFNet implementation for Pytorch Geometric

## Contents of the repository:
- .devcontainer: \
*Folder used by devcontainer vscode extension, to set up VSCode server and VSCode extensions in the Docker container*
    - devcontainer.json
    - preintall_vscode.sh
- workspace: \
*Project root, mounted as volume to the container. My PyG fork is cloned here during docker build.*
    - data: \
    *Mounted as volume to container, folder for storing datasets, logs, model checkpoints. \
    Set to desired dir in docker_params before building container!*
    - requirements.txt
    *Package requirements file, mounted as volume to container.*
- Dockerfile
- build_docker.sh
- run_docker.sh
- docker_params

## Contents of my PyG fork
Repository can be accessed inside the container in workspace/pytorch_geometric \
Added files:
- ./torch_geometric/nn/models/nbfnet.py
- ./torch_geometric/nn/conv/generalized_relational_conv.py
- ./examples/nbfnet_transductive.py
- ./test/nn/models/test_nbfnet.py
- ./test/nn/conv/test_generalized_relational_conv.py
