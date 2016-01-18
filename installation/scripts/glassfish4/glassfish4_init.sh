#!/usr/bin/env bash
source /tmp/environnement_configuration
source $BASE_SCRIPT_PROVISION/commun/./lib.erreur.sh

echo "Configuration diverses"
echo "Changement hostname definition du nom $NOM_HOST_MACHINE_GLASSFISH4:"
sudo sysctl kernel.hostname=$NOM_HOST_MACHINE_GLASSFISH4
 
# sauvegarde le fichier host
if [ -f /etc/hosts ];then
   sudo mv /etc/hosts /etc/hosts.old.$(date +"%Y_%m_%d_")
fi

# ajoute les host du cluster au fichier hosts
sudo echo "127.0.0.1 localhost" >> /etc/hosts
sudo echo "127.0.1.1 $NOM_HOST_MACHINE_GLASSFISH4" >> /etc/hosts
sudo echo "127.0.0.1 $NOM_HOST_MACHINE_GLASSFISH4" >> /etc/hosts
sudo echo "$IP_HOST_MACHINE_GLASSFISH1 $NOM_HOST_MACHINE_GLASSFISH1" >> /etc/hosts
sudo echo "$IP_HOST_MACHINE_GLASSFISH2 $NOM_HOST_MACHINE_GLASSFISH2" >> /etc/hosts
sudo echo "$IP_HOST_MACHINE_GLASSFISH3 $NOM_HOST_MACHINE_GLASSFISH3" >> /etc/hosts

sudo sed -i -e"s@HOSTNAME=.*@HOSTNAME=$NOM_HOST_MACHINE_GLASSFISH4@" /etc/sysconfig/network


#change le hostname
sudo sed -i 's/centos66/$NOM_HOST_MACHINE_GLASSFISH4/g' /etc/hosts

# TODO Vagrant garder que le "else" pour la PROD
if grep -c '^vagrant:' /etc/passwd; then
#change le hostname
  sudo sed -i 's/centos66/$NOM_HOST_MACHINE_GLASSFISH4/g' /etc/hosts
else
  sudo sed -i 's/centos66/$NOM_HOST_MACHINE_GLASSFISH4/g' /etc/hosts
fi
# TODO FIN Vagrant 

# installation de la partie glassfish
sh $BASE_SCRIPT_PROVISION/commun/./99-provision-glassfish.sh

