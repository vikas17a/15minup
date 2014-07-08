##################################################################
################### 15 Minutes Setup Script ######################          
##################################################################
# Algo
#   -- Check for params 
#   -- Set user at remote machine 
#   -- Set destination and source directory structure according to switch statements
#   -- Clean all the remote destination
#   -- Start copying items to destination one by one at home directory and then move to working locations
#   -- Stop all services on the remote machine linked with java , jboss, tomcat
#   -- Start all the services accordingly for which we have started setup
#
#   --Requirement 
#     The remote user must support sudo
#     Usage should pe properly followed
#     API cluster is not included (TO be updated soon)



if [ -d $1 ]; 
then
	echo "ERROR : ";
	echo "Usage sh setupbox.sh <Cluster Name> <IP box>";
	exit 1;
else
	CLUSTERNAME=$1;
fi


if [ -d $2 ];
then 
	echo "ERROR :";
	echo "Usage sh setupbox.sh <Cluster Name> <IP box>";
	exit 1;
else
	IP=$2;
fi

USER='ec2-user';

ELASTICSEARCH_CONF="elastic_search/elasticsearch-0.90.10/elasticsearch-0.90.10/config/elasticsearch.yml";

if [ $CLUSTERNAME == "api" ];
then
        printf "Please enter the Sister IP of elastic search" ;
        read SISTER_IP;
        sed -i 's/network\.host:.*/network\.host:\ '$IP'/g' $ELASTICSEARCH_CONF;
        if [ ! -d $SISTER_IP ];
        then
                sed -i 's/discovery\.zen\.ping\.unicast\.hosts:.*/discovery\.zen\.ping\.unicast\.hosts:\ '$SISTER_IP'/g' $ELASTICSEARCH_CONF;
	else
		sed -i 's/discovery\.zen\.ping\.unicast\.hosts:.*/\#discovery\.zen\.ping\.unicast\.hosts:\ /g' $ELASTICSEARCH_CONF;
        fi
fi


case $CLUSTERNAME in

	"admin")  destination=("/usr/local/" "/usr/java/" "/usr/local/projects/rejuvenate/");
		  local=("tomcat/admin/" "java/" "repos/admin/");
		  item=("tomcat" "jdk1.6.0_30" "HKRejuvenate");
	;;
	
	"bright")  destination=("/usr/local/" "/usr/java/" "/usr/local/projects/rejuvenate/");
        	   local=("tomcat/bright/" "java/" "repos/bright/");
                   item=("tomcat" "jdk1.6.0_30" "HKRejuvenate");
	;;

        "hkweb")  destination=("/usr/local/" "/usr/java/" "/usr/local/projects/hkweb/");
	           local=("tomcat/hkweb/" "java/" "repos/hkweb/");
                   item=("tomcat" "jdk1.6.0_30" "HealthKartWeb");
;;
	"api")   destination=("/usr/local/" "/usr/java/" "/usr/local/projects/edge/" "/usr/local/" "/usr/local/bin/");
		 local=("jboss/api/" "java/" "repos/api/" "elastic_search/" "scripts/api/");
		item=("jboss" "jdk1.6.0_30" "HKEdge" "elasticsearch-0.90.10" "scripts");
esac

## Cleannig all directories ##


local_key=0;

#STOPING ALL SERVICES
ssh -t $USER@$IP "sudo service httpd stop";
ssh -t $USER@$IP "sudo pkill -f /usr/local/tomcat/bin/";
ssh -t $USER@$IP "sudo jboss-kill";
ssh -t $USER@$IP "sudo kill -9 \`ps aux | grep java\`";
ssh -t $USER@$IP "sudo rm -rf /usr/local/bin/*";

for index in ${item[@]};
do
	ssh -t $USER@$IP "sudo rm -rf ${destination[$local_key]}$index";
	ssh -t $USER@$IP "sudo mkdir -p ${destination[$local_key]}";
	ssh -t $USER@$IP "sudo rm -rf ${local[$local_key]}";
	ssh -t $USER@$IP "mkdir -p ${local[$local_key]}";
	scp -r ${local[$local_key]}$index $USER"@"$IP:${local[$local_key]}$index;
 	ssh -t $USER@$IP "sudo mv ${local[$local_key]}$index ${destination[$local_key]}$index";
local_key=`expr $local_key + 1`;	
done

if [ $CLUSTERNAME == 'hkweb' ];
then
	ssh -t $USER@$IP 'sudo yum install httpd -y';
	ssh -t $USER@$IP 'sudo service httpd start';
elif [ $CLUSTERNAME == "api" ];
then
	ssh -t $USER@$IP 'sudo mv /usr/local/bin/scripts/* /usr/local/bin/';
	ssh -t $USER@$IP 'sudo rm -rf /usr/local/bin/scripts';
	ssh -t $USER@$IP 'sudo mv /usr/local/bin/jboss /etc/init.d/';
fi

#INSTALLING ANT
ssh -t $USER@$IP "sudo yum install ant -y";

#INSTALLING GIT
ssh -t $USER@$IP "sudo yum install git -y";

#ANT  DEV CLEAN
ssh -t $USER@$IP "cd ${destination[2]}${item[2]};sudo ant";

# Script to start tomcat services
ssh -t $USER@$IP 'sudo nohup /usr/local/tomcat/bin/startup.sh';

if [ $CLUSTERNAME == "api" ];
then
	ssh -t $USER@$IP 'sudo /usr/local/bin/jboss-start';
        ssh -t $USER@$IP 'sudo /usr/local/bin/es-start';
fi
