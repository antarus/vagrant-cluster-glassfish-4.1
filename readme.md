Test cluster glassfish 4.1 avec vagrant
=========
Attention replication de session non fonctionnelle / Broken Session Replication
-------

Les replications de session ne fonctionnent pas     .

Ceci est un projet de test de cluster glassfish 4.1 avec 2 machines hebergeant chacune une instance.

Si vous changez les Ip dans le ``vagrantfile`` pensez a éditer le fichier  ``installation\scripts\commun\environnement_configuration``

Installation
=====

lancer les machines et la provision

  
  $``vagrant up``


Une fois les machines glassfish1 et glassfish2 provisionnées, finaliser la création du cluster sur la machine ``glassfish1``   

  
  $``vagrant ssh glassfish1``
  
  [vagrant@machine ~]$ ``sudo sh /vagrant/installation/scripts/glassfish1/10-glassfish1_finalisation.sh``
  
  
Ouvrer votre navigateur et connectez vous a l'adresse http://169.254.129.101:4848/ 

Connecter vous avec le user admin, password : adminadmin

Dans applications deployer le war  ``clusterjsp.war`` en  cochant ``availability`` et en choissisant la target ``c1``

Ouvrez les logs du servers

384 	INFO 	clusterjsp was successfully deployed in 192 milliseconds.(details) 	javax.enterprise.system.core 	18 janv. 2016 17:37:54.763 	{levelValue=800, timeMillis=1453138674763}
383 	INFO 	visiting unvisited references(details) 	javax.enterprise.system.tools.deployment.common 	18 janv. 2016 17:37:54.605 	{levelValue=800, timeMillis=1453138674605}
*382 	INFO 	================== availabilityEnabled skipped(details)* 		18 janv. 2016 17:37:54.543 	{levelValue=800, timeMillis=1453138674543}
381 	INFO 	uploadFileName=clusterjsp.war(details) 	org.glassfish.admingui 	18 janv. 2016 17:37:54.536 	{levelValue=800, timeMillis=1453138674536}
380 	INFO 	GUI deployment: uploadToTempfile(details) 	org.glassfish.admingui 	18 janv. 2016 17:37:54.518 	{levelValue=800, timeMillis=1453138674518}

**================== availabilityEnabled skipped(details)**, le détail ne m'apprends rien de plus le texte est tout simplement identique.

...

 A terme il doit y avoir un apache en load balancing.


