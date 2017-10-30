#!/bin/bash

database_docker_image="laravel-automation.db";
docker_hub_naming="poupou/laravel-automation";
public_directory="public";
database_directory="db";
app_container_name="laravel.dev"
project_name="laravel-project";

#Prepare the docker to push it to your docker hub
build_docker_image (){
  cd public
  tar -czvf ../docker/final/final.tar.gz -X "../docker/final/exclude-files.txt" ./

  cd docker

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

  echo "Getting laravel installer from Composer..";
  composer global require "laravel/installer"

  echo "Creating project $project_name";
  if [ -d "$project_name" ]; then
     echo "Removing $project_name folder..";
     rm -rf $project_name
  fi

  laravelexec="$(locate vendor/bin/laravel)";

  if [ -z "$laravelexec" ]; then
    echo "laravel cannot be found. Maybe the composer failed?";
    exit;
  else
		$laravelexec new $project_name

		mv $project_name/{.,}* $public_directory/
		rm -rf $project_name
    mv $public_directory/.env.example $public_directory/.env

		cd docker

		docker-compose -f docker-compose.yml build;
  fi
}

start_app (){
  echo "Loading dockers..";
  docker-compose -f docker/docker-compose.yml up;
}

import_database_data (){
  echo "Importing data..";
  docker exec $database_docker_image bash /tmp/database-import.sh;
}

echo "1. Build project"
echo "2. Start app"
echo "3. Import database data"
echo "4. Build production docker image"
echo "5. Push  image to docker hub"
read -p "Select option to begin: " option

case $option in
  [1]* ) setup_laravel_project; break;;
  [2]* ) start_app; break;;
  [3]* ) import_database_data; break;;
  [4]* ) build_docker_image; break;;
  [5]* ) docker push "$docker_hub_naming"; date; break;;
     * ) echo "Please select a valid option from above";;
esac
