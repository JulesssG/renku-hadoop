# Hadoop deployment

## Overview of Hadoop deployment

The deployment of Hadoop is much more complicated than the one of Renku.  
As it is distributed, it needs coordination between the nodes and without a 
service that facilitates the installations, all other services based on Hadoop
would need manual installation, configuration and management. To automate 
this process we use [Ambari](https://www.cloudera.com/products/open-source/apache-hadoop/apache-ambari.html),
an application whose aim is to simplify the deployment and management of 
Hadoop clusters. Configured appropriately, Ambari can deploy the Hadoop 
clusters and install and configure all services the administrator wants 
to be available on the cluster.

The problem with using Ambari is that 
[it is no longer free](https://community.cloudera.com/t5/Support-Questions/How-do-I-download-the-latest-version-of-Ambari-and-HDP/m-p/299115/highlight/true#M219531).
It is now mandatory to be subscribed to Cloudera to access the repository. 
The good news is that *only* accessing their repository needs a subscription. 
Their software was freely accessible before, so we can still access the code 
for free. All that is needed is to assemble it into a package so that we can
use it easily. The other good news is that a Data Architect named 
[Steven Matison](https://ds-steven-matison.github.io/) did exactly that.  His site 
[Make Open Source Great Again](http://makeopensourcegreatagain.com/) (MOSGA) is 
composed of free repositories of software that become proprietary and it contains 
Ambari and its HDP and HDF software suites (Cloudera softwares related to Ambari). 
This allows us to use Ambari even in our free and open-source approach.

Now that we have access to the resources needed, we can deploy our Hadoop cluster. 
As for the Renku deployment, we broadly describe the deployment here but we've written 
a detailed description of the steps we took during the deployment below. 
And there are always [the official instructions](https://docs.cloudera.com/HDPDocuments/Ambari-2.7.4.0/bk_ambari-installation/content/ch_Getting_Ready.html) 
that are more exhaustive. For the installation, Ambari starts from one 
node, the Ambari master, and can deploy itself to all other nodes named 
Ambari agents. A Hadoop deployment is installed directly on the machine, 
meaning that it doesn't use virtualization, as Renku does with Docker.
Therefore here the first step is to install the machines with the correct 
Operating System. We install CentOS in order to be compatible with the MOSGA 
repositories. Then comes the preparation of the nodes: install the package 
dependencies, setup password-less connection via ssh between the Ambari 
master and the agents, etc. For the preparation of the nodes, one important 
step is to correctly set up both forward and reverse DNS lookup between the 
nodes. Because Hadoop relies heavily on DNS, it is important to have efficient 
DNS lookups. What we did is to simply hardcode the Domain/IP pairs in the 
`/etc/hosts` file on every host. Once all nodes are ready, it suffices to 
set up the Ambari server and start it, both using the ambari-server command. 
Then you can access the Ambari installation wizard at the domain name of your 
Ambari master.  This wizard takes you through the installation process and if 
it is successful all following tasks (adding or modifying services, accessing 
configurations, etc.) can be done through the web UI of Ambari accessible 
through the same address as was the wizard (the IP address of the Ambari master).

## Precise steps taken for our Hadoop deployment
We deploy Hadoop on multiple nodes using Ambari, a software from Cloudera that 
facilitates the installation. The nodes are separated between masters and slaves. 
There is no minimum number of nodes required, it is possible to deploy Hadoop on a 
single node containing all the master and slave processes but it should only be 
used for evaluation purposes. Typically the minimum number of nodes recommended 
for a minimum cluster is at . For more information on the number of nodes required 
for your use and their hardware recommendation, you can refer to [this page](./switchengines-configuration/roles).

1. Install the package dependencies: `rpm`, `scp`, `curl`, `unzip`, `tar`, `wget`, `gcc`, OpenSSL (v1.01, build 16 or later), Python 2.7.12 (with python-devel)
1. Set the maximum number of open file descriptors to a sensible default (e.g. 10000). You can for example set a hard limit in the file `/etc/security/limits.conf`.
1. Set up password-less ssh connection between the Ambari server and the agents: generate a private and public SSH keys on the server in the root account. Copy the generated public key to each agent by appending the content of `/root/.ssh/id_rsa.pub` to the file `/root/.ssh/authorized_keys` on each host. Then manually connect to each agent from the host to ensure it is working and validate the authenticity of each host.
1. Enable NTP on all nodes: install `ntp` and enable it using `systemctl enable ntpd`
1. Disable ipv6 on all nodes. You can refer to the switch engine configuration to see how to disable it.
1. Set up the files `/etc/hostname` and `/etc/hosts` for local DNS resolution on all nodes. The first file should contain the Fully Qualified Domain Name (FQDN) and the second should have entries for the current node and then one line per node in the form <Local ip address> <domain name> FQDN.
1. Disable SELinux on all nodes with the command `setenforce 0`. You can also set `SELINUX=disabled` in `/etc/selinux/config` to ensure it will stay disabled after rebooting the machines.
1. On each nodes add the following MOSGA repositories to yum: http://makeopensourcegreatagain.com/repos/centos/7/hdp/ and http://makeopensourcegreatagain.com/repos/centos/7/ambari/2.7.5.0/.
1. Install `ambari-server` with yum on the Ambari server.
1. Setup the ambari server using `ambari-server setup` (if you encounter problems check the official documentation).
1. Start the Ambari server: `ambari-server start` and then you should be able to access the Ambari wizard by pasting the public ip address of your Ambari server in your browser. Again if you have trouble with this step don’t hesitate to check [the official documentation](https://docs.cloudera.com/HDPDocuments/Ambari-2.7.4.0/bk_ambari-installation/content/ch_Deploy_and_Configure_a_HDP_Cluster.html). You may have to add a certificate to the Ambari server to be able to access it from the browser. All remaining steps are well explained in the wizard: name your cluster, choose the services you want to install, assign the nodes, etc. It is important to use the root account for the wizard and when you are prompted for an ssh-key make sure to copy the private ssh key that has been generated on the Ambari server.
