#!/bin/bash


# Init
# cd ~


# Connection setup

#until [[ $PROJECT_NAME != "" ]]; do
#  read -rp "Project name: " -e PROJECT_NAME
#done

until [[ $REMOTE_PROTOCOL =~ (ftps|ftp) ]]; do
  read -rp "Protocol (ftps|ftp): " -e REMOTE_PROTOCOL
done

until [[ $REMOTE_HOST != "" ]]; do
  read -rp "Host: " -e REMOTE_HOST
done

until [[ $REMOTE_USERNAME != "" ]]; do
  read -rp "Username: " -e REMOTE_USERNAME
done

until [[ $REMOTE_PASSWORD != "" ]]; do
  read -rp "Password: " -e REMOTE_PASSWORD
done

until [[ $DOWNLOAD_OPENCART_DIRECTORY_ADMIN =~ (y|n) ]]; do
  read -rp "Download admin directory? " -e DOWNLOAD_OPENCART_DIRECTORY_ADMIN
done

until [[ $DOWNLOAD_OPENCART_DIRECTORY_CATALOG =~ (y|n) ]]; do
  read -rp "Download catalog directory? " -e DOWNLOAD_OPENCART_DIRECTORY_CATALOG
done

until [[ $DOWNLOAD_OPENCART_SYSTEM_CATALOG =~ (y|n) ]]; do
  read -rp "Download system directory? " -e DOWNLOAD_OPENCART_SYSTEM_CATALOG
done

curl $REMOTE_PROTOCOL://$REMOTE_USERNAME:$REMOTE_PASSWORD@$REMOTE_HOST

until [[ $REMOTE_DIRECTORY != "" ]]; do
  read -rp "Directory: " -e REMOTE_DIRECTORY
done


# Prepare directory tree
# mv $REMOTE_HOST/$REMOTE_DIRECTORY $PROJECT_NAME
# cd $PROJECT_NAME

mkdir $REMOTE_HOST
mkdir $REMOTE_HOST/$REMOTE_DIRECTORY

# Process downloading options
if [[ $DOWNLOAD_OPENCART_DIRECTORY_ADMIN == "y" ]]; then
  echo "Downloading admin directory..."
  wget --no-check-certificate -l 0 -r $REMOTE_PROTOCOL://$REMOTE_USERNAME:$REMOTE_PASSWORD@$REMOTE_HOST/$REMOTE_DIRECTORY/admin/
fi

if [[ $DOWNLOAD_OPENCART_DIRECTORY_CATALOG == "y" ]]; then
  echo "Downloading catalog directory..."
  wget --no-check-certificate -l 0 -r $REMOTE_PROTOCOL://$REMOTE_USERNAME:$REMOTE_PASSWORD@$REMOTE_HOST/$REMOTE_DIRECTORY/catalog/
fi

if [[ $DOWNLOAD_OPENCART_SYSTEM_CATALOG == "y" ]]; then
  echo "Downloading system directory..."
  wget --no-check-certificate -l 0 -X $REMOTE_DIRECTORY/system/storage/ -r $REMOTE_PROTOCOL://$REMOTE_USERNAME:$REMOTE_PASSWORD@$REMOTE_HOST/$REMOTE_DIRECTORY/system/
fi


# Deploy the project
cd $REMOTE_HOST/$REMOTE_DIRECTORY


# VS Codium initialization
echo "VS Codium setup..."
mkdir .vscode

touch .vscode/sftp.json

echo "{"                                                 >> .vscode/sftp.json
echo "    \"name\": \"$REMOTE_HOST/$REMOTE_DIRECTORY\"," >> .vscode/sftp.json #echo "    \"name\": \"$PROJECT_NAME\"," >> .vscode/sftp.json
echo "    \"host\": \"$REMOTE_HOST\","                   >> .vscode/sftp.json
echo "    \"protocol\": \"ftp\","                        >> .vscode/sftp.json #ftp only
echo "    \"port\": 21,"                                 >> .vscode/sftp.json
echo "    \"username\": \"$REMOTE_USERNAME\","           >> .vscode/sftp.json
echo "    \"password\": \"$REMOTE_PASSWORD\","           >> .vscode/sftp.json
echo "    \"remotePath\": \"$REMOTE_DIRECTORY\","        >> .vscode/sftp.json
echo "    \"uploadOnSave\": true,"                       >> .vscode/sftp.json
echo "    \"useTempFile\": false,"                       >> .vscode/sftp.json
echo "    \"openSsh\": false,"                           >> .vscode/sftp.json
echo "    \"ignore\": ["                                 >> .vscode/sftp.json
echo "        \".git\","                                 >> .vscode/sftp.json
echo "        \".gitignore\","                           >> .vscode/sftp.json
echo "        \".vscode\","                              >> .vscode/sftp.json
echo "        \".idea\","                                >> .vscode/sftp.json
echo "        \".ftpconfig\","                           >> .vscode/sftp.json
echo "        \".ftpignore\","                           >> .vscode/sftp.json
echo "        \"README.md\""                             >> .vscode/sftp.json
echo "    ]"                                             >> .vscode/sftp.json
echo "}"                                                 >> .vscode/sftp.json


# GIT initialization
echo "GIT initialization..."
git init
git add .
git commit -m "initial commit"


# Generate .gitignore
touch .gitignore

echo "image"            >> .gitignore
echo "system/storage"   >> .gitignore
echo ".ftpignore"       >> .gitignore
echo ".ftpconfig"       >> .gitignore
echo ".gitignore"       >> .gitignore
echo ".vscode"          >> .gitignore
echo ".idea"            >> .gitignore


# Deployment completed
echo "Project successfully deployed!"
