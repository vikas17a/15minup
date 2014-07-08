15 min up script
================

This script enables us to set up a down machine up and running in 15 mins from scratch

Usage
=====

This script require proper directory structure

Directory Structure
===================
```
- centralrepo `This name can be changed with respect to any other name`
    - elastic_search
	- api
	  -elasticsearch
    - jboss
	- api
	  -jboss
    - tomcat
	- hkweb
	   - tomcat
        - bright
	   - tomcat
        - admin
	   - tomcat
    - repo
	- api
	  - HKEdge
        - hkweb
          - HKWeb
        - bright
          - HKRejunevate
        - admin
	  - HKRejunevate
     - java
        - java

```

Work Flow
=========
```
- Check for proper usage i.e "sh setupbox.sh <Cluster Name> <IP> "
- Create non root user require script to be used setupbox_ec2.sh
- Create final and local paths accrording to directory structure.
- Clear the remote machine destinations to be used for copy.
- Copy all the required items listed in switch statement to remote machine
- Stop all the service related to java , tomcat, jboss, elastic search according to the cluster machine requirment
- Install ant 
- Install git
- Building project with ant 
- Starting all the services as required by the cluster
```

Files
=====
```
- setupbox_root.sh for root user
- setupbox_ec2.sh for non-root user

```

Credits and Regards
===================
Script created by Vikas Aggarwal under guidence of Rahul Agarwal, Nitin Wadhawan and P Singh
Thanks all for your esteemed support.
