recreate:
	@vagrant destroy -f
	@vagrant up --provision

destroy:
	@vagrant destroy -f

provision:
	@vagrant provision

vagrant-setup:
	@cd playbook && ansible-playbook -i hosts setup.yml --limit vagrant

vagrant-update:
	@cd playbook && ansible-playbook -i hosts update.yml --limit vagrant

remote-setup:
	@cd playbook && ansible-playbook -i hosts setup.yml --limit dual

remote-update:
	@cd playbook && ansible-playbook -i hosts update.yml --limit dual
