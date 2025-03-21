# NBFNet implementation for Pytorch Geometric

## Contents of the repository:
*will push project files sometime, need to fix torch, pyg versions and rebuild container first*
- .devcontainer: \
*Folder used by devcontainer vscode extension, to set up VSCode server and VSCode extensions in the Docker container*
    - devcontainer.json
    - preintall_vscode.sh
- workspace: \
*Project root, mounted as volume to the container. My PyG fork is cloned here during docker build, so progress on the PR can be tracked.*
    - data: \
    *Mounted as volume to container, folder for storing datasets, logs, model checkpoints (mounted to mnt/data on the server).*
    - will add src folder for graph transformer model after work on PR complete
- requirements.txt
- Dockerfile
- build_docker.sh
- run_docker.sh
- docker_params

## Progress
1. Week
    - researched recent Graph Transformer Network works
2. Week
    - read NBFNet paper
    - initial review of pull request code
    - initial review of official NBFnet PyG implementation code
3. Week
    - planned work schedule for semester
    - setting up workspace...
4. Week
    - setting up workspace... 
        - forked PyG, cherry-picked PR commits on top of a new branch
5. Week
    - setting up workspace...
    - reviewing NBFNet-PyG repo and pytorch_geometric repo
    NBFNet-PyG can be accessed at:
    https://github.com/KiddoZhu/NBFNet-PyG/tree/master
    ```
    {
    Structure of the above repository: 
        /config
            /inductive: 
                contains experiment config files for inductive setting
            /transductive: 
                contains experiment config files for transductive setting
            All config files contain the following:
                output_dir
                dataset name, version
                model params
                task specific params (negative samples,strict negative (bool), temp, metrics)
                optimizer params (name, lr)
                train params (gpu, epoch num, log intervl, batch size)
        /data:
            contains vocab file needed for visualization (fb15k237 only)
            transformed data stored here?
        /nbfnet
            /rspmm
                contains custom cuda kernel for matrix operations
            /datasets.py
                defines IndRelLinkPredDataset class descending from InMeomoryDataset
                object can be initiated with either FB15k-237 or WN18RR dataset (Knowledge Graphs)
            /layers.py
                defines GeneralizedRelationalConv layes descending from MessagPassing
            /models.py
                defines NBFNet model as nn.Module
            /tasks.py
                helper methods called in run.py, visualize.py, related to data batches
            /util.py
                other util helper methods (build dataset, build model etc.)
        /script
            /run.py
                train and val function
                test function
                main function
            /visualize.py
                load dataset vocab
                visualize predictions
                main function

    Structure of pytorch geometric (parts that could be relevant to implementation, meaning new/changed files in dirs):
        /examples
            example implementations of models on pyg datasets
        /torch_geometric
            /datasets
                custom dataset classes for specific datasets (descending from Dataset class), including transforms, pre-processing etc.
            /nn
                /conv
                    conv layer classes
                /models
                    model classes
                /utils
                    utility functions related to neural networks
            /utils
                other utils
    }
    ```
    - plan for NBFNet PyG implementation, based on the official (NBFNet-PyG) codebase:

        0. run a training using original implementation
        1. identify which parts of the codebase to include in PyG, each requires a separate python file. For now im working in the NBFNet-PyG repo file system
        2. identify redundant function definitions, code snippets (functions that no longer require a custom implementation and/or have since been added to PyG)
        3. create plan for merging remaining important parts of the original codebase into above files (helper, utility functions)
        4. identify further redundancies (eg. whether to include distributed training)
        5. transfer files into cloned PyG repo
        6. consider further improvements/additions
        7. write unit tests for layer (optionally for model too)
        8. documentation 
6. Week
    - setting up workspace... :(
    - Refactoring NBFNet-PyG based on plans:
        0. run a training using original implementation
            - in datasets.py line 30, torch.load() function call I have to explicitly specify weights_only=False because of changes to default value of param in PyG 2.6
            - in layers.py line 80-82 I had to fix _check_input and _collect function calls (function names have changed)
            - runs
        1. identify which parts of the codebase to include in PyG, each requires a separate python file. For now im working in the NBFNet-PyG repo file system
            - crucial:
                layers (layers.py)
                models (models.py)
            - optional:
                examples (run.py)
        2. identify redundant function definitions, code snippets (functions that no longer require a custom implementation and/or have since been added to PyG)
            - layers.py: 
                - init:
                    - receives additional param: aggregate_kwargs, passes it to super().init
                        - allows usage of existing PyG aggregation function DegreeScalerAggregation (pna)
                    - super().init() now resolves the class of, and initializes the aggr function provided in params
                - propagate function does not require custom implementation
                - aggregate function:
                    - replace 'add self loops' custom implementation with existing function
                    - replace custom aggregation implementation with super().aggregate() -> calls initialized aggregation object's forward() method 
                - message funcion:
                    - torch_geometric/nn/kge folder contains classes for embedding edges (transe, distmult, rotate) \
                    NOT YET IMPLEMENTED
        3. create plan for merging remaining important parts of the original codebase into above files (helper, utility functions)
            - from tasks.py: move function 'edge_match' to models.py
            - from util.py: move get_device to run.py
7. Week
