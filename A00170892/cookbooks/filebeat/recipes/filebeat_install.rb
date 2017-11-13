#Instalacion de Filebeat
cookbook_file '/tmp/script.sh' do
	source 'script.sh'
	mode 0711
	owner 'root'
	group 'wheel'
end

bash 'instalacion_elasticsearch' do
 user 'root'
 group 'wheel'
 cwd '/tmp'
 code <<-EOH
 ./script.sh
 EOH
end
