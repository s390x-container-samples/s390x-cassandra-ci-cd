# Base image
FROM cassandra-s390


# The author
LABEL maintainer="Sarah Julia Kriesch <sarah.kriesch@ibm.com>"

# Installing dependencies for the Cassandra perl plugin
RUN apt-get update && apt-get install -y \
    perl \
    perl-base \
    libimage-magick-perl     
# Execute test script 
WORKDIR /bin
COPY cassandra_check.pl /bin/cassandra_check.pl

ENTRYPOINT ["perl", "cassandra_check.pl"]

# Clean up source dir and unused packages
RUN apt-get remove -y \
    perl \
    libimage-magick-perl\
    perl-base  \
&& apt autoremove -y \
&& apt-get clean && rm -rf /var/lib/apt/lists/*
