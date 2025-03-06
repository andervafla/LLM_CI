#!/bin/bash

set -e 

curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2:1b

sudo apt update && sudo apt install npm python3-pip python3-venv git -y

git clone https://github.com/open-webui/open-webui.git
cd open-webui

cp .env.example .env

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install 22
nvm use 22
npm install -g npm@latest

npm install
npm run build

cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt -U