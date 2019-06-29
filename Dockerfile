FROM yonedakenji/centos_update:latest

MAINTAINER yonedakenji <yon_ken@yahoo.co.jp>

ARG PYTHON_VER=3.5.7
ARG SYSLOGNG_VER=3.22.1
ARG RUNIT_VER=2.1.2
ARG JDK_VER=1.8.0

WORKDIR /tmp

RUN curl -OL https://www.python.org/ftp/python/${PYTHON_VER}/Python-${PYTHON_VER}.tgz && \
    curl -OL http://smarden.org/runit/runit-${RUNIT_VER}.tar.gz && \
    curl -OL https://github.com/balabit/syslog-ng/archive/syslog-ng-${SYSLOGNG_VER}.zip

### runit needs these packages. ###
RUN rpm --rebuilddb && \
    yum install -y gcc.x86_64 make.x86_64 glibc-static.x86_64 \

### tomcat needs these packages. ###
    java-${JDK_VER}-openjdk-devel.x86_64 \

### base image provides with these services. ###
    openssh-server.x86_64 cronie.x86_64 logrotate.x86_64 \

### syslog-ng needs these packages. ###
    glib2-devel.x86_64 openssl-devel.x86_64 \

### mysql (5.6.19) needs this package. ###
    libaio.x86_64 hostname.x86_64 numactl-libs.x86_64 \

### install utilities. ###
#   sendmail.pl and mysql_install_db need perl.
    perl.x86_64 patch.x86_64 perl-Data-Dumper.x86_64 bc.x86_64 expect.x86_64

### install runit. ###
RUN mkdir /package && \
    chmod 1755 /package && \
    cd /package && \
    mv /tmp/runit-${RUNIT_VER}.tar.gz /package && \
    tar xvpf runit-${RUNIT_VER}.tar.gz && \
    rm runit-${RUNIT_VER}.tar.gz && \
    cd admin/runit-${RUNIT_VER} && \
    ./package/install && \
    ./package/install-man && \

### my_init requires python3. (to be precise Python 3.5.2) ###
    cd /tmp && \
    tar xfz Python-${PYTHON_VER}.tgz && \
    cd Python-${PYTHON_VER} && \
    ./configure --prefix=/usr/local && \
    make && \
    make install

### make syslog-ng. ###
RUN cd /tmp && \
    unzip syslog-ng-${SYSLOGNG_VER}.zip && \
    cd syslog-ng-${SYSLOGNG_VER} && \
    ./configure --prefix=/usr/local --enable-json=no && \
    make && \
    make install

### clean up ###
RUN yum clean all && \
    rm -rf /package/admin/runit/compile && \
    rm -rf /package/admin/runit/doc && \
    rm -rf /package/admin/runit/etc && \
    rm -rf /package/admin/runit/man && \
    rm -rf /package/admin/runit/package && \
    rm -rf /package/admin/runit/src && \
    rm -rf /tmp/*
