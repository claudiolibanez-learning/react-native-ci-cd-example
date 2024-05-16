#!/bin/bash

# Obtém o versionCode atual do arquivo gradle.properties
VERSION_CODE=$(awk -F'=' '/^versionCode/{print $2}' android/app/gradle.properties)

# Aumenta o versionCode em 1
NEW_VERSION_CODE=$((VERSION_CODE + 1))

# Atualiza o versionCode no arquivo gradle.properties
sed -i "s/versionCode=$VERSION_CODE/versionCode=$NEW_VERSION_CODE/" android/app/gradle.properties