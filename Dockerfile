FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y openssh-client git && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir ansible ansible-lint

COPY . /app

WORKDIR /app/playbooks

CMD ["ansible-playbook", "-i", "inventory.yml", "confluence.yml"]
