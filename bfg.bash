#! /bin/bash
# //////////////////////////////////////////////////////////////////////////////////////////
#   File Type   :- BASH Script (needs GIT-CLI,  docker-CLI and AZURE-CLI installed). 
#  
#   Description :- This script builds "waardepapieren" containers and ships images to hub.docker.com and beyond to ACI
#   Modified           Date           Description
#   Peter Bosch        20200105        bash file generator   
#
# //////////////////////////////////////////////////////////////////////////////////////////
#  File:            :bfg.bash   
#  version          :20200101 v0
#  File Type        :Bash is a command processor that typically runs in a text window 
#                    Bash can also read and execute commands from a file, called a shell script.
#  Purpose          :download - Clone - Build - Ship - Deploy  @datafluisteraar
#  Title:           :cloutuh  
#  Category         :CI CD  bash file genererator
#  Identificatie    :https://github.com/BoschPeter/AZ_ACI_waardepapieren-demo_westeurope_azurecontainer_io
#                    curl -o bfg.bash  https://raw.githubusercontent.com/boschpeter/waardepapieren/master/bfg.bash

#  https://waardepapieren-demo.discipl.org/    BSN=663678651
#  example Pim Otte
#  10dec 2:35 PM @Bas Als het goed is werkt https://waardepapieren-demo.discipl.org/
#  Ik had wel hier problemen met de ICTU firewall die het blokkeerde, ik moest met mijn telefoon op 4g om het werkend te krijgen
#  https://waardepapieren-demo.westeurope.cloudapp.azure.com  VM
#  https://waardepapieren-demo.westeurope.azurecontainer.io ACI
#  https://waardepapieren-demo.westeurope.azurecontainer.io ACI


# forked from https://github.com/discipl/waardepapieren.git read.ME
# Running
#
# The easiest way to run is using docker-compose:  ...but needs a (virtual) machine to run on. (no K8s no ACI)
#
# With docker compose you use a simple text file to define an application that consists of multiple Docker containers.
# You then run your application with a single command that does everything to implement your defined environment.
# This will start 3 applications:
#
# clerk-frontend
# waardepapieren-service, with embedded ephemeral-server
# nlx-mock, which is an nlx-outway that provides access to a mock BRP service
#
# Run docker-compose up#  Run docker-compose down  a.k.a restart.  stop /start
#
# Alternatively, you can use an offline mock, which replicates the NLX environment.
#
# Run docker-compose -f docker-compose-travis.yml up
# The clerk frontend will be available at https://$CERT_HOST_IP:443 on your local pc. 
# Below the cookbook to deploy your containers as a so called ACI Azure Container Instance. 
# simular to k8s pod ?

# This is done as follows:
# Set the environment variable CERT_HOST_IP is with an IP (or domain) that the validator app can use to reach the clerk-frontend container.  
# Ensure that the validator expo app runs on the same (wifi) network as the clerk frontend. (BSN=663678651)
# You build a docker on your laptop and then you are the same as in production. That is why you should use containers btw docker is not fast
# Naming your containers


# ===== INSTRUCTIONS ======
# 1. SET your variable ... from menu
# 2. run this script as follows 
#     ./bfg.bash mm 4 waardepapieren-demo.westeurope.cloudapp.azure.com   (mainmenu docker_tagversion:4 target_FQDN)

# if [ ${PROMPT} = true ] 
# then
# echo "arg1="$1  # mm 
# echo "arg2="$2  # 4
# echo "arg3="$3  # $CERT_HOST_IP  (Azure VM)
#                 # discipl.westeurope.azurecontainer.io   (Azure Container Instance)
# fi 

### barf  
enter_cont() {
    echo
    echo
    echo -n "Press enter to Continue"
    read
}

# here we go
# ----------------------------------
# Step : Define variables
# ----------------------------------

# define your feedback here

GIT_REPO=${PWD##*/}    # waardepapieren
GIT_USER=boschpeter
DOCKER_USER=boscp08
AZURE_USER=bosch.peter@outlook.com
GITHUB_DIR=${PWD}      # /Users/boscp08/Projects/scratch/virtual-insanity/waardepapieren


DOUBLE_CHECK=true  
WRITE_CODE=true
PROMPT=true # echo parameters
            
if [ "$1" = "mm" ]
   then
    MENU=true
    DOCKER_VERSION_TAG=$2
    AZ_RESOURCE_GROUP="Discipl_Wigo4it_DockerGroup$2"

    CERT_HOST_IP=$3             #FQDN
    CERT_HOST_IP_WP_SERVICE_HOSTNAME=$3
    IFS=. url_components=($3##*-})
    AZ_DNSNAMELABEL=${url_components[0]} #discipl (.westeurope.cloudapp.azure.com)
   else 
    MENU=true
    echo "~~~~~~~~~~~~~~~~~~~~~"	
    DOCKER_VERSION_TAG=""
    AZ_RESOURCE_GROUP=""
    CERT_HOST_IP=""            ß
    CERT_HOST_IP_WP_SERVICE_HOSTNAME=""
    echo "~~~~~~~~~~~~~~~~~~~~~"	

fi

MOCK_NLX="mock-nlx"
WAARDEPAPIEREN_SERVICE="waardepapieren-service"
CLERK_FRONTEND="clerk-frontend"
COMPOSE_BUILD_FLAG=" --build"
#EPHEMERAL_RETENTION_TIME=86400  #24h 
#/waardepapieren-service/configuration  ??
EPHEMERAL_RETENTION_TIME_COMPOSE_TRAVIS=2592020 #30 dagen  

#EPHEMERAL_RETENTION_TIME_COMPOSE=2592021 #30 dagen
#EPHEMERAL_RETENTION_TIME_CONFIG=2592022 #30 dagen

#'********** end of parameters **********
#'Below the functions that are called by other functions
# modify at your own peril! because of configuration drift   100% generation

##################################################################
# Purpose: get latests batch file generator from repo
# Arguments:  
# Return: 
##################################################################

get_curl_bfg() {
cd $GITHUB_DIR
curl -o bfg.bash https://raw.githubusercontent.com/boschpeter/waardepapieren/master/bfg.bash
#.bfg.bash mm 2 waardepapieren-demo.westeurope.cloudapp.azure.com
}

##################################################################
# Purpose: show main menu 
# Arguments: 
# Return: 
##################################################################
show_main_menu(){
clear 

# A menu driven shell script 
#"A menu is nothing but a list of commands presented to a user by a shell script"

# ----------------------------------
# Step: User defined function
# ----------------------------------
pause(){
  read -p "Press [Enter] key to continue..." fackEnterKey
} 
# function to display menus
show_menus() {
	
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo " M A I N - M E N U "
  echo "~~~~~~~~~~~~~~~~~~~~~"
  echo "https://$CERT_HOST_IP:443  DOCKER-VERSION_TAG=$DOCKER_VERSION_TAG " 
  echo "~~~~~~~~~~~~~~~~~~~~~"
  echo "10. docker_system_prune                                     "  
  echo "11. get_curl_waardepapieren                                 "
  echo "12  show_parameters                                         "
  echo "20. set_docker_compose_travis_yml_without_volumes           "  
  echo "21. set_Dockerfile_mock_nlx                                 " 
  echo "22. set_Dockerfile_clerk_frontend_without_volumes           "
  echo "23. set_Dockerfile_waardepapieren_without_volumes  " 
  echo "24. set_clerk_frontend_nginx_conf                           "
  echo "25. set_waardepapieren_service_config_compose_travis_json   "  
  echo "30. set_all_Dockerfiles          $CERT_HOST_IP               "                         
  echo "~~~~~~~~~~~~~~~~~~~~~"	
  echo "40. docker_compose_images        $COMPOSE_BUILD_FLAG ${GIT_REPO}_${MOCK_NLX} + ${GIT_REPO}_${WAARDEPAPIEREN_SERVICE} + ${GIT_REPO}_${CLERK_FRONTEND}  " 
  echo "41. docker_build_images          ${GIT_REPO}_${MOCK_NLX} + ${GIT_REPO}_${WAARDEPAPIEREN_SERVICE} + ${GIT_REPO}_${CLERK_FRONTEND}"  
  echo "42. docker_tag_images            $DOCKER_VERSION_TAG        " 
  echo "43. docker_login                 $DOCKER_USER               " 
  echo "44. docker_push_images           ${GIT_REPO}_${MOCK_NLX} + ${GIT_REPO}_${WAARDEPAPIEREN_SERVICE} + ${GIT_REPO}_${CLERK_FRONTEND} " 
  echo "~~~~~~~~~~~~~~~~~~~~~"	
  echo "50. azure_login                  $AZURE_USER                "  
  echo "51  set_azure_deploy_aci_yaml    $AZ_DNSNAMELABEL           " 
  echo "52. azure_delete_resourcegroup   $AZ_RESOURCE_GROUP         "
  echo "53. azure_create_resourcegroup   $AZ_RESOURCE_GROUP         " 
  echo "54. azure_create_containergroup  $AZ_RESOURCE_GROUP         " 
  echo "55. azure_restart_containergroup $AZ_RESOURCE_GROUP         " 
  echo "~~~~~~~~~~~~~~~~~~~~~"	
  echo "60. https://github.com/BoschPeter/$GIT_REPO   "
  echo "61. https://hub.docker.com/?ref=login         " 
  echo "62. https://portal.azure.com/\#home           " 
  echo "63. https://$CERT_HOST_IP:443                 " 
  echo "64. pim https://waardepapieren-demo.discipl.org BSN=663678651" 
	echo "~~~~~~~~~~~~~~~~~~~~~"	
  echo "70  . bfg.bash mm 0 localhost "
  echo "71  . bfg.bash mm 1 waardepapieren-demo.westeurope.cloudapp.azure.com "
  echo "72  . bfg.bash mm 1 discipl.westeurope.cloudapp.azure.com"
  echo "73  . bfg.bash mm 2 waardepapieren-demo.westeurope.azurecontainer.io"
  echo "74  . bfg.bash mm 4 discipl.westeurope.azurecontainer.io"
  echo "79.   get_this_batchfile_generator latest from repo " 
  echo "~~~~~~~~~~~~~~~~~~~~~"	
  echo "80. the_whole_sjebang                     "
  echo "81. " 
  echo "82. "
  echo "~~~~~~~~~~~~~~~~~~~~~"	
  echo "91. set_docker_compose_travis_yml_with_volumes  "  
  echo "92. set_Dockerfile_clerk_frontend_with_volumes  "
  echo "93. set_Dockerfile_waardepapieren_service_with_volumes "
  echo "99. Exit"
}
# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 100 form the menu option.

read_options(){
	local choice
	read -p "Enter choice [ 1 - 99] " choice
	case $choice in
        10) docker_system_prune                                                    ;;  
        11) get_curl_waardepapieren                                                ;;
        12) show_parameters                                                        ;;
        20) set_docker_compose_travis_yml_without_volumes                          ;;  
        21) set_Dockerfile_mock_nlx                                                ;;
        22) set_Dockerfile_clerk_frontend_without_volumes                          ;;
        23) set_Dockerfile_waardepapieren_without_volumes                          ;; 
        24) set_clerk_frontend_nginx_conf                                          ;;
        25) set_waardepapieren_service_config_compose_travis_json                  ;;  
        30) set_all_Dockerfiles                                                    ;;                        
        40) docker_compose_images                                                  ;; 
        41) docker_build_images                                                    ;;  
        42) docker_tag_images                                                      ;; 
        43) docker_login                                                           ;; 
        44) docker_push_images                                                     ;; 
        50) azure_login                                                            ;; 
        51) set_azure_deploy_aci_yaml                                              ;;
        52) azure_delete_resourcegroup                                             ;;
        53) azure_create_resourcegroup                                             ;; 
        54) azure_create_containergroup                                            ;; 
        55) azure_restart_containergroup                                           ;; 
        60) bookmark_open https://github.com/BoschPeter/$GIT_REPO                  ;;
        61) bookmark_open https://hub.docker.com/?ref=login                        ;; 
        62) bookmark_open https://portal.azure.com/\#home                          ;; 
        63) bookmark_open https://$CERT_HOST_IP:443                                ;; 
        64) bookmark_open https://waardepapieren-demo.discipl.org                  ;;
        #64) bookmark_open https://portal.azure.com/#@boschpeteroutlook.onmicrosoft.com/resource/subscriptions/cfcb03ea-255b-42f8-beca-2d4ac30779bb/resourceGroups/${AZ_RESOURCE_GROUP}/providers/Microsoft.ContainerInstance/containerGroups/$AZ_RESOURCE_GROUP/containers'  ;;
        70) bfg_bash_mm_0_localhost                                                ;;
        71) bfg_bash_mm_1_waardepapieren_demo_westeurope_cloudapp_azure_com        ;;
        72) bfg_bash_mm_2_discipl_demo_westeurope_cloudapp_azure_com               ;;
        73) bfg_bash_mm_3_waardepapieren_demo_westeurope_azurecontainer_io         ;;
        74) bfg_bash_mm_4_discipl_westeurope_azurecontainer_io                     ;;
        79) get_curl_bfg                                                           ;;
        80) the_whole_sjebang                                                      ;; 
        91) set_docker_compose_travis_yml_with_volumes                             ;;  
        92) set_Dockerfile_clerk_frontend_with_volumes                             ;;
        93) set_Dockerfile_waardepapieren_service_with_volumes                     ;;
        99) Exit                                                                   ;;
		*) echo -e "${RED}Error...${STD}" && sleep 1
	esac
}

