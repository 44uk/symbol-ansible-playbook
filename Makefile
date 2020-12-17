recreate:
	@vagrant destroy -f
	@vagrant up --provision

destroy:
	@vagrant destroy -f

provision:
	@vagrant provision

provision-vagrant:
	@cd playbook && ansible-playbook -i hosts site.yml --limit vagrant

provision-remote:
	@cd playbook && ansible-playbook -i hosts site.yml --limit dual
