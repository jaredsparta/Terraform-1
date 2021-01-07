#!/bin/bash
echo "export DB_HOST=${db-ip}" >> /home/ubuntu/.bashrc
export DB_HOST=${db-ip}
cd /home/ubuntu/app
pm2 kill
rm -r node_modules
npm install
pm2 start app.js --update-env
pm2 restart app.js --update-env
