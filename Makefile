recreate:
	@vagrant destroy -f
	@vagrant up

destroy:
	@vagrant destroy -f

provision:
	@vagrant provision

vm-infra:
	@vagrant up; cd playbook && ansible-playbook -i hosts infra.yml --limit vm

vm-setup:
	@vagrant up; cd playbook && ansible-playbook -i hosts full.yml --limit vm

remote-setup:
	@cd playbook && ansible-playbook -i hosts full.yml --limit all

remote-https:
	@cd playbook && ansible-playbook -i hosts https.yml --limit all
