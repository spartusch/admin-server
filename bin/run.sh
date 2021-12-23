#!/bin/sh

declare $(env -i `cat bin/secrets.vars`)

./gradlew -PgenerateLaunchScript bootJar
./build/libs/*.jar --ADMIN_USER=$admin_user --ADMIN_PASSWORD=$admin_password
