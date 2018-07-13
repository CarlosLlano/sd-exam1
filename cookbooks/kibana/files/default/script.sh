sudo yum install java -y

sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

echo '[kibana-5.x]
name=Kibana repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md' > /etc/yum.repos.d/kibana.repo

sudo yum install kibana -y
