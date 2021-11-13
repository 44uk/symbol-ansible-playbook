FROM python:3.9-slim
RUN apt-get update && apt-get install -y \
  sshpass \
  && apt-get autoremove && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/* \
  && pip install ansible==2.10.7
WORKDIR /playbook
ENTRYPOINT [ "ansible-playbook" ]
CMD [ "--version" ]
