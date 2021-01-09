#!/bin/bash
echo "export DB_HOST=${db-ip}" >> /home/ubuntu/.bashrc
export DB_HOST=${db-ip}
cd /home/ubuntu/app
pm2 kill
rm -r node_modules
npm install
npm run seed
pm2 start app.js --update-env
