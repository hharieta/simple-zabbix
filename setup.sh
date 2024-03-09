#!/usr/bin/env bash

# Script Name: create_vol.sh
# Author: Inge Gatovsky
# Date: 04/03/24
# Description: configure and create a new volume for zabbix 

source colors.sh

DOCKER_BIN=$(which docker)
DOCKERCOMPOSE_FILE="docker-compose.yaml"
ABS_PATH=$(pwd)

function test_dirs {

    if [[ ! -d "zabbix-volumes" ]]; then

        echo -e "${red}Zabbix-volumes directory does not exist${end}\n"
        echo -e "${yellow}Creating zabbix-volumes directory${end}\n"

        mkdir -p zabbix-volumes/alertscripts \
            zabbix-volumes/data-mysql \
            zabbix-volumes/externalscripts \
            zabbix-volumes/modules \
            zabbix-volumes/enc \
            zabbix-volumes/ssl/certs \
            zabbix-volumes/ssl/keys \
            zabbix-volumes/ssl/ssl_ca \
            zabbix-volumes/snmptraps \
            zabbix-volumes/mibs
    else
        echo -e "${green}zabbix-volumes already exists${end}\n"
        echo -e "${blue}Skiping creation dirs${end}\n"
    fi
}

function test_sock {
    if [[ -S /var/run/docker.sock ]]; then
        DOCKER_SOCK=/var/run/docker.sock
    elif [[ -S /run/user/$(id -u)/docker.sock ]]; then
        DOCKER_SOCK=/run/user/$(id -u)/docker.sock
    else
        # TODO: start docker service
        echo -e "\n${yellow}Docker Service dead or not exists${end}"
        echo -e "${yellow}Starting Docker...${end}"

        unameOut="$(uname -s)"
        if [[ $unameOut == "Linux" ]]; then
            sudo systemctl start docker
            sleep 10
        elif [[ $unameOut == "Darwin" ]]; then
            open /Applications/Docker.app
            sleep 10
        else
            echo -e "${red}OS not supported${end}"
            echo -e "${yellow}Exiting...${end}"
            exit 1
        fi
        DOCKER_SOCK=/var/run/docker.sock
    fi
}

test_dirs
test_sock

set -euo pipefail
if [[ $DOCKER_SOCK ]] && [[ -f $DOCKERCOMPOSE_FILE ]]; then
    docker-compose build --no-cache
    docker-compose -f $DOCKERCOMPOSE_FILE up -d
else
    if [[ ! -f $DOCKERCOMPOSE_FILE ]]; then
        echo -e "${red}Docker-compose file does not exist${end}"
        echo -e "${yellow}Exiting...${end}"
        exit 1
    else
        echo -e "${red}Docker Service not running${end}"
        echo -e "${yellow}Exiting...${end}"
        exit 1
    fi
fi



