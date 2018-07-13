# -*- mode: ruby -*-
# vi: set ft=ruby :

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
      #Se agrega una variable que servira como identificador del servidor
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
