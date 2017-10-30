#!/bin/bash
mysql -u root -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE < /tmp/laravel_automation_dump.sql
