#!/bin/bash
source ./docker_params

# If the git repository exists and it is not shared, prompt the user to make it shared
if [[ -e ".git" ]];
then
    if [[ $( git config core.sharedRepository ) != "true" ]];
    then
        echo "The repository is not shared (git config core.sharedRepository)."
        echo "If you will use git at any point you should make it shared because if not the file modifications from inside the container will break git."
        echo "Would you like to make the repo shared?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes )
                    echo "Changing repo to shared.";
                    git config core.sharedRepository true;
                    break;;
                No )
                    echo "Leaving it untouched.";
                    break;;
            esac
        done
    fi
fi

# Set permissions for newly created files. All new files will have the following permissions.
# Important is that the group permissions of the files created are set to read and write and execute.
# We add src as a volume, so we will be able to edit and delete the files created in the container.
if command -v setfacl &> /dev/null
then
    setfacl -PRdm u::rwx,g::rwx,o::r ./
else
    echo "setfacl command not found. Skipping setting permissions."
fi

# Check if container exists
if [[ $( docker ps -a -f name=$container_name | wc -l ) -eq 2 ]];
then
    echo "Container already exists. Do you want to restart it or remove it?"
    select yn in "Restart" "Remove"; do
        case $yn in
            Restart )
                echo "Restarting it... If it was started without USB, it will be restarted without USB.";
                docker restart $container_name;
                break;;
            Remove )
                echo "Stopping it and deleting it... You should simply run this script again to start it.";
                docker stop $container_name;
                docker rm $container_name;
                break;;
        esac
    done
else
    echo "Container does not exist. Creating it."
    docker run \
        --env DISPLAY=${DISPLAY} \
        --env NVIDIA_VISIBLE_DEVICES=all \
        --env NVIDIA_DRIVER_CAPABILITIES=all \
        --volume /tmp/.X11-unix:/tmp/.X11-unix \
        --volume ${src_folder}:/workspace \
        --volume ${data_folder}:/workspace/data \
        --volume ${requirements_file}:/workspace/requirements.txt \
        --network host \
        --interactive \
        --privileged \
        --detach \
        --tty \
        --gpus all \
        --runtime=nvidia \
        --name $container_name \
        $image_name:$image_tag 
fi