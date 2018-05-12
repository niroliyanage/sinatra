#!/bin/bash
echo "Deploying the sinatra app"

yum install git ruby23-2.3.7-1.19.amzn1.x86_64  -y 
gem install bundler

git clone https://github.com/rea-cruitment/simple-sinatra-app.git  /home/ec2-user/simple-sinatra-app

chown -R ec2-user:ec2-user /home/ec2-user/simple-sinatra-app

cat << EOF | tee /home/ec2-user/start.sh
#!/bin/bash

cd  /home/ec2-user/simple-sinatra-app
rvm use 2.3.1
~/.rvm/rubies/ruby-2.3.1/bin/bundle install --gemfile=/home/ec2-user/simple-sinatra-app/Gemfile
rvmsudo ~/.rvm/rubies/ruby-2.3.1/bin/bundle exec rackup -o 0.0.0.0 -p 80 &

EOF

chown -R ec2-user:ec2-user /home/ec2-user/start.sh
chmod a+x /home/ec2-user/start.sh

su - ec2-user  sh -c "/home/ec2-user/start.sh"


sleep 30







