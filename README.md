# Laravel Automation

Laravel Automation is an automatic way to setup a simple Laravel project to play around. It initializes all the necessary files and folders to run along with [Docker](https://www.docker.com/). It gives you also the ability to push your final docker image in [Docker Hub](https://hub.docker.com/) and then deploy it from any Container Management Platform.

## Motivation

In my free time, I like to play with new technologies. However, to make my coding faster I always want to automate the basic process to setup the core structure. This time I wanted to setup a [Laravel](https://laravel.com/) project inside a Docker container without having the hassle of setting up all the core things to run a Laravel project.  

So I created a small bash script called `start.sh`. The script offers the options to setup a Laravel project from scratch, import database data, build docker image and push this to docker hub.

The end goal of this project is to containerize my applications and deploy them through my Container Management Platform.

## Dependencies

The project needs to have some essential components to start. Keep in mind this project was tested on Ubuntu 17.04. The dependencies are:

* [Docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04) (I always find useful the Digital Ocean installation tutorials)
* [Docker Composer](https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-16-04)
* [Composer](https://getcomposer.org/download/)

## Structure of the folders

The scripts will create the below structured folders:
  * `public` folder:  This will have the core structure of Laravel Project. If you have an existing Laravel project, you can replace all the files inside the public folder and it should work.
  * `db` folder: This will be an empty folder at the beginning. After you start the database docker container, it will map all the data that will add in database in a folder called data inside the db. This way you can copy the data folder and paste it in another database docker container and you map your /var/lib/mysql folder from inside the database docker container with the db/data folder outside. You can see this mapping inside the `docker-compose.yml` file at line 15.

### 1. Configuration variables

In order to create your own project, there are some configuration variables that can be set. These variables exist inside the `start.sh` file and are:
  * `project_name`: This will be used to setup various configurations inside the final docker-compose YAML file along with the creation of project from the laravel command.
  * `database_dump_filename`: Specify the name of your database dump. Place it inside the db folder and this will be mapped inside the database docker container to import the data. The option 3 will do the import data.
  * `database_username`: The database username that the application uses to access database. It will be used to create the database and grant access to this user inside the database docker container.
  * `database_password`: The database password that the application uses to access database.It will be used to create the database and grant access to this user inside the database docker container.
  * `database_root_password`: The root password to setup the database inside the container.
  * `database_name`: The database name that the applications uses to access database. It will be used to create the database inside the database docker container.
  * `docker_hub_naming`: This is the name of the docker image that will be created in docker hub and local on your computer.
  * `public_directory`: This is the public directory where the core project will live. This is mapped inside the docker container, so any changes you make inside the public folder they will be applied inside the docker container.
  * `database_directory`: This is the directory that will be mapped with the /var/lib/mysql directory inside the database docker container

## 2. Setup your own project

  1. First, make sure that you set your correct variables inside the `start.sh` file.
  2. Run `sh start.sh`
  3. This will bring a menu which will look like this:
     `1. Build project
      2. Start app
      3. Import database data
      4. Build production docker image
      5. Push  image to docker hub
      Select option to begin:`
  4. **(Check point 1 in Extra useful information below for existing project)** Select option 1 to build the project. This will start setting up the folder structure, install laravel script, create the project
  5. After option 1 finishes, move to option 2. This will start the application.
  6. When the docker will start, somewhere at the end you should see a message like this:
    `Access your application through this ip: http://<ip-address>` eg. `Access your application through this ip: http://172.19.0.3`
  7. Click on the link and you should see the Laravel project alive.

## Extra useful information

  1. Assumed that you have already setup locally a Laravel project and you want to switch to this automatic way. Just get a MySql dump of your project, put it inside the `db` folder, set the correct variables inside `start.sh` and run option 1. After that, copy paste your code in the correct folders (inside `public` folder) and then select option 2 to start your application.
  2. If you want to execute an artisan command, **always** run it inside the docker container. To access your docker container execute the command `docker exec -i -t <project name variable value>.dev /bin/bash` eg. if your project_name is laravel-test the command will be `docker exec -i -t laravel-test.dev /bin/bash`

## License

This project is licensed under the MIT open source license.
