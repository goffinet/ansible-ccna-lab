#!/bin/bash
install-ansible() {
# Installer Ansible pour Ubuntu
if [ -f /etc/debian_version ] ; then
export DEBIAN_FRONTEND="noninteractive"
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get upgrade --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
apt-get -y install ansible
# Installer les composants Docker
apt -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
apt remove docker docker-engine docker.io containerd runc
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt -y install docker-ce docker-ce-cli containerd.io curl
usermod -aG docker $USER
apt update
apt -y install curl
curl -s https://api.github.com/repos/docker/compose/releases/latest \
  | grep browser_download_url \
  | grep docker-compose-Linux-x86_64 \
  | cut -d '"' -f 4 \
  | wget -qi -
chmod +x docker-compose-Linux-x86_64
mv docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
apt install -y nodejs npm
npm install npm --global
apt -y install python-pip git pwgen vim
pip install requests==2.14.2
pip install docker-compose==$(docker-compose version --short)
service docker start
fi
if [ -f /etc/centos-release ] ; then
dnf install -y epel-release
dnf install -y git gcc gcc-c++ nodejs gettext device-mapper-persistent-data lvm2 bzip2 python3-pip python3 ansible
dnf -y config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install docker-ce --nobest
systemctl start docker
systemctl enable --now docker.service
usermod -aG docker $USER
alternatives --set python /usr/bin/python3
pip3 install --user docker-compose
fi
}
install-awx() {
FQDN="localhost"
# Télécharger AWX
mkdir awx-install
cd awx-install
apt-get -y install git || dnf -y install git
git clone https://github.com/ansible/awx.git
git clone https://github.com/ansible/awx-logos.git
# Configurer l'installation d'AWX
PSQL_DATA_PATH="/opt/awx-psql-data"
mkdir -p ${PSQL_DATA_PATH}
SECRETKEY=$(pwgen -N 1 -s 30)
STRONGPASSWD=$(pwgen -N 1 -s 12)
mkdir -p /var/lib/awx/projects
mv ~/awx-install/awx/installer/inventory ~/awx-install/awx/installer/inventory.old
cat << EOF > ~/awx-install/awx/installer/inventory
localhost ansible_connection=local ansible_python_interpreter="/usr/bin/env python"
[all:vars]
awx_task_hostname=awx
awx_web_hostname="${FQDN}"
awx_official=true
postgres_data_dir="${PSQL_DATA_PATH}"
host_port=8000
docker_compose_dir="~/.awx/awxcompose"
pg_username=awx
pg_password=awxpass
pg_database=awx
pg_port=5432
rabbitmq_password=awxpass
rabbitmq_erlang_cookie=cookiemonster
admin_user=admin
admin_password=${STRONGPASSWD}
create_preload_data=True
secret_key=${SECRETKEY}
project_data_dir=/var/lib/awx/projects
EOF
cd ~/awx-install/awx/installer/
ansible-playbook -i inventory install.yml -v
}

install-ansible
install-awx
grep 'admin_password' ~/awx-install/awx/installer/inventory
