#!/usr/bin/env bash
source /tmp/environnement_configuration
source $BASE_SCRIPT_PROVISION/commun/./lib.erreur.sh

#redemarrage du cluster pour prendre ne compte les nouvelles instance
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD stop-cluster $NOM_CLUSTER
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD start-cluster $NOM_CLUSTER

#activation du  load balancing
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD enable-http-lb-server $NOM_CLUSTER

# creation des propriete systeme
## instance 1
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-system-properties --target $NOM_CLUSTER_INSTANCE1 AJP_PORT=$AJP_PORT_INST1
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-system-properties --target $NOM_CLUSTER_INSTANCE1 AJP_INSTANCE_NAME=$AJP_INSTANCE_NAME1
## instance 2
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-system-properties --target $NOM_CLUSTER_INSTANCE2 AJP_PORT=$AJP_PORT_INST2
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-system-properties --target $NOM_CLUSTER_INSTANCE2 AJP_INSTANCE_NAME=$AJP_INSTANCE_NAME2
## instance 3
#sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-system-properties --target $NOM_CLUSTER_INSTANCE3 AJP_PORT=$AJP_PORT_INST3
#sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-system-properties --target $NOM_CLUSTER_INSTANCE3 AJP_INSTANCE_NAME=$AJP_INSTANCE_NAME3
## instance 4
#sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-system-properties --target $NOM_CLUSTER_INSTANCE4 AJP_PORT=$AJP_PORT_INST4
#sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-system-properties --target $NOM_CLUSTER_INSTANCE4 AJP_INSTANCE_NAME=$AJP_INSTANCE_NAME4


#cree une option JVM pour caque instance du cluster
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-jvm-options --target $NOM_CLUSTER -DjvmRoute=${AJP_INSTANCE_NAME1}
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-jvm-options --target $NOM_CLUSTER -DjvmRoute=${AJP_INSTANCE_NAME2}
#sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-jvm-options --target $NOM_CLUSTER -DjvmRoute=${AJP_INSTANCE_NAME3}
#sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-jvm-options --target $NOM_CLUSTER -DjvmRoute=${AJP_INSTANCE_NAME4}

# creation d'un listener AJP pour le cluster
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-network-listener --protocol http-listener-1 --target $NOM_CLUSTER --listenerport ${AJP_PORT_INST1} --jkenabled=true jk-listener



echo "TODO A ACTIVER !!!"
echo "création du pool de connexion"
#sh $GLASSFISH_HOME/bin/asadmin  --port $PORT_APPLICATION_ADMIN --user $GLF4_USER_ADMIN_DOMAINE --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-jdbc-connection-pool --datasourceclassname $BDD_CLASS_NAME --restype javax.sql.DataSource --property user=$BDD_USER:password=$BDD_PWD:url="jdbc\:oracle\:thin\:@$BDD_IP\:$BDD_PORT\:$BDD_INSTANCE" $BDD_POOL

#echo "test du pool de connexion"
#sh $GLASSFISH_HOME/bin/asadmin --port $PORT_APPLICATION_ADMIN --user $GLF4_USER_ADMIN_DOMAINE --passwordfile $EMPLACEMENT_FICHIER_PASSWORD ping-connection-pool   $BDD_POOL

#echo "création de la ressource JDBC"
#sh $GLASSFISH_HOME/bin/asadmin --port $PORT_APPLICATION_ADMIN --user $GLF4_USER_ADMIN_DOMAINE --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-jdbc-resource --connectionpoolid $BDD_POOL $BDD_JDBC
echo "TODO FIN A ACTIVER !!!"


echo "création service démarrage/arrêt domaine $NOM_DOMAINE"
sudo sh -c "cat > /etc/init.d/glassfish" <<EOF
#!/bin/bash
#
# Glassfish   Script de demarrage et d arret domaine $NOM_DOMAINE
#
# chkconfig: - 86 15
# description: GlassFish
# processname: glassFish

# Linux Platform Services for GlassFish
# See this blog for more details:
# http://blogs.sun.com/foo/entry/run_glassfish_v3_as_a
# Remove the GF_USER setting to have the System account run GlassFish
#
#    Created on : Thu Mar 29 15:31:44 CEST 2012
#     Server Type:  Domain

case "" in
start)
   source ~/.bashrc
   #sudo sh $GLASSFISH_HOME/mq/bin/imqbrokerd
   sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD start-domain --domaindir $GLASSFISH_HOME/glassfish/domains $NOM_DOMAINE
   sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD start-cluster $NOM_CLUSTER
    ;;
stop)
   source ~/.bashrc
   sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD stop-cluster $NOM_CLUSTER
   sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD stop-domain --domaindir $GLASSFISH_HOME/glassfish/domains $NOM_DOMAINE
    ;;
restart)
   source ~/.bashrc
   sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD stop-cluster $NOM_CLUSTER
   sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD stop-domain --domaindir $GLASSFISH_HOME/glassfish/domains $NOM_DOMAINE
   sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD start-domain --domaindir $GLASSFISH_HOME/glassfish/domains $NOM_DOMAINE
   sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD start-cluster $NOM_CLUSTER
   ;;
*)
    echo "usage: (start|stop|help)"
esac
EOF
## fin fichier

sudo sed -i -e"s@case.*@case \"\$1\" in@" /etc/init.d/glassfish > /dev/null 2>&1





sudo chmod 755 /etc/init.d/glassfish
sudo chkconfig --add glassfish
sudo chkconfig glassfish on

# redemarrage de glassfish via le service pour le lancer avec l'utilisateur glassfish
echo "Arret de glassfish via le service"
sudo /etc/init.d/glassfish stop

echo "Modification droit"
sudo chown -Rf glassfish:glassfishadm $GLASSFISH_HOME
sudo chmod -Rf 755 $GLASSFISH_HOME/glassfish/domains/$NOM_DOMAINE/config
sudo chmod -Rf 755 $GLASSFISH_HOME/glassfish/nodes/localhost-$NOM_DOMAINE

echo "Demarrage de glassfish via le service"
sudo /etc/init.d/glassfish start

