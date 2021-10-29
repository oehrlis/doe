Oracle Database 12c Release 12.1.0.2.200714DBPSU

ORACLE SECURITY SERVICE Patch for Bug# 23627427 for Linux-x86-64 Platforms

This patch is RAC Rolling Installable  - Please read My Oracle Support Document 244241.1 https://support.us.oracle.com/oip/faces/secure/km/DocumentDisplay.jspx?id=244241.1 
Rolling Patch - OPatch Support for RAC.

This patch is non-Data Guard Standby-First Installable - Please read My Oracle Support Note 1265700.1 https://support.us.oracle.com/oip/faces/secure/km/DocumentDisplay.jspx?id=1265700.1
Oracle Patch Assurance - Data Guard Standby-First Patch Apply for details on how to remove risk and reduce downtime when applying this patch. 

Released: Mon Jul 20 11:16:09 2020
  
This document describes how you can install the ORACLE SECURITY SERVICE overlay patch for bug#  23627427 on your Oracle Database 12c Release 12.1.0.2.200714DBPSU
 

 
(I) Prerequisites
--------------------
Before you install or deinstall the patch, ensure that you meet the following requirements:

Note: In case of an Oracle RAC environment, meet these prerequisites on each of the nodes.

1.	Ensure that the Oracle home on which you are installing the patch or from which you are rolling back the patch is Oracle Database 12c Release 12.1.0.2.200714DBPSU.
 
2.	Ensure that 12c Release 12.1.0.2.200714DBPSU Patch Set Update (PSU) 31113348 is already applied on the Oracle Database.

3.      Ensure that you have OPatch 12c Release 12.1.0.1.4 or higher. Oracle recommends that you use the latest version available for  12c Release 12.1.0.1.4. 
	
	Note:
	If you do not have OPatch 12c Release 12.1.0.1.4 or the latest version available for 12c Release 12.1.0.1.4, then download it from patch# 6880880 for  12.1.0.1.4.

	For information about OPatch documentation, including any known issues, see My Oracle Support Document 293369.1 OPatch documentation list:
	https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=224346.1

4.	Ensure that you set (as the home user) the ORACLE_HOME environment variable to the Oracle home.

5.	Ensure that the $PATH definition has the following executables: make, ar, ld and nm. The location of these executables depends on your operating system. On many operating systems, they are located in /usr/ccs/bin.	

6.	Ensure that you verify the Oracle Inventory because OPatch accesses it to install the patches. To verify the inventory, run the following command.
       $ opatch lsinventory 
	Note:
	-	If this command succeeds, it will list the Top-Level Oracle Products and one-off patches if any that are installed in the Oralce Home.
			- Save the output so you have the status prior to the patch apply.
	-	If the command displays some errors, then contact Oracle Support and resolve the issue first before proceeding further.

7.	(Only for Installation) Maintain a location for storing the contents of the patch ZIP file. In the rest of the document, this location (absolute path) is referred to as <PATCH_TOP_DIR>. Extract the contents of the patch ZIP file to the location (PATCH_TOP_DIR) you have created above. To do so, run the following command:
	$ unzip -d <PATCH_TOP_DIR>  p23627427_12102200714_Linux-x86-64.zip 


8.	(Only for Installation) Determine whether any currently installed interim patches conflict with this patch 23627427 as shown below:
	$ cd <PATCH_TOP_DIR>/23627427
	$ opatch prereq CheckConflictAgainstOHWithDetail -ph ./
	
	The report will indicate the patches that conflict with this patch and the patches for which the current 23627427 is a superset.
	
	Note:
	When OPatch starts, it validates the patch and ensures that there are no conflicts with the software already installed in the ORACLE_HOME. OPatch categorizes conflicts into the following types: 
	-	Conflicts with a patch already applied to the ORACLE_HOME that is a subset of the patch you are trying to apply  - In this case, continue with the patch installation because the new patch contains all the fixes from the existing patch in the ORACLE_HOME. The subset patch will automatically be rolled back prior to the installation of the new patch.
	-	Conflicts with a patch already applied to the ORACLE_HOME - In this case, stop the patch installation and contact Oracle Support Services.

9.	Ensure that you shut down all the services running from the Oracle home.
	Note:
		-	For a Non-RAC environment, shut down all the services running from the Oracle home. 
		-	For a RAC environment, shut down all the services (database, ASM, listeners, nodeapps, and CRS daemons) running from the Oracle home of the node you want to patch. After you patch this node, start the services on this node.Repeat this process for each of the other nodes of the Oracle RAC system. OPatch is used on only one node at a time.
                -       Please use -local option to apply the patch to the particular node. e.g., opatch apply -local



(II) Installation  
-----------------
To install the patch, follow these steps:

1.	Set your current directory to the directory where the patch is located and then run the OPatch utility by entering the following commands:

	$ cd <PATCH_TOP_DIR>/23627427

	$ opatch apply

2.	Verify whether the patch has been successfully installed by running the following command:

	$ opatch lsinventory

3.	Start the services from the Oracle home.





(III) Deinstallation
----------------------
Ensure to follow the Prerequsites (Section I). To deinstall the patch, follow these steps:


1.	Deinstall the patch by running the following command:

	$ opatch rollback -id 23627427
  
2.	Start the services from the Oracle home.

3.	Ensure that you verify the Oracle Inventory and compare the output with the one run before the patch installation and re-apply any patches that were rolled back as part of this patch apply. To verify the inventory, run the following command:

	$ opatch lsinventory







(IV) Bugs Fixed by This Patch
---------------------------------
The following are the bugs fixed by this patch:
  23627427: NEED SUPPORT FOR DB 12C PASSWORD VERSION IN ZTV/ZTVGH


--------------------------------------------------------------------------
Copyright 2020, Oracle and/or its affiliates. All rights reserved.
--------------------------------------------------------------------------
