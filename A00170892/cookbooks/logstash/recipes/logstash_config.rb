#configuracion de logstash
template '/etc/logstash/conf.d/apache-logstash.conf' do
	source 'apache-logstash.erb'
	mode 0644
	owner 'root'
	group 'wheel'
	variables(
		:direccion_ip => node[:direccion_ip]
	)
end

#Iniciar elasticsearch
service 'logstash' do
    action [ :enable, :start ]
end
