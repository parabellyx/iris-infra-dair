#!/bin/bash

# Install k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.23.4+k3s1 sh -


# Configure Linux
sysctl -w vm.max_map_count=524288
echo -n "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf

# Clone repo
mkdir -p /opt/iris && cd /opt/iris
git clone https://github.com/parabellyx/iris-infra-dair.git
cd iris-infra-dair

# Change the password based on env vars
RANDOM_STR=`openssl rand -base64 21`
sed -i "s/##password##/$RANDOM_STR/g" secrets/pgsql.secret
sed -i "s/##password##/$RANDOM_STR/g" secrets/pgsql.secret


kubectl kustomize | kubectl apply -f -

#Should at a wait here for the jenkins container to come into a running status
echo "sudo kubectl exec -it --namespace=appsec $(sudo kubectl get pods --namespace=appsec | awk '/jenkins/ {print $1}') -- cat /var/jenkins_home/secrets/initialAdminPassword" > /opt/iris/fetchJenkinsCred.sh
chmod +x /opt/iris/fetchJenkinsCred.sh