# ----------------------------------------------
# Step #3: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
#trap '' SIGINT SIGQUIT SIGTSTP

# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
while true
do
	show_menus
	read_options
done

}




##################################################################
# Purpose: set docker-compose-travis.yml  original with volumes  (N/A in ACI k8s ?)
# Arguments: target 
# Return:  https://$CERT_HOST_IP
##################################################################
set_docker_compose_travis_yml_with_volumes() {
echo "-- Running:"${FUNCNAME[0]}" $@"
TT_DIRECTORY=${GITHUB_DIR}
TT_INSPECT_FILE=docker-compose-travis.yml 
enter_touch "${FUNCNAME[0]}" $@

cd $TT_DIRECTORY
echo "version: '3'
services:
  waardepapieren-service:
    volumes:
    - ./waardepapieren-service/system-test/certs:/certs:ro
    - ./waardepapieren-service/system-test/ephemeral-certs:/ephemeral-certs:ro
    - ./waardepapieren-service/configuration/:/app/configuration:ro
    build: waardepapieren-service/.
    links:
      - mock-nlx
    ports:
      - 3232:3232
      - 3233:3233
    environment:
    - WAARDEPAPIEREN_CONFIG=/app/configuration/waardepapieren-config-compose.json
    # Ignore self-signed ephemeral and NLX cert issues
    - NODE_TLS_REJECT_UNAUTHORIZED=0
  clerk-frontend:
    build:
      context: clerk-frontend/
      args:
        - CERTIFICATE_HOST=http://$CERT_HOST_IP:8880
    links:
      - waardepapieren-service
    ports:
    - 443:443
    - 8880:8880
    healthcheck:
      test: service nginx status
    volumes:
    - ./clerk-frontend/nginx/certs:/etc/nginx/certs:ro
  mock-nlx:
    image: nlxio/outway:latest
    volumes:
      - ./mock-nlx/certs:/certs:ro
    environment:
      - DIRECTORY_INSPECTION_ADDRESS=directory-inspection-api.demo.nlx.io:443
      - TLS_NLX_ROOT_CERT=/certs/root.crt
      - TLS_ORG_CERT=/certs/org.crt
      - TLS_ORG_KEY=/certs/org.key
      - DISABLE_LOGDB=1
    ports:
      - 80:80" >  "${TT_INSPECT_FILE}" 

check_check_doublecheck  "${FUNCNAME[0]}" $@
}


##################################################################
# Purpose: modify mock-nlx.Dockerfile
# Arguments: 
# Return: 
##################################################################
set_Dockerfile_mock_nlx() {  
echo "Running: "${FUNCNAME[0]}" $@"
TT_DIRECTORY=${GITHUB_DIR}/mock-nlx
TT_INSPECT_FILE=Dockerfile
enter_touch "${FUNCNAME[0]}" $@
cd $TT_DIRECTORY

echo "FROM node:10
RUN mkdir /app
ADD index.js package.json package-lock.json /app/
WORKDIR /app
RUN npm install --production
CMD npm start" > "${TT_INSPECT_FILE}" 

check_check_doublecheck  "${FUNCNAME[0]}" $@
}

##################################################################
# Purpose: set clerk-frontend Dockerfile with_volumes  default
# Arguments: 
# Return: 
##################################################################
set_Dockerfile_clerk_frontend_with_volumes() {
echo "Running: "${FUNCNAME[0]}" $@"
TT_DIRECTORY=${GITHUB_DIR}/clerk-frontend
TT_INSPECT_FILE=Dockerfile 
enter_touch "${FUNCNAME[0]}" $@
cd $TT_DIRECTORY

echo "FROM node:10
RUN mkdir /app
ADD package.json package-lock.json /app/
ENV REACT_APP_EPHEMERAL_ENDPOINT=https://$CERT_HOST_IP:443/api/eph
ENV REACT_APP_EPHEMERAL_WEBSOCKET_ENDPOINT=wss://$CERT_HOST_IP:443/api/eph-ws
WORKDIR /app
RUN npm install --unsafe-perm
ADD public /app/public
ADD src /app/src
ARG CERTIFICATE_HOST
ENV REACT_APP_CERTIFICATE_HOST=${CERTIFICATE_HOST}
RUN npm run build

FROM nginx:1.15.8
ADD nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=0 /app/build /usr/share/nginx/html" > "${TT_INSPECT_FILE}" 

check_check_doublecheck  "${FUNCNAME[0]}" $@

}

