#!/bin/bash

# Obtém o versionCode atual do arquivo build.gradle
VERSION_CODE=$(awk '/versionCode/{print $2}' android/app/build.gradle | tr -d '[:space:]')

# Aumenta o versionCode em 1
NEW_VERSION_CODE=$((VERSION_CODE + 1))

# Atualiza o versionCode no arquivo build.gradle
sed -i "s/versionCode $VERSION_CODE/versionCode $NEW_VERSION_CODE/" android/app/build.gradle