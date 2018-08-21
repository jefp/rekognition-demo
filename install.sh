while true
do 
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
if [ $? -eq 0 ]
then 
break
fi
done
 
\curl -sSL https://get.rvm.io | bash -s stable

source ~/.rvm/scripts/rvm

sudo yum install -y nodejs npm --enablerepo=epel
sudo yum install -y openssl nginx

rvm install 2.4.1 
rvm gemset create aws-demo
rvm gemset use aws-demo
gem install bundler

cd ..
cd -
bundle

openssl req -subj '/CN=demo.com/O=Amazon Rekognition/C=CL' -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -keyout server.key -out server.crt
sudo mkdir -p /etc/nginx/ssl/certs/
sudo mv server.key server.crt /etc/nginx/ssl/certs/

sudo mv ssl.conf /etc/nginx/conf.d
sudo service nginx restart
