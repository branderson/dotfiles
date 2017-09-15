gem install --user-install bro
gem install --user-install tmuxinator

npm install -g how2
sed "s/var EventEmitter = process.EventEmitter;/var EventEmitter = require\('events'\);/g" ~/.npm-prefix/lib/node_modules/how2/node_modules/devnull/transports/transport.js > ~/.npm-prefix/lib/node_modules/how2/node_modules/devnull/transports/transport.js

pip install --user haxor-news

tar -xf .local.tar
