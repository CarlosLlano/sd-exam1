# PARCIAL 1 SISTEMAS DISTRIBUIDOS #

***1.Consigne los comandos de Linux necesarios para el aprovisionamiento de los servicios solicitados. 
En este punto no debe incluir recetas solo se requiere que usted identifique los comandos o acciones que debe automatizar***

Se utilizaron 4 nodos, cada uno con las siguientes direcciones ip:

| Nodo          | Ip             |
| ------------- |:--------------:|
| elasticsearch_server | 192.168.56.101 |
| kibana_server     | 192.168.56.102 |
| logstash_server   | 192.168.56.103 |
| web_server   | 192.168.56.104 |

Los comandos necesarios para que cada uno haga su funcion:

***SERVIDOR ELASTICSEARCH***

__instalar llave publica__ 
```bash
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
```
__crear archivo para instalacion__
```bash
vi /etc/yum.repos.d/elasticsearch.repo
```
__contenido del archivo__
```bash
[elasticsearch-5.x] 
name=Elasticsearch repository for 5.x packages 
baseurl=https://artifacts.elastic.co/packages/5.x/yum 
gpgcheck=1 
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch 
enabled=1 
autorefresh=1 
type=rpm-md
```
__instalacion__
```bash
sudo yum install elasticsearch
```
__configuracion__

En el archivo /etc/elasticsearch/elasticsearch.yml.
```bash
network.host: 192.168.56.101
http.port: 9200
```


***SERVIDOR KIBANA***

__instalar llave publica__ 
```bash
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
```
__crear archivo para instalacion__
```bash
vi /etc/yum.repos.d/kibana.repo
```
__contenido del archivo__
```bash
[kibana-5.x] 
name=Kibana repository for 5.x packages 
baseurl=https://artifacts.elastic.co/packages/5.x/yum 
gpgcheck=1 
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch 
enabled=1 
autorefresh=1 
type=rpm-md
```
__instalacion__
```bash
sudo yum install kibana
```
__configuracion__

En el archivo /etc/kibana/kibana.yml.

```bash
server.port: 5601
server.host: "192.168.56.102"
elasticsearch.url: "http://192.168.56.101:9200"
```

***SERVIDOR LOGSTASH***

__instalar llave publica__ 
```bash
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
```
__crear archivo para instalacion__
```bash
vi /etc/yum.repos.d/logstash.repo
```
__contenido del archivo__
```bash
[logstash-5.x] 
name=Elastic repository for 5.x packages 
baseurl=https://artifacts.elastic.co/packages/5.x/yum 
gpgcheck=1 
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch 
enabled=1 
autorefresh=1 
type=rpm-md
```
__instalacion__
```bash
sudo yum install logstash
```
__configuracion__

crear el archivo /etc/logstash/conf.d/apache-logstash.conf con el contenido siguiente:

```bash
input {
    beats {
        port => "5044"
    }
}
filter {
    grok {
        match => { "message" => "%{COMBINEDAPACHELOG}"}
    }
}
output {
    elasticsearch
    {
        hosts => ["192.168.56.101:9200"]
    }
}
```

***SERVIDOR WEB CON FILEBEAT***

__instalar llave publica__ 
```bash
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
```
crear archivo para instalacion
```bash
vi /etc/yum.repos.d/elastic.repo
```
__contenido del archivo__
```bash
[elastic-5.x]
name=Elastic repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum 
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1 
autorefresh=1 
type=rpm-md
```
__instalacion__
```bash
sudo yum install filebeat
```
__configuracion__

Se utiliza httpd como origen de logs. Para instalarlo se debe utilizar el siguiente comando:
```bash
yum install httpd -y
```

Con respecto a filebeat, se debe modificar el archivo /etc/filebeat/filebeat.yml para que utilice los logs de httpd:
```bash
input_type: log
paths:
    - /var/log/httpd/access_log
```

Tambien se debe especificar el destino de esos logs (servidor elasticsearch).
```bash
output.logstash:
  hosts: ["192.168.56.101:5044"]
```


***2.Escriba el archivo Vagrantfile para realizar el aprovisionamiento, teniendo en cuenta definir: maquinas a aprovisionar, 
interfaces solo anfitrión, interfaces tipo puente, declaración de cookbooks, variables necesarias para plantillas***

