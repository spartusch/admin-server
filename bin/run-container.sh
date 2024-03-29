#!/bin/bash

declare $(env -i `cat bin/configuration.vars`)
declare $(env -i `cat bin/secrets.vars`)

echo
echo "=> Starting to build and run '$project_group/$project_name' ..."
echo

container_id=$(docker ps -a --filter name=$project_name --format '{{.ID}}');
if [ -z $container_id ];
  then
    echo "=> Container '$project_name' is not running";
    echo
	else
	  echo "=> Stopping and removing existing container '$project_name' ...";
	  docker stop $container_id > /dev/null && docker container rm $container_id > /dev/null;
	  echo
fi

echo "=> Building image '$project_group/$project_name' (might take a while) ..."
docker image build -t $project_group'/'$project_name':latest' .
echo

if [[ ! $(docker network ls | grep $project_group) ]];
  then
    echo "=> Creating network '$project_group' ..."
    docker network create $project_group > /dev/null
    echo
  else
    echo "=> Network '$project_group' found"
    echo
fi

echo "=> Starting new container '$project_name' to be available at port $port ..."
docker run -p$port:8080 \
  -e ADMIN_USER=$admin_user \
  -e ADMIN_PASSWORD=$admin_password \
  -d --network $project_group --name $project_name --restart unless-stopped \
  $project_group'/'$project_name':latest' > /dev/null

echo "=> Done"
echo
