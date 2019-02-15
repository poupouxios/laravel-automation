#!/bin/bash
project_name="project-setup";
public_dir="/var/www";
parameter=$1;

if [[ "$parameter" != "install" ]]; then
	echo "Getting Laravel installer from Composer..";
	composer global require "laravel/installer"

	laravelexec="/root/.composer/vendor/bin/laravel";

        if [ -z "$laravelexec" ]; then
    	    echo "Laravel cannot be found. Maybe the composer failed or maybe cannot locate Laravel?";
	    exit;
        fi
fi

if [[ "$parameter" == "install" ]]; then
    cd $public_dir
    echo "Waiting 2 seconds to warm up the docker engine..";
    sleep 2

    laravelexec="/root/.composer/vendor/bin/laravel";

    if [ -z "$laravelexec" ]; then
        echo "Laravel cannot be found. Maybe the composer failed or maybe cannot locate Laravel?";
        exit;
    fi

    $laravelexec new $project_name

    mv $project_name/{.,}* $public_dir/
    rm -rf $project_name
    mv $public_dir/.env.example $public_dir/.env
fi