```ruby
Vagrant.configure("2") do |config|
  config.ssh.insert_key = false

  #servidor encargado de almacenar logs por medio de la aplicación Elasticsearch
  config.vm.define :elasticsearch_server do |elasticsearch_server|
    #definicion de la imagen del SO a utilizar (en este caso Centos7)
    elasticsearch_server.vm.box = "centos1706_v0.2.0"
    #Configuracion de una red privada e ip asociada a la maquina
    elasticsearch_server.vm.network :private_network, ip: "192.168.56.101"
    #Configuracion de la cantidad de memoria RAM, numero de cpus y nombre de la maquina virtual
    elasticsearch_server.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "elasticsearch_server" ]
    end

    #Definicion del aprovisionador a utilizar (chef solo)
    config.vm.provision :chef_solo do |chef|
      #No se instala el aprovisionador porque ya esta contenido en la imagen del sistema operativo
      chef.install = false
      #Definicion del directorio que contiene las recetas de aprovisionamiento
      chef.cookbooks_path = "cookbooks"
      #Se añade la receta de elasticsearch
      chef.add_recipe "elasticsearch"
      #Se agrega una variable que representa la ip del servidor elasticsearch
      chef.json = {"direccion_ip" => "192.168.56.101"}
    end
  end

  #servidor con la herramienta encargada de visualizar la información de los logs por medio de la aplicación Kibana
  config.vm.define :kibana_server do |kibana_server|
    #definicion de la imagen del SO a utilizar (en este caso Centos7)
    kibana_server.vm.box = "centos1706_v0.2.0"
    #Configuracion de una red privada e ip asociada a la maquina
    kibana_server.vm.network :private_network, ip: "192.168.56.102"
    #Configuracion de la cantidad de memoria RAM, numero de cpus y nombre de la maquina virtual
    kibana_server.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "kibana_server" ]
    end

    #Definicion del aprovisionador a utilizar (chef solo)
    config.vm.provision :chef_solo do |chef|
      #No se instala el aprovisionador porque ya esta contenido en la imagen del sistema operativo
      chef.install = false
      #Definicion del directorio que contiene las recetas de aprovisionamiento
      chef.cookbooks_path = "cookbooks"
      #Se añade la receta de kibana
      chef.add_recipe "kibana"
      #Se agregan dos variables (la direccion ip del servidor kibana y la url del servidor elasticsearch)
      chef.json = {"direccion_ip" => "192.168.56.102", "elasticsearch_url" => "http://192.168.56.101:9200"}

    end


  end

  #servidor encargado de hacer la conversión de logs por medio de la aplicación Logstash
  config.vm.define :logstash_server do |logstash_server|
    #definicion de la imagen del SO a utilizar (en este caso Centos7)
    logstash_server.vm.box = "centos1706_v0.2.0"
    #Configuracion de una red privada e ip asociada a la maquina
    logstash_server.vm.network :private_network, ip: "192.168.56.103"
    #Configuracion de la cantidad de memoria RAM, numero de cpus y nombre de la maquina virtual
    logstash_server.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "logstash_server" ]
    end

    #Definicion del aprovisionador a utilizar (chef solo)
    config.vm.provision :chef_solo do |chef|
      #No se instala el aprovisionador porque ya esta contenido en la imagen del sistema operativo
      chef.install = false
      #Definicion del directorio que contiene las recetas de aprovisionamiento
      chef.cookbooks_path = "cookbooks"
      #Se añade la receta de logstash
      chef.add_recipe "logstash"
      #Se agrega una variable con la direccion ip del servidor elasticsearch
      chef.json = {"direccion_ip" => "192.168.56.101"}
    end
  end

  #servidor web ejecutando la aplicación filebeat para el envío de los logs al servidor con Logstash
  config.vm.define :web_server do |web_server|
    #definicion de la imagen del SO a utilizar (en este caso Centos7)
    web_server.vm.box = "centos1706_v0.2.0"
    #Configuracion de una red privada e ip asociada a la maquina
    web_server.vm.network :private_network, ip: "192.168.56.104"
    #Configuracion de la cantidad de memoria RAM, numero de cpus y nombre de la maquina virtual
    web_server.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "web_server" ]
    end

    #Definicion del aprovisionador a utilizar (chef solo)
    config.vm.provision :chef_solo do |chef|
      #No se instala el aprovisionador porque ya esta contenido en la imagen del sistema operativo
      chef.install = false
      #Definicion del directorio que contiene las recetas de aprovisionamiento
      chef.cookbooks_path = "cookbooks"
      #Se añade la receta de httpd
      chef.add_recipe "httpd"
      #Se añade la receta de logstash
      chef.add_recipe "filebeat"
      #Se agrega una variable con la direccion ip del servidor logstash
      chef.json = {"direccion_ip" => "192.168.56.103"}
    end
  end
  
end
```

***3.Escriba los cookbooks necesarios para realizar la instalación de los servicios solicitados***



***4.Incluya evidencias que muestran el funcionamiento de lo solicitado*** 

__servicio httpd en servidor web__



__registro de logs de httpd por medio del stack ELK__


***5.Documente algunos de los problemas encontrados y las acciones efectuadas para su solución al aprovisionar la 
infraestructura y aplicaciones***

__problemas encontrados__

  * __version de java__
    el stack ELK requiere java 1.8 para su correcto funcionamiento. En este caso, se tuvo problemas al iniciar los servicios
    dado que se poseia una version mas antigua.
    Para solucionarlo se uso el siguiente comando:
    ```bash
    yum install java-1.8.0-openjdk.x86_64
    ```
    





