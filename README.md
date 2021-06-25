# System Integration of the Hadoop framework in Renku

In this project, we explore how to deploy and configure Data Science projects with Hadoop in ![Renku](https://datascience.ch/renku/). We incorporate the configuration between the two components in our design of template for Renku. This template permits to reduce as much as possible the configuration needed to use a Hadoop cluster. Just from the file that defines the backend (5 to 10 addresses) it can automatize the rest of the procedure while keeping the possibility of configuring further the cluster's components. We also began working on an important configuration element of a Hadoop cluster, namely to provide authentication of the users on the cluster and the services available on it.

# Quick overview of the repository

- [deployments](./deployments): the documentation relative to the Renku and Hadoop deployments
- [hadoop-template](./hadoop-template): our Renku template for Hadoop
- [authentication](./authentication): documentation relative to the setup of authentication on the Hadoop cluster

Along with this project you can find:
- A repository containing an example Hadoop project in Renku that doesn't use our template (current state of Renku): [https://github.com/jjjules/hadoop-project-without-template](https://github.com/jjjules/hadoop-project-without-template)
- A repository containing an example Hadoop project in Renku using our template: [https://github.com/jjjules/hadoop-project-with-template](https://github.com/jjjules/hadoop-project-with-template)

# Motivations

The technology provided by ![Apache](https://www.apache.org/) with its Hadoop framework is the foundation of many leading services when it comes to Big Data processing. With this project, we work on improving the accessibility of this framework by providing documentation for all key components and a proposal of design for integrating an automatic and dynamic configuration of Hadoop in Renku, an open-source platform for reproducible and collaborative Data Science. Developed by the Swiss Data Science Center (![SDSC](https://datascience.ch/)), it enables versioning of the code, the data and the environment which together provides full reproducibility of Data Science projects. In the long term by offering a service similar to what we’re designing, Renku would be one of the  rare providers of an easy-to-use Hadoop environment and it would greatly improve the accessibility to it. The Renku plateform is also very useful in academic context. Our work of Hadoop integration in Renku can help the teaching of this framework by providing an easy to use and easy to manage Hadoop template in Renku.

# Background

## Overview of Hadoop

Apache Hadoop is a framework for distributed processing. It is composed of the Hadoop File System (HDFS), YARN and a MapReduce component. HDFS is the distributed file system made for Hadoop. YARN is the job scheduler and cluster resource management, it orchestrates the computation across the nodes and manages the resources needed for the computation. MapReduce is the programming model used by Hadoop, it has been designed for parallel and distributed processing on clusters.

Hadoop serves as the basis for a lot of services for Big Data based on distributed architecture: Spark, Hive, HBase, Kafka, etc. If you are unfamiliar with Hadoop and want to know more, Craig Stedman has made ![a great and accessible description of it](https://searchdatamanagement.techtarget.com/definition/Hadoop).  It is a very important tool, it is considered as the principal technology for Big Data processing for more than 10 years (![source](https://www.lebigdata.fr/hadoop)), especially in combination with Spark which is widely used.

## Overview of Renku

Renku is a platform for Data Scientists and Analysts, it helps them
create reproducible environments for their project. As Git is for the
code, Renku enables version control for the code, the data and the
computer environment which makes it the perfect tool for collaborative
and reproducible Data Science projects. A Renku project is similar to
any other project, it just needs some additional information for the
creation of the environment, mainly files needed by Docker. Renku is
always linked to a Gitlab instance where Renku stores its projects.

Renku is very intuitive to use. From the web UI of Renku a user can
choose a project and launch an interactive environment with a
command-line interface and the ability to launch jupyter notebooks to
code directly in the browser.

![General structure of Renku using an external computing cluster](./general-structure-renku.png)
*General structure of Renku using an external computing cluster*

# Hadoop in Renku - Current Situation

There are templates available in Renku to set up a new project rapidly.
A Renku template sets up a simple environment for the needed task. For
example, the template for python will install the packages needed by
python along with additional *nice-to-have* packages, add the extension
manager to jupyter and improve the command-line prompt with powershell.

For a project using Hadoop, the problem is that there is no integrated
support yet. Meaning that to work on a project using Hadoop in Renku,
all the configuration has to be done manually by the user. This includes
installing the softwares for all services, configuring them and
connecting them to their back-end (on the Hadoop cluster). This is
problematic for a number of reasons. First, this is messy as all the
configuration has to be done directly in the Dockerfile of the project.
Hence, there is no separation between the project's code and its setup.
This means that not only all people working on the project have to use
the same back-end but also that a person working with multiple Hadoop
projects has to duplicate the configuration across all of them. This
also comes with a severe security flaw, by sharing the project the user
shares also the resources he or she used in the project. Even if the
cluster is secure, revealing the addresses of the cluster publicly is
never a good idea as it exposes the cluster to attacks (e.g. DDoS).
Secondly, installing and setting up the local machine for Hadoop with
the back-end is not a trivial task. Most of the work will be common to
all projects and thus easily automated. But done by hand this process
takes time and involves a lot of transversal knowledge. In fact, chances
are that without explicit support for Hadoop in Renku, hardly anybody
will take the effort to use Renku with Hadoop. And finally, installing
all the softwares in the Dockerfile will make the creation of the
environment significantly slower than if it was already installed in the
Docker image.

To illustrate this current state in Renku, we've added ![an example
repository](./hadoop-project-without-template).

# Hadoop in Renku - Using our template

We show here our template in action. It comes in the form of a Docker image [available here](https://hub.docker.com/repository/docker/renkuhadoop/renkulab-py-hadoop). The only two components required for a working Hadoop project are to use the template and to have the cluster set up in Gitlab as shown below (check the [user guide](./hadoop-template) of the template for more information):

![](./demo-screenshots/demo-backend-conf.png)

The Dockerfile of the project simply use our Docker image:
![](./demo-screenshots/demo-dockerfile.png)

Note: at line 6 of the Dockerfile we just give a custom URL for the renku-env so that we can store the backend in a private repository, again check the user guide for more information.


Then we can create an environment and start coding:

![](./demo-screenshots/demo1.png)

![](./demo-screenshots/demo2.png)

![](./demo-screenshots/demo3.png)

<!---
References:
https://github.com/jupyter-incubator/sparkmagic/issues/527#issuecomment-492015968
https://blog.chezo.uno/livy-jupyter-notebook-sparkmagic-powerful-easy-notebook-for-data-scientist-a8b72345ea2d
https://docs.cloudera.com/HDPDocuments/HDP2/HDP-2.6.5/bk_command-line-installation/content/installing_ranger_plugins.html
https://docs.cloudera.com/HDPDocuments/HDP2/HDP-2.6.5/bk_security/content/ranger_console_navigation.html

Documentation for the project (our documentation for deployments, design
of Hadoop setup in Renku, etc.):
[[https://github.com/jjjules/renku-hadoop]{.ul}](https://github.com/JulesssG/renku-hadoop)

Apache website:
[[https://www.apache.org/]{.ul}](https://www.apache.org/)

Hadoop description:
[[https://www.lebigdata.fr/hadoop]{.ul}](https://www.lebigdata.fr/hadoop),
[[https://searchdatamanagement.techtarget.com/definition/Hadoop]{.ul}](https://searchdatamanagement.techtarget.com/definition/Hadoop)

What is Spark?:
[[https://www.infoworld.com/article/3236869/what-is-apache-spark-the-big-data-platform-that-crushed-hadoop.html]{.ul}](https://www.infoworld.com/article/3236869/what-is-apache-spark-the-big-data-platform-that-crushed-hadoop.html)

Kubernetes overview:
[[https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/]{.ul}](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/)

Helm: [[https://helm.sh/]{.ul}](https://helm.sh/)

Swiss Data Science Center:
[[https://datascience.ch/]{.ul}](https://datascience.ch/renku/)

Renku:
[[https://datascience.ch/renku/]{.ul}](https://datascience.ch/renku/)

Renku source code:
[[https://github.com/SwissDataScienceCenter/renku]{.ul}](https://github.com/SwissDataScienceCenter/renku)

Renku documentation:
[[https://renku.readthedocs.io/en/latest/introduction/why.html]{.ul}](https://renku.readthedocs.io/en/latest/introduction/why.html)

Caveats of using an external Gitlab with Renku:
[[https://renku.readthedocs.io/en/latest/developer/example-configurations/gitlab.html?\#caveats]{.ul}](https://renku.readthedocs.io/en/latest/developer/example-configurations/gitlab.html?#caveats)

Public Renku deployment:
[[https://renkulab.io]{.ul}](https://renkulab.io)

Public Renku deployment's Gitlab:
[[https://renkulab.io/gitlab]{.ul}](https://renkulab.io)

Official documentation for Renku's deployment:
[[https://renku.readthedocs.io/en/latest/admin/index.html]{.ul}](https://renku.readthedocs.io/en/latest/admin/index.html)

Hadoop Docker image:
[[https://hub.docker.com/r/renkubigdata/renkulab-py-bigdata]{.ul}](https://hub.docker.com/r/renkubigdata/renkulab-py-bigdata)

Thread discussing free access to Ambari:
[[https://community.cloudera.com/t5/Support-Questions/How-do-I-download-the-latest-version-of-Ambari-and-HDP/m-p/299115/highlight/true\#M219531]{.ul}](https://community.cloudera.com/t5/Support-Questions/How-do-I-download-the-latest-version-of-Ambari-and-HDP/m-p/299115/highlight/true#M219531)

Ambari:
[[https://www.cloudera.com/products/open-source/apache-hadoop/apache-ambari.html]{.ul}](https://www.cloudera.com/products/open-source/apache-hadoop/apache-ambari.html)

Steven Matison's information (author of MOSGA):
[[https://ds-steven-matison.github.io/]{.ul}](https://ds-steven-matison.github.io/)

MOSGA repositories:
[[http://makeopensourcegreatagain.com/]{.ul}](http://makeopensourcegreatagain.com/)

Cloudera's documentation for Hadoop deployment:
[[https://docs.cloudera.com/HDPDocuments/Ambari-2.7.4.0/bk_ambari-installation/content/ch_Getting_Ready.html]{.ul}](https://docs.cloudera.com/HDPDocuments/Ambari-2.7.4.0/bk_ambari-installation/content/ch_Getting_Ready.html)

Documentation for IPython's startup script:
[[https://ipython.readthedocs.io/en/stable/interactive/tutorial.html?\#startup-files]{.ul}](https://ipython.readthedocs.io/en/stable/interactive/tutorial.html?#startup-files)

Apache Knox documentation:
[[https://www.cloudera.com/products/open-source/apache-hadoop/apache-knox.html]{.ul}](https://www.cloudera.com/products/open-source/apache-hadoop/apache-knox.html)

Apache Ranger:
[[https://www.cloudera.com/products/open-source/apache-hadoop/apache-ranger.html]{.ul}](https://www.cloudera.com/products/open-source/apache-hadoop/apache-ranger.html)

Difference between Apache Knox and Ranger:
[[https://community.cloudera.com/t5/Support-Questions/whats-the-difference-between-Ranger-and-Knox/td-p/159565]{.ul}](https://community.cloudera.com/t5/Support-Questions/whats-the-difference-between-Ranger-and-Knox/td-p/159565)

Setting up a KDC for Kerberos:
[[https://godatadriven.com/blog/kerberos-basics-and-installing-a-kdc/]{.ul}](https://godatadriven.com/blog/kerberos-basics-and-installing-a-kdc/)

How does Kerberos works?:
[[https://stealthbits.com/blog/what-is-kerberos/]{.ul}](https://stealthbits.com/blog/what-is-kerberos/)
-->
