#!/bin/sh

./gradlew -PgenerateLaunchScript bootJar
./build/libs/*.jar
