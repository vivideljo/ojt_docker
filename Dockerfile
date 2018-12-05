FROM centos:7.4.1708

MAINTAINER Vivideljo vivideljo@gmail.com

##### initialize #####

RUN yum clean all \
&& yum -y update \
&& yum repolist \
&& yum -y reinstall glibc-common 

RUN yum -y install gcc cpp gcc-c++ compat-gcc-34 gcc-gfortran flex \
&& yum -y install libjepg-devel libpng-devel freetype-devel \
&& yum -y install gd-devel libtermcap-devel ncurses-devel libxml2 \
&& yum -y install libxml2-devel libevent libevent-devel libtool \
&& yum -y install pcre-devel bzip2 bzip2-devel gmp gmp-devel wget \
&& yum -y install openssl openssl-devel mod_ssl \
&& yum -y install subversion subversion-devel \
&& yum -y install git \
&& yum -y install yum clean all


##### user & group add ##### 

RUN mkdir /home1 \
&& useradd -m -d /home1/irteam irteam \
&& useradd -m -d /home1/irteamsu irteamsu 

USER irteam
RUN mkdir -p /home1/irteam/apps

##### JAVA Environment #####

USER irteam
WORKDIR /home1/irteam/apps

RUN wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.tar.gz \
&& tar -zxvf jdk-8u191-linux-x64.tar.gz \
&& rm -r jdk-8u191-linux-x64.tar.gz \ 
&& ln -s jdk1.8.0_191 jdk

RUN echo "export APP_HOME=/home1/irteam" >> /home1/irteam/.bashrc \
&& echo "export JAVA_HOME=${APP_HOME}/apps/jdk" >> /home1/irteam/.bashrc \
&& echo "export CATALINA_HOME=${APP_HOME}/apps/tomcat" >> /home1/irteam/.bashrc \
&& source /home1/irteam/.bashrc

##### apache install #####

USER irteam
WORKDIR /home1/irteam/apps

RUN wget http://mirror.apache-kr.org//httpd/httpd-2.4.37.tar.gz \
&& tar -xvzf httpd-2.4.37.tar.gz \
&& rm -r httpd-2.4.37.tar.gz

WORKDIR /home1/irteam/apps/httpd-2.4.37/srclib
RUN wget http://apache.mirror.cdnetworks.com//apr/apr-1.6.5.tar.gz \
&& wget http://apache.mirror.cdnetworks.com//apr/apr-util-1.6.1.tar.gz \
&& wget http://apache.mirror.cdnetworks.com//apr/apr-iconv-1.2.2.tar.gz

RUN tar xvzf apr-1.6.5.tar.gz \
&& rm -r apr-1.6.5.tar.gz \
&& tar xvzf apr-util-1.6.1.tar.gz \
&& rm -r apr-util-1.6.1.tar.gz \
&& tar xvzf apr-iconv-1.2.2.tar.gz \
&& rm -r apr-iconv-1.2.2.tar.gz

RUN ln -s apr-1.6.5 apr \
&& ln -s apr-iconv-1.2.2 apr-iconv \
&& ln -s apr-util-1.6.1 apr-util

WORKDIR /home1/irteam/apps/httpd-2.4.37
RUN ./configure --prefix=/home1/irteam/apps/apache-2.4.37 --with-included-apr --enable-ssl=yes \
&& make \
&& make install

WORKDIR /home1/irteam/apps
RUN ln -s apache-2.4.37 apache

#USER irteamsu
#WORKDIR /home1/irteam/apps/apache/bin
#RUN sudo chown root:irteam httpd \
#&& sudo chmod 4755 httpd

USER irteam
WORKDIR /home1/irteam/apps
RUN echo "export APACHE_HTTP_HOME=${APP_HOME}/apps/httpd" >> /home1/irteam/.bashrc 
RUN echo "export PATH=${APACHE_HTTP_HOME}/bin:$PATH" >> /home1/irteam/.bashrc \
&& source /home1/irteam/.bashrc


##### tomcat install #####

USER irteam
WORKDIR /home1/irteam/apps
RUN wget http://apache.mirror.cdnetworks.com/tomcat/tomcat-8/v8.5.35/bin/apache-tomcat-8.5.35.tar.gz \
&& tar xvzf apache-tomcat-8.5.35.tar.gz \
&& rm -r apache-tomcat-8.5.35.tar.gz \
&& ln -s apache-tomcat-8.5.35 tomcat


##### mod_jk install #####

USER irteam
WORKDIR /home1/irteam/apps

RUN wget http://mirror.apache-kr.org/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.46-src.tar.gz \
&& tar xvzf tomcat-connectors-1.2.46-src.tar.gz \
&& rm -r tomcat-connectors-1.2.46-src.tar.gz

WORKDIR /home1/irteam/apps/tomcat-connectors-1.2.46-src/native
RUN ./configure --with-apxs=/home1/irteam/apps/apache/bin/apxs \
&& make 

WORKDIR /home1/irteam/apps/tomcat-connectors-1.2.46-src/native/apache-2.0
RUN cp mod_jk.so /home1/irteam/apps/apache/modules \
&& make \
&& make install


##### python3.5.6 install #####

USER irteam
WORKDIR /home1/irteam/apps
RUN wget https://www.python.org/ftp/python/3.5.6/Python-3.5.6.tgz \
&& tar -zxvf Python-3.5.6.tgz \
&& rm -r Python-3.5.6.tgz

WORKDIR /home1/irteam/apps/Python-3.5.6 
RUN ./configure --prefix=/home1/irteam/apps/Python-3.5.6 \
&& make \
&& make install

WORKDIR /home1/irteam/apps
RUN ln -s Python-3.6.5 python3
RUN echo "export PATH=/home1/irteam/apps/python3/bin:/home1/irteam/apps/python3/bin:$PATH" >> /home1/irteam/.bashrc \
&& source /home1/irteam/.bashrc 


##### pip, django install #####

WORKDIR /home1/irteam/apps
#RUN /home1/irteam/apps/Python-3.5.6/bin/pip3 install --upgrade pip \
RUN /home1/irteam/apps/Python-3.5.6/bin/pip3 install django==1.11 \
&& /home1/irteam/apps/Python-3.5.6/bin/pip3 install pymysql 



