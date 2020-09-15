########## Multi-Arch Dockerfile for Cassandra version 3.11.6 #########
#
# This Dockerfile builds a basic installation of Cassandra.
#
# Apache Cassandra is an open source distributed database management system designed
# to handle large amounts of data across many commodity servers, providing high
# availability with no single point of failure
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To Start Cassandra Server create a container from the image created from Dockerfile
# docker run --name <container_name> -p <port_number>:7000 -p <port_number>:7001 -p <port_number>:7199 -p <port_number>:9042 -p <port_number>:9160 -d <image_name>
#
#################################################################################

# Base image
FROM adoptopenjdk:8-jdk-hotspot


ARG CASSANDRA_VERSION=3.11.6

# The author
LABEL maintainer="Sarah Julia Kriesch <sarah.kriesch@ibm.com"

# Set environment variables
ENV SOURCE_ROOT=/root

WORKDIR $SOURCE_ROOT

RUN unset JAVA_TOOL_OPTIONS
ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8 -XX:+UnlockExperimentalVMOptions"
#ENV JVM_OPTS='-XX:+UnlockExperimentalVMOptions'
ENV ANT_OPTS="-Xms4G -Xmx4G"

# Installing dependencies for Cassandra
RUN apt-get update && apt-get install -y \
    automake \
    ant      \
    junit    \
    ant-optional \
    autoconf\
    git \
    g++ \
    libx11-dev \
    libxt-dev  \
    libtool \
    locales-all \
    make  \
    patch  \
    pkg-config \
    python \
    texinfo \
    tar \
    wget \
    unzip  \
    perl \
    perl-base \
    libimage-magick-perl \
# Build JNA
&& cd $SOURCE_ROOT \
&& git clone https://github.com/java-native-access/jna.git \
&& cd jna \
&& git checkout 4.2.2 \
&& ant native jar \
# Build and install Apache Cassandra
&& cd $SOURCE_ROOT \
&& git clone https://github.com/apache/cassandra.git \
&& cd cassandra \
&& git checkout cassandra-${CASSANDRA_VERSION} \
&& sed -i ' s/Xss256k/Xss32m/' build.xml conf/jvm.options \
&& ant \
&& rm lib/snappy-java-1.1.1.7.jar \
&& wget -O lib/snappy-java-1.1.2.6.jar https://repo1.maven.org/maven2/org/xerial/snappy/snappy-java/1.1.2.6/snappy-java-1.1.2.6.jar \
&& rm lib/jna-4.2.2.jar \
&& cd $SOURCE_ROOT \
&& cp $SOURCE_ROOT/jna/build/jna.jar $SOURCE_ROOT/cassandra/lib/jna-4.2.2.jar \
&& ln -s $SOURCE_ROOT/cassandra /usr/share/cassandra \
&& rm -rf  $SOURCE_ROOT/jna $SOURCE_ROOT/*.tar.gz  \
&& rm -rf /usr/share/cassandra/test \

# Clean up source dir and unused packages/libraries
&& apt-get remove -y \
    automake \
    autoconf\
    make  \
    patch  \
    pkg-config \
    wget \
    unzip     \
    ant    \
    junit    \
    ant-optional \
    git   \
&& apt autoremove -y \
&& apt-get clean && rm -rf /var/lib/apt/lists/*


# Expose Ports

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160

# Define mount points for conf files & data.
VOLUME ["/usr/share/cassandra/data", "/usr/share/cassandra/conf"]

# Set Path
ENV PATH $PATH:/usr/share/cassandra/bin

# Start Cassandra server
CMD ["cassandra", "-Rf"]

# Execute test script 
WORKDIR /bin
COPY plugins/cassandra_check.pl /bin/cassandra_check.pl

ENTRYPOINT ["perl", "cassandra_check.pl"]
