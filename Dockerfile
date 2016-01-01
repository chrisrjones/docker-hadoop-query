# Hadoop/HBase/Hive in Docker

FROM anapsix/docker-oracle-java8

# environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HBASE_VERSION 1.1.2
ENV HIVE_VERSION 1.2.1
ENV HADOOP_VERSION 2.6.3

#RUN echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

RUN	\

	# make sure the package repository is up to date
	#sed 's/main$/main universe/' -i /etc/apt/sources.list && \
	#apt-get update && \

	# Install build requirements
	apt-get install -y curl && \

	# clean up
	apt-get autoremove -y && apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/*

RUN \

	# install hbase
	mkdir -p /opt/downloads && cd /opt/downloads && curl -SsfLO "http://archive.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz" && \
	cd /opt && tar xvfz /opt/downloads/hbase-$HBASE_VERSION-bin.tar.gz && \
	rm -f /opt/downloads/hbase-$HBASE_VERSION-bin.tar.gz && \
	mv /opt/hbase-$HBASE_VERSION /opt/hbase && \
	# Data will go here (see hbase-site.xml)
	mkdir -p /data/hbase /opt/hbase/logs

RUN \
	
	# install hive
	mkdir -p /opt/downloads && cd /opt/downloads && curl -SsfLO "http://apache.claz.org/hive/stable/apache-hive-$HIVE_VERSION-bin.tar.gz" && \
	cd /opt && tar xvfz /opt/downloads/apache-hive-$HIVE_VERSION-bin.tar.gz && \
	rm -f /opt/downloads/apache-hive-$HIVE_VERSION-bin.tar.gz && \
	mv /opt/apache-hive-$HIVE_VERSION-bin /opt/hive && \
	mv /opt/hive/conf/hive-default.xml.template /opt/hive/conf/hive-default.xml && \
	mkdir -p /data/hive && \
	sed -i 's|/user/hive/warehouse|/data/hive|' /opt/hive/conf/hive-default.xml

RUN \
	
	# install hadoop
	mkdir -p /opt/downloads && cd /opt/downloads && curl -SsfLO "http://www.eu.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" && \
	cd /opt && tar xvfz /opt/downloads/hadoop-$HADOOP_VERSION.tar.gz && \
	rm -f /opt/downloads/hadoop-$HADOOP_VERSION.tar.gz && \
	mv /opt/hadoop-$HADOOP_VERSION /opt/hadoop

ENV HBASE_HOME /opt/hbase
ENV HIVE_HOME /opt/hive
ENV HADOOP_HOME /opt/hadoop
ENV PATH /opt:/opt/hbase/bin:/opt/hive/bin:/opt/hadoop/bin:$PATH

RUN \
	
	# support hive queries over hbase
	mkdir $HIVE_HOME/auxlib && \
	ln -s $HBASE_HOME/lib/hbase-client-1.1.2.jar $HIVE_HOME/auxlib && \
	ln -s $HBASE_HOME/lib/hbase-hadoop-compat-1.1.2.jar $HIVE_HOME/auxlib && \
	ln -s $HBASE_HOME/lib/hbase-server-1.1.2.jar $HIVE_HOME/auxlib && \
	ln -s $HBASE_HOME/lib/htrace-core-3.1.0-incubating.jar $HIVE_HOME/auxlib && \
	ln -s $HBASE_HOME/lib/netty-all-4.0.23.Final.jar $HIVE_HOME/auxlib && \
	ln -s $HBASE_HOME/lib/guava-12.0.1.jar $HIVE_HOME/auxlib && \
	ln -s $HBASE_HOME/lib/hbase-common-1.1.2.jar $HIVE_HOME/auxlib && \
	ln -s $HBASE_HOME/lib/hbase-protocol-1.1.2.jar $HIVE_HOME/auxlib && \
	ln -s $HBASE_HOME/lib/metrics-core-2.2.0.jar $HIVE_HOME/auxlib && \
	ln -s $HBASE_HOME/lib/zookeeper-3.4.6.jar $HIVE_HOME/auxlib


ADD ./hbase-site.xml /opt/hbase/conf/hbase-site.xml
ADD ./docker-init /opt/docker-init

# Rest API
EXPOSE 8080
# Thrift API
EXPOSE 9090
# Thrift Web UI
EXPOSE 9095
# HBase's zookeeper - used to find servers
EXPOSE 2181
## HBase Master API port ??
#EXPOSE 16000
# HBase Master web UI at :15010/master-status;  ZK at :16010/zk.jsp
EXPOSE 16010
# Region server API port
EXPOSE 16020
# HBase Region server web UI at :16030/rs-status
EXPOSE 16030

CMD ["/opt/docker-init"]

