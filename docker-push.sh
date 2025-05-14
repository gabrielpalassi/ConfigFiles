#!/bin/bash

read -p "Enter the Docker image name (e.g., gabrielpalassi/currencyconverter-backend): " IMAGE_NAME

docker login
docker build -t "$IMAGE_NAME" .
docker push "$IMAGE_NAME"

