##################################################################
################### 15 Minutes Setup Script ######################          
##################################################################


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

USER='root';

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
                   item=("tomcat" "jdk1.6.0_30" "HKRejuvenate2");
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
ssh  $USER@$IP " service httpd stop";
ssh  $USER@$IP " pkill -f /usr/local/tomcat/bin/";
ssh  $USER@$IP " jboss-kill";
ssh  $USER@$IP " kill -9 \`ps aux | grep java\`";

#ssh  $USER@$IP " rm -rf /usr/local/projects";
#ssh  $USER@$IP " rm -rf /usr/local/tomcat";
#ssh  $USER@$IP " rm -rf /usr/local/elasticsearch-0.90.10";
ssh -r $USER@$IP " rm -rf /usr/local/bin/*";



for index in ${item[@]};
do
	ssh  $USER@$IP " rm -rf ${destination[$local_key]}$index";
	ssh  $USER@$IP " mkdir -p ${destination[$local_key]}";
	ssh  $USER@$IP " rm -rf ${local[$local_key]}";
	ssh  $USER@$IP "mkdir -p ${local[$local_key]}";
	scp -r ${local[$local_key]}$index $USER"@"$IP:${local[$local_key]}$index;
 	ssh  $USER@$IP " mv ${local[$local_key]}$index ${destination[$local_key]}$index";
local_key=`expr $local_key + 1`;	
done

if [ $CLUSTERNAME == 'hkweb' ];
then
	ssh  $USER@$IP ' yum install httpd -y';
	ssh  $USER@$IP ' service httpd start';
elif [ $CLUSTERNAME == "api" ];
then
	ssh  $USER@$IP ' mv /usr/local/bin/scripts/* /usr/local/bin/';
	ssh  $USER@$IP ' rm -rf /usr/local/bin/scripts';
	ssh  $USER@$IP ' mv /usr/local/bin/jboss /etc/init.d/';
fi

#INSTALLING ANT
ssh  $USER@$IP " yum install ant -y";

#INSTALLING GIT
ssh  $USER@$IP " yum install git -y";

#ANT  DEV CLEAN
ssh  $USER@$IP "cd ${destination[2]}${item[2]}; ant";

# Script to start tomcat services
ssh  $USER@$IP ' nohup /usr/local/tomcat/bin/startup.sh';

if [ $CLUSTERNAME == "api" ];
then
	ssh  $USER@$IP ' /usr/local/bin/jboss-start';
        ssh  $USER@$IP ' /usr/local/bin/es-start';
fi
