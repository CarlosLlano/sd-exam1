#configuracion de elasticsearch
template '/etc/elasticsearch/elasticsearch.yml' do
	source 'elasticsearch.erb'
	mode 0644
	owner 'root'
	group 'wheel'
	variables(
		:direccion_ip => node[:direccion_ip]
	)
end

#Iniciar elasticsearch
service 'elasticsearch' do
    action [ :enable, :start ]
end
