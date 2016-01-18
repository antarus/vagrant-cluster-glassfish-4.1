#!/usr/bin/env bash
source /tmp/environnement_configuration
source $BASE_SCRIPT_PROVISION/commun/./lib.erreur.sh

echo ""
echo ""
echo ""
echo "----------------------------------"
echo "----------------------------------"
echo "installation du jdk $JDK_VERSION  "  
echo "----------------------------------"
echo "----------------------------------"
echo " "
echo " "
echo " "

cd /opt
if [ ! -d "/opt/jdk1.$JDK_VERSION_2" ];then
  echo "recuperation en cours. veuillez patienter ... "       
                                                                                                   
  sudo wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -q -N -P /var/cache/wget http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-$JDK_VERSION.tar.gz

  echo "Installation en cours"
  sudo tar xzf /var/cache/wget/jdk-$JDK_VERSION.tar.gz
  cd /opt/jdk1.$JDK_VERSION_2

  sudo  alternatives --install /usr/bin/java java /opt/jdk1.$JDK_VERSION_2/bin/java 2
  #sudo  alternatives --config java
  sudo alternatives --install /usr/bin/jar jar /opt/jdk1.$JDK_VERSION_2/bin/jar 2
  sudo alternatives --install /usr/bin/javac javac /opt/jdk1.$JDK_VERSION_2/bin/javac 2
  sudo alternatives --set jar /opt/jdk1.$JDK_VERSION_2/bin/jar
  sudo alternatives --set javac /opt/jdk1.$JDK_VERSION_2/bin/javac

  echo "Configuration Setup PATHVariable"
  export PATH=$PATH:/opt/jdk1.$JDK_VERSION_2/bin:/opt/jdk1.$JDK_VERSION_2/jre/bin

  # Ajout des variables pour qu'elles soit disponible pour tous les utilisateurs
  echo "Ajout des variables au fichier /etc/environment"
  echo "JAVA_HOME=$JAVA_HOME" >> /etc/environment
  echo "JRE_HOME=$JRE_HOME" >> /etc/environment
  echo "AS_JAVA=$JAVA_HOME" >> /etc/environment
  export JAVA_HOME=$JAVA_HOME
  export JRE_HOME=$JRE_HOME
  export AS_JAVA=$JAVA_HOME

else
  echo "Version java $JDK_VERSION_2 déja installée : on passe"
fi




echo -e " "
echo -e "Installation du JDK: ${BLEU}OK${PAS_COULEUR}"
echo -e " "
