#!/bin/bash

echo "Deploying the sinatra app"

yum install git ruby22  -y 
gem install bundler

git clone https://github.com/rea-cruitment/simple-sinatra-app.git  /home/ec2-user/simple-sinatra-app


cd  /home/ec2-user/simple-sinatra-app
/usr/local/bin/bundle install
/usr/local/bin/bundle/bundle exec rackup -p8080 2&>1 > app.log &
