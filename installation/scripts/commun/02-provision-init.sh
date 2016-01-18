#!/usr/bin/env bash
echo " "
echo " "
echo " "
echo "----------------------------------"
echo "----------------------------------"
echo "Début provision - init"
echo "----------------------------------"
echo "----------------------------------"
echo " "
echo " "
echo " "
source /tmp/environnement_configuration
source $BASE_SCRIPT_PROVISION/commun/./lib.erreur.sh

echo "TODO A ACTIVER !!!"
echo "Update de tous les packages"
#sudo yum -y update
echo "TODO FIN A ACTIVER !!!"

echo "Installation des outils necessaires"
echo "wget, unzip, acpid, createrepo:"
sudo yum -y install wget unzip

   sudo mkdir -p /var/cache/wget   

echo "Arrêt du service iptables"
sudo service iptables stop
sudo service ip6tables stop
sudo chkconfig iptables off
sudo chkconfig ip6tables off

echo "Désactivation de SELinux"
#sudo sed -i -e"s@SELINUX=enforcing@SELINUX=disabled@" /etc/sysconfig/selinux
sudo sed -i -e"s@SELINUX=enforcing@SELINUX=disabled@" /etc/selinux/config
# desactivation pour eviter de redemarré pour que la modification du dessus sois prise en compte
sudo setenforce 0  > /dev/null 2>&1 || true

echo -e " "
echo -e "Initialisation : ${BLEU}OK${PAS_COULEUR}"
echo -e " "
