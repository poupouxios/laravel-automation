#!/bin/bash
project_name="laravel-project";
database_dump_filename="laravel_automation_dump.sql"
database_username="laraveluser"
database_password="test1234!"
database_root_password="rootT3st4321!"
database_name="laraveldb"
docker_hub_naming="poupou/$project_name";
public_directory="public";
database_directory="db";

#Prepare the docker to push it to your docker hub
build_docker_image (){
  cd public
  tar -czvf ../docker/final/final.tar.gz -X "../docker/final/exclude-files.txt" ./

  cd ../docker

  DOCKER_IMG=$docker_hub_naming
  GIT_SHA=`git rev-parse HEAD`
  GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
  GIT_TAG=`git describe --abbrev=0 --tags`

  echo "sha=${GIT_SHA}, branch=${GIT_BRANCH}, tag=${GIT_TAG}"

  docker build --no-cache -t ${DOCKER_IMG}:latest final
  if [ -n "$GIT_TAG" ]; then
   docker tag "$DOCKER_IMG" "${DOCKER_IMG}:${GIT_TAG}"
  fi
  date
}

#setup the Laravel project by downloading the structure of it and then
#build the docker that will serve the project
setup_laravel_project (){

  if [ ! -d "$database_directory" ]; then
     echo "Creating $database_directory folder..";
     mkdir -p $database_directory/data
  fi

  if [ ! -d "$public_directory" ]; then
     echo "Creating $public_directory folder..";
     mkdir $public_directory
  fi

  #creating docker-compose file
  create_docker_compose_file;

  cd docker/initial-setup

  #creating a .env to give a uniqueness for each project and not interfere with other docker containers
  echo "COMPOSE_PROJECT_NAME=$project_name-setup" > .env;

  #building the project

  #making sure that the container is not running
  docker-compose -f docker-compose.yml down;

  #building the container to retrieve the image if not installed
  docker-compose -f docker-compose.yml build;

  #start docker in order to be able to run the setup script
  docker-compose -f docker-compose.yml up -d;

  #now that the docker started, run the setup.sh script
  docker exec -t setup-project.dev /setup.sh;

  #here we hope that everything went ok and we shutdown the container
  docker-compose -f docker-compose.yml stop;

  #start docker in order to be able to run the setup script
  docker-compose -f docker-compose.yml up -d;

  #we re-run docker to setup now the Laravel project
  docker exec -t setup-project.dev sh -c '/setup.sh install';

  #here we hope that everything went ok and we shutdown the container
  docker-compose -f docker-compose.yml down;

  cd ../
  docker-compose -f docker-compose.yml build;
}

create_docker_compose_file (){
 dockercomposesample=$(<./docker/docker-compose.sample.yml);
 variables=$(( set -o posix ; set ) | sort);
 dockercompose=${dockercomposesample//##project_name##/$project_name};
 dockercompose=${dockercompose//##database_dump_filename##/$database_dump_filename};
 dockercompose=${dockercompose//##database_username##/$database_username};
 dockercompose=${dockercompose//##database_password##/$database_password};
 dockercompose=${dockercompose//##database_root_password##/$database_root_password};
 dockercompose=${dockercompose//##database_name##/$database_name};
 echo "$dockercompose" >> ./docker/docker-compose.yml;
 echo "File docker-compose.yml created.";
}

start_app (){
  echo "Loading dockers..";
  echo "COMPOSE_PROJECT_NAME=$project_name" > ./docker/.env;
  docker-compose -f docker/docker-compose.yml up;
}

import_database_data (){
  echo "Importing data..";
  docker exec $project_name.db bash /tmp/database-import.sh;
}

select_menu (){
  echo "------------------------";
  echo "1. Build project";
  echo "2. Start app";
  echo "3. Import database data";
  echo "4. Build production docker image";
  echo "5. Push  image to docker hub";
  echo "6. Exit";
  read -p "Select option to begin: " option;
}

while [ "$option" != "6" ]
do
  select_menu;
  case $option in
    1) setup_laravel_project;;
    2) start_app;;
    3) import_database_data;;
    4) build_docker_image;;
    5) docker push "$docker_hub_naming"; date;;
    6) exit;;
    *) echo "Please select a valid option from above";;
  esac
done
