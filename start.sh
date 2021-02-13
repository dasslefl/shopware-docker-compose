#!/bin/bash

shopware_url="https://releases.shopware.com/sw6/install_v6.3.5.1_b2d5d91f1f2189b0112601b0cfd65073b2d12dd4.zip"
shopware_zip="shopware.zip"

shopware_dir="shopware"

shopware_php="php7.4-shopware"

execute_echo() {
    echo $ $@
    $@
    exitcode=$?

    if [ "$exitcode" -ne 0 ]; then
        echo 
        echo " --- ERROR DURING INSTALLATION ---"
        echo "The previous command exited with Code $exitcode"
        echo "Do you have sufficient privileges?"
        exit $exitcode
    fi
}

install_package() {
    echo " - Installing package $1"

    if (( $EUID != 0 )); then
        echo
        echo " --- ERROR DURING INSTALLATION ---"
        echo "Packages can only be installed as root."
        exit 1
    fi

    execute_echo apt-get install -y $1
}

checkfor() {
    echo -n " - Ckecking for $1 - "
    if [ -x "$(command -v $1)" ]; then
        echo "Found."
        return 0
    else
        echo "NOT FOUND."
        return 1
    fi
}

# Check for wget and unzip
checkfor wget || install_package wget
checkfor unzip || install_package unzip

# Check for Docker and Docker-Compose
checkfor docker         || install_package docker.io
checkfor docker-compose || install_package docker-compose

# Check if user has access to docker
echo
execute_echo docker images
echo

# Check if custom php-fpm is installed
if docker images | grep -q "$shopware_php"; then
    echo "Custom PHP Docker image '$shopware_php' found."
else
    echo "Custom PHP Docker image '$shopware_php' not found."
    echo "Building '$shopware_php'..."

    execute_echo docker build -t $shopware_php $shopware_php/
fi

echo

# Check if shopware is installed
if [ -d "$shopware_dir" ]; then
    echo "Shopware installation detected."
else
    echo "Installing shopware 6 from '$shopware_url'..."

    execute_echo wget -O "$shopware_zip" "$shopware_url"

    execute_echo mkdir "$shopware_dir"
    execute_echo unzip -d "$shopware_dir" "$shopware_zip"

    # Necessary for some Shopware temp files
    execute_echo chmod 777 "$shopware_dir"
    find "$shopware_dir" -type d -print0 | xargs -0 chmod 755

    execute_echo rm "$shopware_zip"
fi

# Starting up
echo 
echo Starting Shopware 6...

execute_echo docker-compose up