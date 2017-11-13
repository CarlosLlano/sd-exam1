#configuracion de filebeat
template '/etc/filebeat/filebeat.yml' do
	source 'filebeat.erb'
	mode 0644
	owner 'root'
	group 'wheel'
	variables(
		:direccion_ip => node[:direccion_ip]
	)
end

#Iniciar elasticsearch
service 'filebeat' do
    action [ :enable, :start ]
end
