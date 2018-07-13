#configuracion de kibana
template '/etc/kibana/kibana.yml' do
	source 'kibana.erb'
	mode 0644
	owner 'root'
	group 'wheel'
	variables(
		:direccion_ip => node[:direccion_ip],
    :elasticsearch_url => node[:elasticsearch_url]
	)
end

#Iniciar elasticsearch
service 'kibana' do
    action [ :enable, :start ]
end
