#!/bin/bash
project_name="project-setup";
public_dir="/var/www";

echo "Getting Laravel installer from Composer..";
composer global require "laravel/installer"

laravelexec="/root/.composer/vendor/bin/laravel";

if [ -z "$laravelexec" ]; then
    echo "Laravel cannot be found. Maybe the composer failed or maybe cannot locate Laravel?";
    exit;
else
    cd /var/www
    echo "Waiting 2 seconds to warm up the docker engine..";
    sleep 2

    $laravelexec new $project_name

    mv $project_name/{.,}* $public_dir/
    rm -rf $project_name
    mv $public_dir/.env.example $public_dir/.env
fi