##################################################################
# Purpose: hack into waardepapieren-servcie Dockerfile with volunes default
# Arguments: 
# Return: 
##################################################################
set_Dockerfile_waardepapieren_service_with_volumes() {
echo "Running: "${FUNCNAME[0]}" $@"
TT_DIRECTORY=${GITHUB_DIR}/waardepapieren-service
TT_INSPECT_FILE=Dockerfile
enter_touch "${FUNCNAME[0]}" $@

cd $TT_DIRECTORY
echo "FROM node:10
RUN mkdir /app
ADD .babelrc package.json package-lock.json /app/
ADD src/* app/src/
ADD configuration/* app/configuration/
ENV WAARDEPAPIEREN_CONFIG /app/configuration/waardepapieren-config.json
WORKDIR /app
RUN npm install --production
CMD npm start"   > "${TT_INSPECT_FILE}" 

check_check_doublecheck  "${FUNCNAME[0]}" $@
}

##################################################################
# Purpose: set docker-compose-travis.yml
# Arguments: 
# Return: 
##################################################################
set_docker_compose_travis_yml_without_volumes() {
echo "Running: "${FUNCNAME[0]}" $@ "

TT_DIRECTORY=${GITHUB_DIR}
TT_INSPECT_FILE=docker-compose-travis.yml 
enter_touch "${FUNCNAME[0]}" $@

cd $TT_DIRECTORY
echo "version: '3'
services:
  waardepapieren-service:
    volumes:
      #- ./waardepapieren-service/system-test/certs:/certs:rw
      #- ./waardepapieren-service/system-test/ephemeral-certs:/ephemeral-certs:rw
      - ./waardepapieren-service/configuration/:/app/configuration2:rw  #FAKE
    build: waardepapieren-service/.
    links:
      - mock-nlx
    ports:
      - 3232:3232
      - 3233:3233
    environment:
      - WAARDEPAPIEREN_CONFIG=/app/configuration/waardepapieren-config-compose-travis.json
      # Ignore self-signed ephemeral cert issues
      - NODE_TLS_REJECT_UNAUTHORIZED=0
  clerk-frontend:
    build:
      context: clerk-frontend/
      args:
        - CERTIFICATE_HOST=http://${CERT_HOST_IP}:8880
    links:
      - waardepapieren-service
    ports:
      - 443:443
      - 8880:8880
    healthcheck:
      test: service nginx status
  #  volumes:
  #    - ./clerk-frontend/nginx/certs:/etc/nginx/certs:rw
  mock-nlx:
    build: mock-nlx/
    ports:
      - 80:80" > "${TT_INSPECT_FILE}" 

cat     "${TT_INSPECT_FILE}"   

check_check_doublecheck  "${FUNCNAME[0]}" $@
}

##################################################################
# Purpose: modify clerk-frontend.Dockerfile
# Arguments: 
# Return: 
##################################################################
set_Dockerfile_clerk_frontend_without_volumes() {
echo "Running: "${FUNCNAME[0]}" $@ "
TT_DIRECTORY=${GITHUB_DIR}/clerk-frontend
TT_INSPECT_FILE=Dockerfile 
enter_touch "${FUNCNAME[0]}" $@
cd $TT_DIRECTORY

echo "FROM node:10
RUN mkdir /app
ADD package.json package-lock.json /app/
ENV REACT_APP_EPHEMERAL_ENDPOINT=https://${CERT_HOST_IP}:443/api/eph
ENV REACT_APP_EPHEMERAL_WEBSOCKET_ENDPOINT=wss://${CERT_HOST_IP}:443/api/eph-ws
WORKDIR /app
RUN npm install --unsafe-perm
ADD public /app/public
ADD src /app/src
ARG CERTIFICATE_HOST
ENV REACT_APP_CERTIFICATE_HOST=http://${CERT_HOST_IP}:8880

$TIMEZONE
$APT_GET_UPDATE
$APT_GET_INSTAL
$APT_GET_INSTALL_IPUTILS_PING

RUN npm run build

FROM nginx:1.15.8
ADD nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=0 /app/build /usr/share/nginx/html
#  volumes:
#    - ./clerk-frontend/nginx/certs:/etc/nginx/certs:rw
RUN mkdir /etc/nginx/certs
ADD nginx/certs/org.crt /etc/nginx/certs/org.crt
ADD nginx/certs/org.key /etc/nginx/certs/org.key"  > "${TT_INSPECT_FILE}" 

check_check_doublecheck  "${FUNCNAME[0]}" $@
}

##################################################################
# Purpose: hack into waardepapieren-service Dockerfile
# Arguments: 
# Return: 
##################################################################
set_Dockerfile_waardepapieren_service_without_volumes() {
echo "Running: "${FUNCNAME[0]}" $@"
TT_DIRECTORY=${GITHUB_DIR}/waardepapieren-service
TT_INSPECT_FILE=Dockerfile
enter_touch "${FUNCNAME[0]}" $@

cd $TT_DIRECTORY
echo "FROM node:10
RUN mkdir /app
ADD .babelrc package.json package-lock.json /app/
ADD src/* app/src/
ADD configuration/* app/configuration/
#- ./waardepapieren-service/system-test/certs:/certs:ro
RUN mkdir /certs
ADD system-test/certs/org.crt /certs/org.crt
ADD system-test/certs/org.key /certs/org.key
#- ./waardepapieren-service/system-test/ephemeral-certs:/ephemeral-certs:ro
RUN mkdir /ephemeral-certs
ADD system-test/ephemeral-certs/org.crt /ephemeral-certs/
ADD system-test/ephemeral-certs/org.key /ephemeral-certs/
#- ./waardepapieren-service/configuration/:/app/configuration:ro

WORKDIR /app
RUN mkdir /configuration
ADD configuration/waardepapieren-config-compose.json /app/configuration
ADD configuration/waardepapieren-config-compose-travis.json /app/configuration
ADD configuration/waardepapieren-config.json /app/configuration
ENV WAARDEPAPIEREN_CONFIG /app/configuration/waardepapieren-config.json

$TIMEZONE
$APT_GET_UPDATE
$APT_GET_INSTAL
$APT_GET_INSTALL_IPUTILS_PING

RUN npm install --production
CMD npm start"  > "${TT_INSPECT_FILE}" 
check_check_doublecheck  "${FUNCNAME[0]}" $@
}


##################################################################
# Purpose: hack into clerk-frontend build in nginx
# Arguments: 
# Return: 
##################################################################
set_clerk_frontend_nginx_conf() {
echo "Running: "${FUNCNAME[0]}" $@"
TT_DIRECTORY=${GITHUB_DIR}/clerk-frontend/nginx
TT_INSPECT_FILE=nginx.conf
enter_touch "${FUNCNAME[0]}" $@

cd $TT_DIRECTORY
echo "events {
    worker_connections  1024;
}


http {

    map $http_upgrade $connection_upgrade {
        default upgrade;
        '' close;
    }

    # Http server to obtain NLX certificate
    server {
        listen 8880;

        location / {
           root /usr/share/nginx/html;
           include /etc/nginx/mime.types;
        }
    }

    server {
        listen 443 ssl;

        ssl_certificate /etc/nginx/certs/org.crt;
        ssl_certificate_key /etc/nginx/certs/org.key;

        location /api/eph/ {
            proxy_pass https://$CERT_HOST_IP:3232/;
        }

        location /api/eph-ws {
            proxy_pass https://$CERT_HOST_IP:3232;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "Upgrade";
        }
        location / {
            root /usr/share/nginx/html;
            include /etc/nginx/mime.types;
        }
    }
}" > "${TT_INSPECT_FILE}" 

check_check_doublecheck  "${FUNCNAME[0]}" $@ 

} 


##################################################################
# Purpose: 
# Arguments: 
# Return: 
##################################################################
set_waardepapieren_service_config_json() {
echo "Running: "${FUNCNAME[0]}" $@"
TT_DIRECTORY=${GITHUB_DIR}/waardepapieren-service/configuration
TT_INSPECT_FILE=waardepapieren-config.json
enter_touch "${FUNCNAME[0]}" $@

cd $TT_DIRECTORY
echo "{
  \"EPHEMERAL_ENDPOINT\" : \"https://$CERT_HOST_IP:3232\",
  \"EPHEMERAL_WEBSOCKET_ENDPOINT\" : \"wss://$CERT_HOST_IP:3232\",
  \"EPHEMERAL_CERT\": \"/ephemeral-certs/org.crt\",
  \"EPHEMERAL_KEY\": \"/ephemeral-certs/org.key\",
  \"NLX_OUTWAY_ENDPOINT\" : \"http://$CERT_HOST_IP:80\",
  \"NLX_CERT\": \"/certs/org.crt\",
  \"NLX_KEY\": \"/certs/org.key\",
  \"LOG_LEVEL\": \"info\",
  \"EPHEMERAL_RETENTION_TIME\": 86400,
  \"PRODUCT_NEED\" : \"BRP_UITTREKSEL_NEED\",
  \"SOURCE_NLX_PATH\" : \"/brp/basisregistratie/natuurlijke_personen/bsn/{BSN}\",
  \"SOURCE_ARGUMENT\" : \"BSN\",
  \"PRODUCT_ACCEPT\" : \"BRP_UITTREKSEL_ACCEPT\",
  \"PRODUCT_NAME\" : \"Gewaarmerkt digitaal afschrift van gegevens uit de basisregistratie personen (BRP)\",
  \"PRODUCT_DESCRIPTION\" : \"Uittreksel Basis Registratie Persoonsgegevens\",
  \"PRODUCT_PURPOSE\" : \"Bewijs verblijfadres in woonplaats\",
  \"SOURCE_DATA_SELECTION\" : [
    {\"Burgerservicenummer (BSN)\" : \"burgerservicenummer\"},
    {\"Woonplaats verblijfadres\" : \"verblijfadres.woonplaats\"}
  ]
}" > "${TT_INSPECT_FILE}" 

check_check_doublecheck  "${FUNCNAME[0]}" $@
}

##################################################################
# Purpose: hack 
# Arguments: 
# Return: 
##################################################################
set_waardepapieren_service_config_compose_json() {
echo "Running: "${FUNCNAME[0]}" $@"
TT_DIRECTORY=${GITHUB_DIR}/waardepapieren-service/configuration
TT_INSPECT_FILE=waardepapieren-config-compose.json
enter_touch "${FUNCNAME[0]}" $@

cd $TT_DIRECTORY
echo "{
  \"EPHEMERAL_ENDPOINT\" : \"https://$CERT_HOST_IP:3232\",
  \"EPHEMERAL_WEBSOCKET_ENDPOINT\" : \"wss://$CERT_HOST_IP:3232\",
  \"EPHEMERAL_CERT\": \"/ephemeral-certs/org.crt\",
  \"EPHEMERAL_KEY\": \"/ephemeral-certs/org.key\",
  \"NLX_OUTWAY_ENDPOINT\" : \"https://$CERT_HOST_IP:443\",
  \"NLX_CERT\": \"/certs/org.crt\",
  \"NLX_KEY\": \"/certs/org.key\",
  \"LOG_LEVEL\": \"info\",
  \"EPHEMERAL_RETENTION_TIME\": 86400,
  \"PRODUCT_NEED\" : \"BRP_UITTREKSEL_NEED\",
  \"SOURCE_NLX_PATH\" : \"/brp/basisregistratie/natuurlijke_personen/bsn/{BSN}\",
  \"SOURCE_ARGUMENT\" : \"BSN\",
  \"PRODUCT_ACCEPT\" : \"BRP_UITTREKSEL_ACCEPT\",
  \"PRODUCT_NAME\" : \"Gewaarmerkt digitaal afschrift van gegevens uit de basisregistratie personen (BRP)\",
  \"PRODUCT_DESCRIPTION\" : \"Uittreksel Basis Registratie Persoonsgegevens\",
  \"PRODUCT_PURPOSE\" : \"Bewijs verblijfadres in woonplaats\",
  \"SOURCE_DATA_SELECTION\" : [
    {\"Burgerservicenummer (BSN)\" : \"burgerservicenummer\"},
    {\"Woonplaats verblijfadres\" : \"verblijfadres.woonplaats\"}
  ]
}" > "${TT_INSPECT_FILE}" # waardepapieren-config-compose-travis.json

check_check_doublecheck  "${FUNCNAME[0]}" $@
}



#################################################################
# Purpose: hack 
# Arguments: 
# Return: 
##################################################################
set_waardepapieren_service_config_compose_travis_json() {
echo "Running: "${FUNCNAME[0]}" $@"
TT_DIRECTORY=${GITHUB_DIR}/waardepapieren-service/configuration
TT_INSPECT_FILE=waardepapieren-config-compose-travis.json
enter_touch "${FUNCNAME[0]}" $@

cd $TT_DIRECTORY
echo "{
  \"EPHEMERAL_ENDPOINT\" : \"https://$CERT_HOST_IP:3232\",
  \"EPHEMERAL_WEBSOCKET_ENDPOINT\" : \"wss://$CERT_HOST_IP:3232\",
  \"EPHEMERAL_CERT\": \"/ephemeral-certs/org.crt\",
  \"EPHEMERAL_KEY\": \"/ephemeral-certs/org.key\",
  \"NLX_OUTWAY_ENDPOINT\" : \"http://$CERT_HOST_IP:80\",
  \"NLX_CERT\": \"/certs/org.crt\",
  \"NLX_KEY\": \"/certs/org.key\",
  \"LOG_LEVEL\": \"info\",
  \"EPHEMERAL_RETENTION_TIME\": 86400,
  \"PRODUCT_NEED\" : \"BRP_UITTREKSEL_NEED\",
  \"SOURCE_NLX_PATH\" : \"/brp/basisregistratie/natuurlijke_personen/bsn/{BSN}\",
  \"SOURCE_ARGUMENT\" : \"BSN\",
  \"PRODUCT_ACCEPT\" : \"BRP_UITTREKSEL_ACCEPT\",
  \"PRODUCT_NAME\" : \"Gewaarmerkt digitaal afschrift van gegevens uit de basisregistratie personen (BRP)\",
  \"PRODUCT_DESCRIPTION\" : \"Uittreksel Basis Registratie Persoonsgegevens\",
  \"PRODUCT_PURPOSE\" : \"Bewijs verblijfadres in woonplaats\",
  \"SOURCE_DATA_SELECTION\" : [
    {\"Burgerservicenummer (BSN)\" : \"burgerservicenummer\"},
    {\"Woonplaats verblijfadres\" : \"verblijfadres.woonplaats\"}
  ]
}" > "${TT_INSPECT_FILE}" 

check_check_doublecheck  "${FUNCNAME[0]}" $@
}

##################################################################
# Purpose: set all docker (configuration) files
# Arguments: 
# Return: 
##################################################################
set_all_Dockerfiles() {
echo "Running: "${FUNCNAME[0]}" $@"
create_logfile_header "${FUNCNAME[0]}" $@

echo "set_docker_compose_travis_yml_without_volumes"
echo "set_Dockerfile_clerk_frontend_without_volumes"
echo "set_Dockerfile_waardepapieren_service_without_volumes"
echo "set_Dockerfile_mock_nlx"       
echo "set_clerk_frontend_nginx_conf" 
echo "set_waardepapieren_service_config_compose_travis_json"
echo "set_waardepapieren_service_config_compose_json"
echo "set_waardepapieren_service_config_json"
echo "set_azure_deploy_aci_yaml"
echo "okay ?"
echo enter

set_docker_compose_travis_yml_without_volumes 
set_Dockerfile_clerk_frontend_without_volumes 
set_Dockerfile_waardepapieren_without_volumes
set_Dockerfile_mock_nlx       

#set_docker_compose_travis_yml_with_volumes      
#set_Dockerfile_clerk_frontend_with_volumes 
#set_Dockerfile_waardepapieren_service_with_volumes 

set_clerk_frontend_nginx_conf 
set_waardepapieren_service_config_compose_travis_json
set_waardepapieren_service_config_compose_json
set_waardepapieren_service_config_json
set_azure_deploy_aci_yaml

create_logfile_footer "${FUNCNAME[0]}" $@
}

##################################################################
# Purpose: hack into azure deploy ACI
# Arguments: 
# Return: 
##################################################################
set_azure_deploy_aci_yaml() {
echo "Running:"${FUNCNAME[0]}" $@"
TT_DIRECTORY=${GITHUB_DIR}
TT_INSPECT_FILE=deploy-aci.yaml
enter_touch "${FUNCNAME[0]}" $@

echo "location: westeurope
name: $AZ_RESOURCE_GROUP
properties:
  containers:
  - name: mock-nlx
    properties:
      image: ${DOCKER_USER}/${GIT_REPO}_${MOCK_NLX}:${DOCKER_VERSION_TAG}
      resources:
        requests:
          cpu: 1
          memoryInGb: 0.5
      ports:
      - port: 80
  - name: waardepapieren-service
    properties:
      image: ${DOCKER_USER}/${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}:${DOCKER_VERSION_TAG}
      resources:
        requests:
          cpu: 1
          memoryInGb: 0.5
      ports:
      - port: 3232
      - port: 3233
  - name: clerk-frontend
    properties:
      image: ${DOCKER_USER}/${GIT_REPO}_${CLERK_FRONTEND}:${DOCKER_VERSION_TAG}
      resources:
        requests:
          cpu: 1
          memoryInGb: 0.5
      ports:
      - port: 443
      - port: 8880
  osType: Linu
  ipAddress:
    type: Public
    # fqdn wordt: discipl_waardepapieren.westeurope.azurecontainer.io
    dnsNameLabel: "$AZ_DNSNAMELABEL" 
    ports:
    - protocol: tcp
      port: '443' 
    - protocol: tcp
      port: '3232' 
    - protocol: tcp
      port: '3233' 
    - protocol: tcp
      port: '80'    
    - protocol: tcp
      port: '8880'      
tags: null
type: Microsoft.ContainerInstance/containerGroups" > "${TT_INSPECT_FILE}" 

check_check_doublecheck  "${FUNCNAME[0]}" $@
}



# -----------------------------------
# Main-Menu logic  below
# ------------------------------------
#'# Structured programming:
#'# Entire program logic modularized in User defined function

the_world_is_flat=true
# ...do something interesting...
if ! [ "$the_world_is_flat" = true ] ; then
    echo 'Be careful not to fall off!'
fi

#################################################################
# Purpose:Copy the specific file's raw link from GitHub.(As you open the file in Github, 
# Arguments:  on the top right corner you can see the option to open the file in raw mode. 
# Return: Open it in raw mode and copy the URL) curl -o filename raw-link-to-file
##################################################################

get_curl_waardepapieren() {

create_logfile_header "${FUNCNAME[0]}" $@
clear
echo "-- Running:"${FUNCNAME[0]}" $@"   >> "${LOG_FILE}"
curl -o ${GITHUB_DIR}/docker-compose-travis.yml "https://raw.githubusercontent.com/discipl/waardepapieren/master/docker-compose-travis.yml"
stat ${GITHUB_DIR}/docker-compose-travis.yml                           >> "${LOG_FILE}"

curl -o ${GITHUB_DIR}/mock-nlx/Dockerfile "https://raw.githubusercontent.com/discipl/waardepapieren/master/mock-nlx/Dockerfile"
stat    ${GITHUB_DIR}/mock-nlx/Dockerfile                              >> "${LOG_FILE}"

curl -o ${GITHUB_DIR}/clerk-frontend/Dockerfile "https://raw.githubusercontent.com/discipl/waardepapieren/master/clerk-frontend/Dockerfile"
stat    ${GITHUB_DIR}/clerk-frontend/Dockerfile                        >> "${LOG_FILE}"



curl -o ${GITHUB_DIR}/clerk-frontend/nginx/nginx.conf "https://raw.githubusercontent.com/discipl/waardepapieren/master/clerk-frontend/nginx/nginx.conf"
stat    ${GITHUB_DIR}/clerk-frontend/nginx/nginx.conf                  >> "${LOG_FILE}"

curl -o ${GITHUB_DIR}/waardepapieren-service/Dockerfile "https://raw.githubusercontent.com/discipl/waardepapieren/ddd9d45750e560b594454cfd3274e2bfa0215208/waardepapieren-service/Dockerfile"
stat    ${GITHUB_DIR}/waardepapieren-service/Dockerfile                 >> "${LOG_FILE}"

curl -o ${GITHUB_DIR}/waardepapieren-service/configuration/waardepapieren-config-compose-travis.json "https://raw.githubusercontent.com/discipl/waardepapieren/master/waardepapieren-service/configuration/waardepapieren-config-compose-travis.json"
stat    ${GITHUB_DIR}/waardepapieren-service/configuration/waardepapieren-config-compose-travis.json            >> "${LOG_FILE}"
clear

curl -o ${GITHUB_DIR}/waardepapieren-service/configuration/waardepapieren-config-compose.json  "https://github.com/discipl/waardepapieren/blob/ddd9d45750e560b594454cfd3274e2bfa0215208/waardepapieren-service/configuration/waardepapieren-config-compose.json"
stat    ${GITHUB_DIR}/waardepapieren-service/configuration/waardepapieren-config-compose.json                  >> "${LOG_FILE}"

curl -o ${GITHUB_DIR}/waardepapieren-service/configuration/waardepapieren-config.json "https://raw.githubusercontent.com/discipl/waardepapieren/ddd9d45750e560b594454cfd3274e2bfa0215208/waardepapieren-service/configuration/waardepapieren-config.json"
stat    ${GITHUB_DIR}/waardepapieren-service/configuration/waardepapieren-config.json                           >> "${LOG_FILE}"


create_logfile_footer "${FUNCNAME[0]}" $@

}

# /////////////////////////////////////////////////////////////////////////////////
#  Create a Header in the logfile
# /////////////////////////////////////////////////////////////////////////////////
create_logfile_header() {
    JOB_START_DATE_TIME=`date +%Y%m%d_%H_%M`
    echo $JOB_START_DATE_TIME - BEGIN JOB:                                             >> "${LOG_FILE}"
    echo ----------------------------------------------------------------------------- >> "${LOG_FILE}"
    echo $1 $2                                                                         >> "${LOG_FILE}"
    echo ----------------------------------------------------------------------------- >> "${LOG_FILE}"
    }

# /////////////////////////////////////////////////////////////////////////////////
#  Create a Footer in the logfile
# /////////////////////////////////////////////////////////////////////////////////
create_logfile_footer() {
    JOB_END_DATE_TIME=`date +%Y%m%d_%H_%M`
    echo $JOB_END_DATE_TIME - END JOB :                                                >> "${LOG_FILE}"
    echo ----------------------------------------------------------------------------- >> "${LOG_FILE}"
    echo $1 $2                                                                         >> "${LOG_FILE}"
    echo ----------------------------------------------------------------------------- >> "${LOG_FILE}"
    }

##################################################################
# Purpose: Procedure to create directories specified
# Arguments: 
# Return: To check if a directory exists in a shell script you can use the following:
##################################################################
create_logdir() {
if ! [ -d "${LOG_DIR}" ]; then
  cd $PROJECT_DIR
  chmod -R 777  ${GITHUB_DIR}
  #mkdir  ${LOG_DIR}

# if [ `uname` = 'Linux' ]
#   then  HOME_DIR=/home/`whoami`   
#   echo "linux"
# fi  
# 
# if  [ `uname` = 'Darwin' ]
#     then  HOME_DIR=/Users/`whoami`    
#    echo "MacOs"
# fi
# 
# if  [ `uname` = 'CYGWIN_NT-10.0' ]
#     then  HOME_DIR=/c/Users/`whoami`    
#    echo "Windows10  ... /home/Gebruiker/Projects/scratch/virtual-insanity/waardepapieren"
#    # a.k.a 
# fi
# PROJECT_DIR=$HOME_DIR/Projects/scratch/virtual-insanity  

fi 
}

##################################################################
# Purpose: #echo ${PROJECT_DIR} | awk -F/ '{print "/"$2"/"$3"/"$4"/"$5"/"$6}'
# Arguments: directory structure  #/home/boscp08/Projects/scratch/virtual-insanity
# Return: a folder  /home/boscp08/Dropbox/tt/Waardepapieren-AZURE-ACI
##################################################################
 make_folder() 
    {
     #echo $1
    
   if ! [ -d $1 ]; then
    echo $1 > struct.txt
    sed '/^$/d;s/ /\//g' struct.txt | xargs mkdir -p 
    rm struct.txt
     
     if [ ${PROMPT} = true ]   
        then 
        echo "$1 Directorie(s) have been made"
        cd $1
        pwd
    fi   
    
    #else   echo "$1 directory already exists "
   fi
   }

##################################################################
# Purpose: Procedure to create an empty file
# Arguments: 
# Return: 
##################################################################
enter_touch() {
cd ${TT_DIRECTORY}
touch "${TT_INSPECT_FILE}"
}

##################################################################
# Purpose:   procedure 
# Arguments: 
# Return: 
##################################################################
check_check_doublecheck() {
if [ ${DOUBLE_CHECK} =  true ]
#echo "check check double check"
#enter_cont

then enter_inspect $1
fi 
TT_DIRECTORY=""
TT_INSPECT_FILE=""
}

##################################################################
# Purpose:   show content of Dockerfile/ configfiles. 
# Arguments: 
# Return: 
##################################################################
enter_inspect() {
clear

if [ -f "${TT_INSPECT_FILE}" ]; 
then
 
echo "| ${LOG_START_DATE_TIME} | "${TT_INSPECT_FILE}"|"                              >> "${LOG_FILE}" 
echo "| ${LOG_START_DATE_TIME} | ${TT_DIRECTORY} |"                                  >> "${LOG_FILE}"
echo "<code>"                                                                        >> "${LOG_FILE}"
cat  "${TT_INSPECT_FILE}"                                                            >> "${LOG_FILE}"
echo "</code>"                                                                       >> "${LOG_FILE}"
create_logfile_footer

else 
cd ${GITHUB_DIR}
clear
echo "File "${TT_INSPECT_FILE}" is missing or cannot be executed"   
enter_cont
fi

if [ ${PROMPT} = true ] 
then 
clear

echo ""
echo "========="
pathname=${TT_DIRECTORY}
echo "enter inspect : "${TT_INSPECT_FILE}" " 
echo "folder        = $(basename $pathname) "
echo "directory     = $pathname "
echo "repo          = $GITHUB_DIR "
echo "function      = $1 "
echo "========="
echo ""
cd ${TT_DIRECTORY}
cat "${TT_INSPECT_FILE}" 
echo ""
echo "========="
pathname=${TT_DIRECTORY}
echo "enter inspect : "${TT_INSPECT_FILE}" " 
echo "folder        = $(basename $pathname) "
echo "directory     = $pathname "
echo "repo          = $GITHUB_DIR "
echo "function      = $1 "
echo "========="

enter_cont

cd $GITHUB_DIR

fi
}

##################################################################
# Purpose: create directories if neccecary.
# Arguments: 
# Return: specified directory structure
##################################################################
create_directories() {
make_folder ${PROJECT_DIR}     
make_folder ${LOG_DIR}
}

##################################################################
# Purpose: DOWNLOAD-FUNCTIONS
##################################################################

##################################################################
# Purpose: show version
# Arguments: 
# Return: 
##################################################################
show_version() {
create_logfile_header "${FUNCNAME[0]}" $@
echo "Running:"${FUNCNAME[0]}" $@"
 echo "git --version"
 git --version

 echo "docker -v  "
 docker -v
 
 echo "docker-compose -v "
 docker-compose -v 
 
 echo "az -v"
 az -v
 
 enter_cont 
}

##################################################################
# Purpose: Procedure to install Docker command line interface
# Arguments: 
# Return: 
##################################################################
install_docker_cli() {
echo "-Running: "${FUNCNAME[0]}" $@ "

#description	command
#1	install docker download	sudo install -y docker docker-common docker-client docker-compose
#2	enable docker daemon	systemctl enable docker
#3	and start docker daemon	systemctl start docker
#4	verify that docker daemon is active by running your first container	docker run hello-world
#but now as a 'normal' user
#g roupadd docker usermod -aG docker boscp08 systemctl restart docker docker run hello-world
#systemctl restart docker
}

##################################################################
# Purpose: Procedure to download azure command line interface
# Arguments: 
# Return: 
##################################################################
install_azure_cli() {
echo "-Running: "${FUNCNAME[0]}" $@"
sudo apt-get update
  sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg

#Down load en installeer de micro soft-handtekening sleutel:
#bash
#linux
curl -sL https://packages.microsoft.com/keys/microsoft.asc | 
    gpg --dearmor | 
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

#windows
}

##################################################################
# Purpose: P
# Arguments: 
# Return: 
##################################################################
set_credentials() {

DOCKER_USER=boscp08
DOCKER_PWD=P.\!.

AZURE_USER=bosch.peter@outlook.com
AZURE_PWD=0l.....n

GIT_USER=boschpeter
GIT_PWD=P...\!...


}

##################################################################
# Purpose: CLONE-FUNCTIONS   
##################################################################

#################################################
# Purpose: Procedure concurrent version system
# Arguments: 
# Return: 
##################################################################

git_init() {
echo "Running:"${FUNCNAME[0]}" $@"
cd $GITHUB_DIR
git init
#Initialized empty Git repository in /home/boscp08/Dropbox/Github/.git/
git config --global credential.helper store
git config --global user.email "bosch.peter@icloud.com"
git config --global user.name "boschpeter"
#git config --global user.password "P....\!...."  #mind macos keyring
git config --list
git config --get remote.origin.Uittreksel
}

##################################################################
# Purpose: Procedure to clone de github repo on your pc
# Arguments: 
# Return: 
##################################################################

git_clone() {
 echo "Running:"${FUNCNAME[0]}" $@"
 create_logfile_header "${FUNCNAME[0]}" $@
 echo "rm -rf ${PROJECT_DIR}/$1 sure?"
 enter_cont
 cd ${PROJECT_DIR}
 rm -rf ${GIT_REPO}
 #git clone https://github.com/discipl/waardepapieren.git
 #git clone https://github.com/AZ_VM_waardepapieren-demo_westeurope_cloudapp_azure_com.git
 #git clone https://github.com/BoschPeter/AZ_ACI_waardepapieren-demo_westeurope_azurecontainer_io.git
 git clone https://github.com/${GIT_REPO}.git  
 
 create_logfile_footer
}

##################################################################
# Purpose: DOCKER_BUILD-FUNCTIONS
##################################################################

##################################################################
# Purpose:  docker system prune -a
# Arguments: 
# Return:   remove all docker objects  starting from scratch... 
##################################################################
docker_system_prune() {
echo "Running:"${FUNCNAME[0]}" $@"
docker system prune -a   
}

##################################################################
# Purpose: remove alle containers 
# Arguments: 
# Return: 
##################################################################
docker_stop() {
echo "-Running:"${FUNCNAME[0]}" $@"
docker stop  $(docker ps -a -q)
}

##################################################################
# Purpose:  remove alle containers and images d
# Arguments: 
# Return:   
##################################################################
docker_remove_images() {
echo "Running:"${FUNCNAME[0]}" $@"
echo "docker rm $(docker ps -a -q) && docker rmi $(docker images -q)"   >> ${LOG_DIR}

docker rm $(docker ps -a -q) && docker rmi $(docker images -q)
create_logfile_footer "${FUNCNAME[0]}" $@

}

##################################################################
# Purpose:  remove all stopped containers (just waist of storage} 
# Arguments: 
# Return: 
##################################################################
docker_container_prune() {
echo "Running:"${FUNCNAME[0]}" $@"
create_logfile_header "${FUNCNAME[0]}" $@

echo "docker container prune -a "  >> ${LOG_DIR}
docker container prune -a   

create_logfile_footer "${FUNCNAME[0]}" $@

}

##################################################################
# Purpose:  Procedure to build the waardepapieren images and run containers.  
# Arguments: docker-compose -f docker-compose-travis.yml up   (docker-compose=thirdparty tool)
# Return: 3 containers  
##################################################################
docker_compose_images() {

cd ${GITHUB_DIR}
docker-compose -f docker-compose-travis.yml up --build


}
#################################################################
# Purpose:  Procedure to build the mock-nlx image
# Arguments: docker_build_image mock-nlx boscp08 waardepapieren_mock_nlx 1.0 
# Arguments: docker_build_image mock-nlx ${DOCKER_USER} ${${GIT_REPO}_${MOCK_NLX}} ${DOCKER_VERSION_TAG} 
# Return: image
##################################################################

docker_build_image() {
echo "Running:"${FUNCNAME[0]}" $@"
create_logfile_header "${FUNCNAME[0]}" $@
arg1=$1 #mock-nlx
arg1=$2 #${DOCKER_USER}
arg2=$3 #${${GIT_REPO}_${MOCK_NLX}}
arg3=$4 #${DOCKER_VERSION_TAG}
cd ${GITHUB_DIR}/$1
docker build -t $2/$3 .  #mind the dot!
cd ${GITHUB_DIR}  #cd -
}

##################################################################
# Purpose:  Procedure to build the waardepapieren images and run containers.  
# Arguments: docker build -t boscp08/waardepapieren_mock-nlx     NB . periode means from this directory 
# Return: 
##################################################################
docker_build_images() {
echo "Running:"${FUNCNAME[0]}" $@"
create_logfile_header "${FUNCNAME[0]}" $@
docker_build_image mock-nlx  ${DOCKER_USER} ${${GIT_REPO}_${MOCK_NLX}} ${DOCKER_VERSION_TAG}  
docker_build_image waardepapieren-service ${DOCKER_USER} ${${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}} ${DOCKER_VERSION_TAG}  
docker_build_image clerk-frontend ${DOCKER_USER} ${${GIT_REPO}_${CLERK_FRONTEND}} ${DOCKER_VERSION_TAG}  
create_logfile_footer "${FUNCNAME[0]}" $@
}


##################################################################
# Purpose:  Build an image from a Dockerfile
# Arguments: docker build -t boscp08/waardepapieren-service .   NB [.] periode means from this directory 
# Return: 
##################################################################
docker_build_waardepapierenservice()  {
echo "Running:"${FUNCNAME[0]}" $@"
create_logfile_header "${FUNCNAME[0]}" $@
cd ${GITHUB_DIR}/waardepapieren-service
docker build -t ${DOCKER_USER}/waardepapieren-service .  #NB [.] periode means from this directory 
}

##################################################################
# Purpose:  build custom image s  
# Arguments: specify own modifications in Dockerfile
# Return: 
##################################################################
docker_build_clerkfrontend() {
echo "Running:"${FUNCNAME[0]}" $@"
create_logfile_header "${FUNCNAME[0]}" $@
cd ${GITHUB_DIR}/clerk-frontend
docker build -t ${DOCKER_USER}/clerk-frontend .  #NB [.] directory containing Dockerfile and other files needed in image
create_logfile_footer "${FUNCNAME[0]}" $@
}


##################################################################
# Purpose:  start container from base image
# Arguments: docker run [image] [ps -f]
# Return: 
##################################################################
docker_run_image() {
echo "Running:"${FUNCNAME[0]}" $@"
#-p 8080:80
#-d detatched 
create_logfile_header "${FUNCNAME[0]}" $@
docker run -it $1 bash
create_logfile_footer "${FUNCNAME[0]}" $@
}
#################################################################
# Purpose:  Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
# Arguments: docker_tag boscp08  waardepapieren_mock-nlx 4.0 
# Return: image
##################################################################
docker_tag_image() {
echo "Running:"${FUNCNAME[0]}" $@"
create_logfile_header "${FUNCNAME[0]}" $@
#docker tag waardepapieren_clerk-frontend $DOCKER_USER/waardepapieren-clerk-frontend:$DOCKER_VERSION_TAG
#docker tag ${DOCKER_USER}/${GIT_REPO}_${MOCK_NLX}:latest ${DOCKER_USER}/${${GIT_REPO}_${MOCK_NLX}}:${DOCKER_VERSION_TAG}
arg1=$1 #${DOCKER_USER}
arg2=$2 #${${GIT_REPO}_${MOCK_NLX}}
arg3=$3 #${${GIT_REPO}_${MOCK_NLX}}
arg4=$4 #${DOCKER_VERSION_TAG}

#docker tag $2:latest $1/$3:$4

}  

##################################################################
# Purpose:  Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
# Arguments: docker tag -t boscp08/waardepapieren_clerk-frontend    
# Return: 
##################################################################
docker_tag_images() {
echo "Running:"${FUNCNAME[0]}" $@"
create_logfile_header "${FUNCNAME[0]}" $@
docker_tag_image  ${DOCKER_USER} ${${GIT_REPO}_${MOCK_NLX}} ${${GIT_REPO}_${MOCK_NLX}} ${DOCKER_VERSION_TAG}  
docker_tag_image  ${DOCKER_USER} ${${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}}  ${${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}} ${DOCKER_VERSION_TAG}  
docker_tag_image  ${DOCKER_USER} ${${GIT_REPO}_${CLERK_FRONTEND}} ${${GIT_REPO}_${CLERK_FRONTEND}} ${DOCKER_VERSION_TAG}  
docker images | grep  ${DOCKER_VERSION_TAG}   
docker images | grep  ${DOCKER_VERSION_TAG}      >> ${LOG_DIR}
create_logfile_footer "${FUNCNAME[0]}" $@
}

#################################################################
# Purpose:  Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
# Arguments: docker_tag boscp08  waardepapieren_mock-nlx 4.0 
# Return: image
##################################################################
docker_push_image() {
echo "Running:"${FUNCNAME[0]}" $@"
create_logfile_header "${FUNCNAME[0]}" $@
#docker tag waardepapieren_clerk-frontend $DOCKER_USER/waardepapieren-clerk-frontend:$DOCKER_VERSION_TAG
#docker tag ${DOCKER_USER}/${GIT_REPO}_${MOCK_NLX}:latest ${DOCKER_USER}/${${GIT_REPO}_${MOCK_NLX}}:${DOCKER_VERSION_TAG}
arg1=$1 #${DOCKER_USER}
arg3=$2 #${${GIT_REPO}_${MOCK_NLX}}
arg4=$3 #${DOCKER_VERSION_TAG}
docker push  $1/$2:$3
}  

##################################################################
# Purpose:  Push an image or a repository to a registry
# Arguments: docker push -t boscp08/waardepapieren_service   
# Return: Ship to docker registry docker.hub.com
##################################################################
docker_push_images() {
echo "Running:"${FUNCNAME[0]}" $@"
create_logfile_header "${FUNCNAME[0]}" $@
docker_push_image  ${DOCKER_USER} ${${GIT_REPO}_${MOCK_NLX}} ${DOCKER_VERSION_TAG}  
docker_push_image  ${DOCKER_USER} ${${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}} ${DOCKER_VERSION_TAG}  
docker_push_image  ${DOCKER_USER} ${${GIT_REPO}_${CLERK_FRONTEND}} ${DOCKER_VERSION_TAG} 
create_logfile_footer
}

##################################################################
# Purpose:  Push an image or a repository to a registry
# Arguments: docker push -t boscp08/waardepapieren_service   
# Return: Ship to docker registry docker.hub.com
##################################################################
docker_commit() {
echo "Running:"${FUNCNAME[0]}" $@"
#create_logfile_header "${FUNCNAME[0]}" $@
#docker commit ${${GIT_REPO}_${MOCK_NLX}} ${DOCKER_USER}/${${GIT_REPO}_${MOCK_NLX}}:${DOCKER_VERSION_TAG}  
##docker commit ${${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}} ${DOCKER_USER}/${${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}}:${DOCKER_VERSION_TAG} 
#docker commit ${${GIT_REPO}_${CLERK_FRONTEND}} ${DOCKER_USER}/${DOCKER_HUB_${GIT_REPO}_${CLERK_FRONTEND}}:${DOCKER_VERSION_TAG}          
create_logfile_footer
}

##################################################################
# Purpose:  Push an image or a repository to a registry
# Arguments: docker push -t boscp08/waardepapieren_service   
# Return: Ship to docker registry docker.hub.com
##################################################################
docker_commit_containers() {
echo "Running:"${FUNCNAME[0]}" $@"
create_logfile_header "${FUNCNAME[0]}" $@
docker commit ${${GIT_REPO}_${MOCK_NLX}} ${DOCKER_USER}/${${GIT_REPO}_${MOCK_NLX}}:${DOCKER_VERSION_TAG}  
docker commit ${${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}} ${DOCKER_USER}/${${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}}:${DOCKER_VERSION_TAG} 
docker commit ${${GIT_REPO}_${CLERK_FRONTEND}} ${DOCKER_USER}/${DOCKER_HUB_${GIT_REPO}_${CLERK_FRONTEND}}:${DOCKER_VERSION_TAG}          
create_logfile_footer
}

##################################################################
# DEPLOY-FUNCTIONS 2AZURE FROM DOCKER-HUB   
##################################################################

##################################################################
# Purpose: Procedure to create azure resource group aka costcenter/root
# Arguments: 
# Return: 
##################################################################
azure_create_resourcegroup() {
echo "-- Running:"${FUNCNAME[0]}" $@"
create_logfile_header "${FUNCNAME[0]}" $@
az login -u $AZURE_USER  -p $AZURE_PWD
#az group create --name $AZ_RESOURCE_GROUP --location westeurope
az group create --name $AZ_RESOURCE_GROUP --location westeurope
enter_cont
}

##################################################################
# Purpose: Procedure to delete azure resource group (a.k.a costcentre )
# Arguments: 
# Return: 
##################################################################
azure_delete_resourcegroup() {
echo "-- Running:"${FUNCNAME[0]}" $@ "
create_logfile_header "${FUNCNAME[0]}" $@
az login -u $AZURE_USER  -p $AZURE_PWD
#az group delete --name $AZ_RESOURCE_GROUP
az group delete --name $AZ_RESOURCE_GROUP
enter_cont
}

##################################################################
# Purpose: Procedure to create the azure containergroup
# Arguments: 
# Return: 
##################################################################
azure_create_containergroup() {
echo "-- Running:"${FUNCNAME[0]}" $@"
create_logfile_header "${FUNCNAME[0]}" $@
az login -u $AZURE_USER  -p $AZURE_PWD
enter_cont
cd ${GITHUB_DIR}


FILE=$GITHUB_DIR/deploy-aci.yaml
if test -f "$FILE"; then
    echo "$FILE exist"
 else set_azure_deploy_aci_yaml   
fi

#az container create --resource-group $AZ_RESOURCE_GROUP --file deploy-aci.yaml
az container create --resource-group $AZ_RESOURCE_GROUP --file $GITHUB_DIR/deploy-aci.yaml
enter_cont
cd $GITHUB_DIR
# https://docs.microsoft.com/en-us/azure/container-instances/container-instances-multi-container-yaml
# View deployment state
# az container show --resource-group ${AZ_RESOURCE_GROUP} --name myContainerGroup --output table
}


##################################################################
# Purpose: Procedure to clone build run ship and deploy 
# Arguments: 
# Return: the whole_sjebang
##################################################################
set_docker_tag() {

echo "DOCKER_VERSION_TAG="$DOCKER_VERSION_TAG
read -p "Enter Your new tag : " DOCKER_VERSION_TAG
echo "DOCKER_VERSION_TAG=$DOCKER_VERSION_TAG"
sleep 2
}


##################################################################
# Purpose: Procedure to clone build run ship and deploy 
# Arguments: 
# Return: the whole_sjebang
##################################################################
set_azure_resourcegroup() {

echo "AZ_RESOURCE_GROUP="$AZ_RESOURCE_GROUP
read -p "Enter Your azure resourcegroup : " AZ_RESOURCE_GROUP
echo "AZ_RESOURCE_GROUP=$AZ_RESOURCE_GROUP"
sleep 2
}

##################################################################
# Purpose: Procedure to clone build run ship and deploy 
# Arguments: 
# Return: the whole_sjebang
##################################################################
the_whole_sjebang() {

docker login -u $DOCKER_USER #
az login -u $AZURE_USER  # -p $AZURE_PWD  

enter_cont

docker_compose_images
docker_tag_images
docker_push_images

#docker_build_image mock-nlx  ${DOCKER_USER} ${${GIT_REPO}_${MOCK_NLX}} ${DOCKER_VERSION_TAG}  
#docker_build_image waardepapieren-service ${DOCKER_USER} ${${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}} ${DOCKER_VERSION_TAG}  
#docker_build_image clerk-frontend ${DOCKER_USER} ${${GIT_REPO}_${CLERK_FRONTEND}} ${DOCKER_VERSION_TAG}  
#docker_tag_image  ${DOCKER_USER} ${${GIT_REPO}_${MOCK_NLX}} ${${GIT_REPO}_${MOCK_NLX}} ${DOCKER_VERSION_TAG}  
#docker_tag_image  ${DOCKER_USER} ${${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}} ${${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}} ${DOCKER_VERSION_TAG}  
#docker_tag_image  ${DOCKER_USER} ${${GIT_REPO}_${CLERK_FRONTEND}} ${${GIT_REPO}_${CLERK_FRONTEND}} ${DOCKER_VERSION_TAG}  

#docker_push_image  ${DOCKER_USER} ${${GIT_REPO}_${MOCK_NLX}} ${DOCKER_VERSION_TAG}  
#docker_push_image  ${DOCKER_USER} ${${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}} ${DOCKER_VERSION_TAG}  
#docker_push_image  ${DOCKER_USER} ${${GIT_REPO}_${CLERK_FRONTEND}} ${DOCKER_VERSION_TAG}  

azure_delete_resourcegroup  $AZ_RESOURCE_GROUP
azure_create_resourcegroup  $AZ_RESOURCE_GROUP
azure_create_containergroup $AZ_RESOURCE_GROUP
create_logfile_footer

}


##################################################################
# Purpose: Firefox Start Browser From The Command Line
# Arguments: 
# Return: website  
###############################################################

bookmark_open() {

#URL=https://github.com/BoschPeter/$GIT_REPO

if [ `uname` = 'Linux' ]
  then  /usr/bin/firefox  $1
  #echo "linux"
fi  

if  [ `uname` = 'Darwin' ]
    then  open -a Firefox $1
   #echo "MacOs"
fi

if  [ `uname` = 'CYGWIN_NT-10.0' ]
    then  cygstart  $1  #this way you get the user's preferred web browser
   #echo "MacOs"
fi

}

##################################################################
# Purpose: azure_login
# Arguments: 
# Return: variables
##################################################################
azure_login() {

az login -u bosch.peter@outlook.com #-p 0l.n 

# //////////////////////////////////////////////////////////////////////////////////////////
#  az account list
#[
#  {
#    "cloudName": "AzureCloud",
#    "id": "cfcb03ea-255b-42f8-beca-2d4ac30779bb",
#    "isDefault": true,
#    "name": "Azure-abonnement 1",
#    "state": "Enabled",
#    "tenantId": "62123322-502d-493f-b543-503672043240",
#    "user": {
#      "name": "bosch.peter@outlook.com", 0l..ten
#      "type": "user"
#    }
#  }
#]


#If you’re in a hurry, here is a brief summary of somecommands used in this post:

## List currently authenticated subscriptions
#az account list

## Log in to a subscription
#az login

## Display subscriptions by Name and show which is selected
#az account list --query "[].{Name:name, IsDefault:isDefault}"

## Select a specific subscription by name
#az account set --subscription "Visual Studio Enterprise"

## Show usernames associated with specific subscriptions
#az account list --query "[].{Name:name, User:user.name}"

## Show usernames associated with a specific subscriptio matching Name
#az account list --query "[?contains(name, 'Visual')].{Name:name, User:user.name}"

## Log out of a specific subscription by username
#az logout --username "user@example.com"

## List virtual machines for select account
#az vm list


#https://docs.microsoft.com/en-us/azure/virtual-machines/azure-cli-arm-commands
#https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest

}

##################################################################
# Purpose: docker_login
# Arguments: 
# Return: variables
##################################################################
docker_login() {
docker login -u $DOCKER_USER
# docker container 
#  attach      Attach local standard input, output, and error streams to a running container
#  commit      Create a new image from a container's changes
#  cp          Copy files/folders between a container and the local filesystem
#  create      Create a new container
#  diff        Inspect changes to files or directories on a container's filesystem
#  exec        Run a command in a running container
#  export      Export a container's filesystem as a tar archive
#  inspect     Display detailed information on one or more containers
#  kill        Kill one or more running containers
#  logs        Fetch the logs of a container
#  ls          List containers
#  pause       Pause all processes within one or more containers
#  port        List port mappings or a specific mapping for the container
#  prune       Remove all stopped containers
#  rename      Rename a container
#  restart     Restart one or more containers
#  rm          Remove one or more containers
#  run         Run a command in a new container
#  start       Start one or more stopped containers
#  stats       Display a live stream of container(s) resource usage statistics
#  stop        Stop one or more running containers
#  top         Display the running processes of a container
#  unpause     Unpause all processes within one or more containers
#  update      Update configuration of one or more containers
#  wait        Block until one or more containers stop, then print their exit codes

#Usage:	docker image COMMAND
#Manage images

#Commands:
#  build       Build an image from a Dockerfile
#  history     Show the history of an image
#  import      Import the contents from a tarball to create a filesystem image
#  inspect     Display detailed information on one or more images
#  load        Load an image from a tar archive or STDIN
#  ls          List images
#  prune       Remove unused images
#  pull        Pull an image or a repository from a registry
#  push        Push an image or a repository to a registry
#  rm          Remove one or more images
#  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAG
#  save        Save one or more images to a tar archive (streamed to STDOUT by default)\
}

##################################################################
# Purpose: Procedure to save the program to the LOG_FILE
# Arguments: 
# Return: dokuwiki 
##################################################################
write_bash_code() {

echo "====== az_clone_build_ship_deploy.bash ======"                         >> "${LOG_FILE}"
echo "| ${LOG_START_DATE_TIME} | ${GITHUB_DIR}|"                             >> "${LOG_FILE}"
echo "| ${LOG_START_DATE_TIME} | az_clone_build_ship_deploy.bash |"          >> "${LOG_FILE}"
echo  "<code>"                                                               >> "${LOG_FILE}" 
cat  ${GITHUB_DIR}/bfg.bash                                                  >> "${LOG_FILE}"
echo "</code>"                                                               >> "${LOG_FILE}"
echo "====== menu.bash  ======"                                              >> "${LOG_FILE}"
echo "| ${LOG_START_DATE_TIME} | ${GITHUB_DIR}|"                             >> "${LOG_FILE}"
echo "| ${LOG_START_DATE_TIME} | menu.bash |"                                >> "${LOG_FILE}"
echo  "<code>"                                                               >> "${LOG_FILE}" 
cat  ${GITHUB_DIR}/menu.bash                                                 >> "${LOG_FILE}"
echo "</code>"                                                               >> "${LOG_FILE}"

}

##################################################################
# Purpose: Procedure to download raw contents
# Arguments: https://raw.githubusercontent.com/boschpeter/waardepapieren/master/az_clone_build_ship_deploy.bash  
# Return: fil
##################################################################
get_all_dockerfiles(){
#
cd $LOG_DIR
curl -o $LOG_START_DATE_TIME_menu.bash https://raw.githubusercontent.com/boschpeter/waardepapieren/master/az_clone_build_ship_deploy.bash
#cd $GITHUB_DIR
#curl -o docker-compose_travis_orig.yml  https://raw.githubusercontent.com/discipl/waardepapieren/master/docker-compose-travis.yml
}

##################################################################
# Purpose:  specify own modifications in Dockerfile
# Arguments: 
# Return: additional cookbook lines in Dockerfile 
##################################################################

specify_additional_modifications_in_dockerfiles() {

echo ".."

TIMEZONE="ENV TZ=Europe/Amsterdam"
APT_GET_UPDATE="RUN apt-get update"
APT_GET_INSTALL_NET_TOOLS="RUN apt-get install net-tools"
APT_GET_INSTALL_IPUTILS_PING="RUN apt-get install iputils-ping"

}

##################################################################
# Purpose: kickstarters localhost
# Arguments:  . bfg.bash mm 0 localhost
# Return: https://localhost
##################################################################
bfg_bash_mm_0_localhost() {
cd $GITHUB_DIR
. bfg.bash mm 1 localhost
}

##################################################################
# Purpose: kickstarters  AZURE VM
# Arguments:  . bfg.bash mm 1 waardepapieren-demo.westeurope.cloudapp.azure.com 
# Return: https://waardepapieren-demo.westeurope.cloudapp.azure.com
##################################################################
bfg_bash_mm_1_waardepapieren_demo_westeurope_cloudapp_azure_com(){
cd $GITHUB_DIR
. bfg.bash mm 1 waardepapieren-demo.westeurope.cloudapp.azure.com 
}

##################################################################
# Purpose: kickstarters AZURE VM
# Arguments:  . bfg.bash mm 2 $CERT_HOST_IP
# Return: https://$CERT_HOST_IP
##################################################################
bfg_bash_mm_2_discipl_demo_westeurope_cloudapp_azure_com(){
cd $GITHUB_DIR
. bfg.bash mm 2 discipl.westeurope.cloudapp.azure.com 
}

##################################################################
# Purpose: kickstarters azure ACI Azure Container Instance  
# Arguments:  . bfg.bash mm 3 waardepapieren-demo.w 
# Return: https://waardepapieren-demo.westeurepe.azurecontainer.io
##################################################################
bfg_bash_mm_3_waardepapieren_demo_westeurope_azurecontainer_io(){
cd $GITHUB_DIR
. bfg.bash mm 3 waardepapieren-demo.westeurope.azurecontainer.io
}
 
##################################################################
# Purpose: kickstarters azure ACI Azure Container Instance  
# Arguments:  . bfg.bash mm 4 discipl.westeurepe.azurecontainer.io 
# Return: https://discipl.westeurepe.azurecontainer.io
##################################################################
bfg_bash_mm_4_discipl_westeurope_azurecontainer_io(){
cd $GITHUB_DIR
. bfg.bash mm 4 discipl.westeurope.azurecontainer.io  
}


##################################################################
# Purpose: show bash parameters
# Arguments: 
# Return: 
##################################################################
show_parameters(){

echo "<code>"                                                                          >> "${LOG_FILE}"
echo "***"                                                                             >> "${LOG_FILE}"  
echo "***  Welcome to a `uname` docker build  $BATCH_START_DATE_TIME "                 >> "${LOG_FILE}"  
echo "***"                                                                             >> "${LOG_FILE}"  
echo "***  bfg.bash    "                                                               >> "${LOG_FILE}"  
echo "***  ${GITHUB_DIR}  "                                                            >> "${LOG_FILE}" 
echo "***  to build new waardepapieren images and containers "                         >> "${LOG_FILE}"  
echo "***  FQDN = https://${CERT_HOST_IP} "                                            >> "${LOG_FILE}"  
echo "***  docker-tag = ${DOCKER_VERSION_TAG}"                                         >> "${LOG_FILE}"  
echo "***  AZURE ACI-resourcegroup=${AZ_RESOURCE_GROUP}"                               >> "${LOG_FILE}"  
echo "***  LOGFILE=${LOG_FILE}"                                                        >> "${LOG_FILE}"  
echo "***"   
echo "#######################"                                                         >> "${LOG_FILE}"
echo "## variables"                                                                    >> "${LOG_FILE}"
echo "#######################"                                                         >> "${LOG_FILE}"
echo "LOG_DIR=${GITHUB_DIR}/LOG_DIR"                                                   >> "${LOG_FILE}"
echo "GIT_USER=${GIT_USER}"                                                            >> "${LOG_FILE}"
echo "GIT_REPO=$GIT_REPO"                                                              >> "${LOG_FILE}"
echo "GITHUB_DIR=$GITHUB_DIR"                                                          >> "${LOG_FILE}"
echo "DOCKER_USER=$DOCKER_USER"                                                        >> "${LOG_FILE}"
echo "COMPOSE_BUILD_FLAG=$COMPOSE_BUILD_FLAG"                                          >> "${LOG_FILE}"
echo "${GIT_REPO}_${MOCK_NLX}=${GIT_REPO}_${MOCK_NLX}"                                 >> "${LOG_FILE}"
echo "${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}=${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}"     >> "${LOG_FILE}"
echo "${GIT_REPO}_${CLERK_FRONTEND}=${GIT_REPO}_${CLERK_FRONTEND}"                     >> "${LOG_FILE}"
echo "${GIT_REPO}_${MOCK_NLX}=${GIT_REPO}_${MOCK_NLX}"                                 >> "${LOG_FILE}"
echo "${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}=${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}"     >> "${LOG_FILE}"
echo "${GIT_REPO}_${CLERK_FRONTEND}=${GIT_REPO}_${CLERK_FRONTEND}"                     >> "${LOG_FILE}"
echo "DOCKER_VERSION_TAG=$DOCKER_VERSION_TAG"                                          >> "${LOG_FILE}"
echo "AZ_RESOURCE_GROUP=$AZ_RESOURCE_GROUP"                                            >> "${LOG_FILE}"
echo "AZ_DNSNAMELABEL=$AZ_DNSNAMELABEL"                                                >> "${LOG_FILE}"
echo "TIMEZONE=$TIMEZONE"                                                              >> "${LOG_FILE}"
echo "CERT_HOST_IP=$CERT_HOST_IP"                                                      >> "${LOG_FILE}"
echo "EPHEMERAL_RETENTION_TIME_COMPOSE_TRAVIS=$EPHEMERAL_RETENTION_TIME_COMPOSE_TRAVIS" >> "${LOG_FILE}"
#echo "EPHEMERAL_RETENTION_TIME_COMPOSE=$EPHEMERAL_RETENTION_TIME_COMPOSE"               >> "${LOG_FILE}"
#echo "EPHEMERAL_RETENTION_TIME_CONFIG=$EPHEMERAL_RETENTION_TIME_CONFIG"                 >> "${LOG_FILE}"
echo "CERT_HOST_IP_WP_SERVICE_HOSTNAME=$CERT_HOST_IP_WP_SERVICE_HOSTNAME"              >> "${LOG_FILE}"
echo "#######################"                                                          >> "${LOG_FILE}"
echo "## variables"                                                                     >> "${LOG_FILE}"
echo "#######################"                                                          >> "${LOG_FILE}"
echo "</code>"                                                                         >> "${LOG_FILE}"
clear 
echo "***  Welcome to a `uname` docker build  $BATCH_START_DATE_TIME "                
echo "***"                                                                            
echo "***  bfg.bash   "                                                            
echo "***  ${GITHUB_DIR}  "                                                           
echo "***  to build new waardepapieren images and containers "                        
echo "***  FQDN = https://${CERT_HOST_IP} "                                           
echo "***  docker-tag = ${DOCKER_VERSION_TAG}"                                        
echo "***  AZURE ACI-resourcegroup=${AZ_RESOURCE_GROUP}"                              
echo "***  LOGFILE=${LOG_FILE}"                                                       
echo "***" 
echo "#######################"
echo "## variables"
echo "#######################"
echo "LOG_DIR=${GITHUB_DIR}/LOG_DIR"
echo "GIT_USER=${GIT_USER}"                                                             #=BoschPeter
echo "GIT_REPO=$GIT_REPO"                                                               #=AZ_ACI_waardepapieren-demo_westeurope_azurecontainer_io  #see befores
echo "GITHUB_DIR=$GITHUB_DIR"                                                           #=$PROJECT_DIR/${GIT_REPO}   #git clone https://github.com/ezahr/Waardepapieren-AZURE-ACI.git 
echo "DOCKER_USER=$DOCKER_USER"                                                         #="boscp08"  #NB repository name must be lowercase  
echo "COMPOSE_BUILD_FLAG=$COMPOSE_BUILD_FLAG"                                           #=" --build"
echo "${GIT_REPO}_${MOCK_NLX}=${GIT_REPO}_${MOCK_NLX}"                                  #=waardepapieren_mock-nlx
echo "${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}=${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}"      #=waardepapieren_waardepapieren-service
echo "${GIT_REPO}_${CLERK_FRONTEND}=${GIT_REPO}_${CLERK_FRONTEND}"                      #=waardepapieren_clerk-frontend
echo "${GIT_REPO}_${MOCK_NLX}=${GIT_REPO}_${MOCK_NLX}"                                  #=waardepapieren-mock-nlx
echo "${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}=${GIT_REPO}_${WAARDEPAPIEREN_SERVICE}"      #=waardepapieren-waardepapieren-service
echo "${GIT_REPO}_${CLERK_FRONTEND}=${GIT_REPO}_${CLERK_FRONTEND}"                      #=waardepapieren-clerk-frontend
echo "DOCKER_VERSION_TAG=$DOCKER_VERSION_TAG"                                           #="4.0"
echo "AZURE_USER=$AZURE_USER"                                                           #=bosch.peter@outlook.com  
echo "AZ_RESOURCE_GROUP=$AZ_RESOURCE_GROUP"                                             #="Discipl_Wigo4it_DockerGroup4"  #waardepapierenVM
echo "AZ_DNSNAMELABEL=$AZ_DNSNAMELABEL"                                                 #=discipl  
echo "TIMEZONE=$TIMEZONE"                                                               #=""
echo "EPHEMERAL_RETENTION_TIME_COMPOSE_TRAVIS=$EPHEMERAL_RETENTION_TIME_COMPOSE_TRAVIS" 
#echo "EPHEMERAL_RETENTION_TIME_COMPOSE=$EPHEMERAL_RETENTION_TIME_COMPOSE"               
#echo "EPHEMERAL_RETENTION_TIME_CONFIG=$EPHEMERAL_RETENTION_TIME_CONFIG"                
echo "CERT_HOST_IP=$CERT_HOST_IP"                                                       #=$AZ_DNSNAMELABEL.westeurope."$AZ_TLD"  #FQDN linux
echo "CERT_HOST_IP_WP_SERVICE_HOSTNAME=$CERT_HOST_IP_WP_SERVICE_HOSTNAME"               #=$AZ_DNSNAMELABEL.westeurope.$AZ_TLD
echo "DOUBLE_CHECK=$DOUBLE_CHECK"                                                       #=true  #cat content modified files to ${LOG_DIR}
echo "MENU=$MENU"                                                                       #=true
enter_cont
clear

}

##################################################################
# Purpose: shortcuts
# Arguments: 
# Return: 
##################################################################
tt() {

if [ "$1" = "" ] 
 then echo "geen input gespecificeerd" 
  echo "sad=set_all_Dockerfiles"
  echo "dci=docker_compose_images"
  echo "dti=docker_tag_images"
  echo "dpi=docker_push_images"
  echo "adr=azure_delete_resourcegroups"
  echo "acr=azure_create_resourcegroups"
  echo "acc=azure_create_containergroup"
  echo "arc=azure_restart_containergroup pull again"
  enter_cont
  
fi 

if [ "$1" = "sad" ] 
 then 
echo "set_all_Dockerfiles" 
fi

if [ "$1" = "sad" ] 
 then 
echo "sad=set_all_Dockerfiles"
enter_cont
set_all_Dockerfiles
 fi
  
  if [ "$1" = "dci" ] 
 then 
  echo "dci=docker_compose_images"
  enter_cont
  docker_compose_images
  fi
  
  if [ "$1" = "dti" ] 
 then  echo "dti=docker_tag_images"
 enter_cont
 docker_tag_images
   fi

    if [ "$1" = "dpi" ] 
    then  echo "dpi=docker_push_images"
    enter_cont
    docker_push_images
  fi
  
  if [ "$1" = "adr" ] 
    then echo "adr=azure_delete_resourcegroup"
    enter_cont
    azure_delete_resourcegroup
  fi

  if [ "$1" = "acr" ] 
   then echo "acr=azure_create_resourcegroup"
   enter_cont
   azure_create_resourcegroup
  fi
  
  if [ "$1" = "acc" ] 
   then echo "acc=azure_create_containergroup"
   enter_cont
   azure_create_containergroup
  fi

  if [ "$1" = "arc" ] 
   then  echo "arc=azure_restart_containergroup pull again"
   enter_cont
   azure_restart_containergroup
  fi

}


#######################
## M A I N
# program starts here actually
#######################
create_directories  
create_logdir
set_credentials
clear 

BATCH_START_DATE_TIME=`date +%Y%m%d_%H_%M`
LOG_START_DATE_TIME=`date +%Y%m%d_%H_%M`  
LOG_DIR=${GITHUB_DIR}/LOG_DIR
LOG_FILE=${LOG_DIR}/LOG_${LOG_START_DATE_TIME}.log

echo "***"                                                                                    
echo "***  Welcome to a `uname` docker build  $BATCH_START_DATE_TIME "                        
echo "***"                                                                                    
echo "***  bfg.bash $@   "                                                                    
echo "***  ${GITHUB_DIR}  "                                                                   
echo "***  to build new waardepapieren images and containers "                                
echo "***  FQDN = https://${CERT_HOST_IP} "                                                   
echo "***  docker-tag = ${DOCKER_VERSION_TAG}"                                                
echo "***  AZURE ACI-resourcegroup=${AZ_RESOURCE_GROUP}"                                      
echo "***  LOGFILE=${LOG_FILE}"                                                               
echo "***" 
enter_cont

#if [ ${PROMPT} = true ] 
# then 
##clear
#while true; do
#    read -p "Display all variables  (y or n)?" yn
#    case $yn in
#          [Yy]* ) show_parameters ; break;;
#          [Nn]* ) echo "N" ;  break;;
#        * ) echo "Please answer yes or no.";;
#    esac
#done
#fi

if [ ${MENU} = true ] 
 then 
clear
while true; do
    read -p "goto MAIN-MENU (y or n)" yn
    case $yn in
          [Yy]* ) show_main_menu ; break;;
          [Nn]* ) echo "N";  break;;
        * ) echo "Please answer yes or no.";;
    esac
done
fi


BATCH_END_DATE_TIME=`date +%Y%m%d_%H_%M`
echo 
echo "hope the run will be ok!"
echo      

echo "batch runtime : $BATCH_START_DATE_TIME  - $BATCH_END_DATE_TIME "  >> "${LOG_FILE}"
echo                                                                    >> "${LOG_FILE}"
echo "hope the run will be ok!"                                         >> "${LOG_FILE}"
echo                                                                    >> "${LOG_FILE}"


enter_cont
cd ${GITHUB_DIR}


# eof

