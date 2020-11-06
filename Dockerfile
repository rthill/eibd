FROM debian:jessie-slim

LABEL maintainer="Emmanuel BRUNO <emmanuel.bruno@univ-tln.fr>"

#Adapted from https://github.com/TimWeyand/eibd/blob/master/Dockerfile

EXPOSE 6720
ARG GATEWAY_IP 

ENV KNXDIR /usr
ENV INSTALLDIR $KNXDIR/local
ENV SOURCEDIR  $KNXDIR/src
ENV LD_LIBRARY_PATH $INSTALLDIR/lib

WORKDIR $SOURCEDIR

RUN apt-get -qq update && \
	apt-get install -y --no-install-recommends build-essential gcc git rsync cmake make g++ binutils automake flex bison patch wget ca-certificates file && \
	rm -rf /var/lib/apt/lists/* &&  \
wget https://phoenixnap.dl.sourceforge.net/project/bcusdk/pthsem/pthsem_2.0.8.tar.gz -O pthsem_2.0.8.tar.gz &&\
	tar -xzf pthsem_2.0.8.tar.gz && \
	cd pthsem-2.0.8 && \
	./configure --prefix=$INSTALLDIR/ && make && make test && make install && \
wget https://phoenixnap.dl.sourceforge.net/project/linknx/linknx/linknx-0.0.1.32/linknx-0.0.1.32.tar.gz -O linknx-0.0.1.32.tar.gz && \
	tar -xzf linknx-0.0.1.32.tar.gz && \
	cd linknx-0.0.1.32 && ./configure --without-log4cpp --without-lua --prefix=$INSTALLDIR/ --with-pth=$INSTALLDIR/ && make && make install && \
wget https://phoenixnap.dl.sourceforge.net/project/bcusdk/bcusdk/bcusdk_0.0.5.tar.gz -O bcusdk_0.0.5.tar.gz && \
	tar -xzf bcusdk_0.0.5.tar.gz && \
	cd bcusdk-0.0.5 && ./configure --enable-onlyeibd --enable-eibnetiptunnel --enable-eibnetipserver --enable-ft12 --prefix=$INSTALLDIR/ --with-pth=$INSTALLDIR/ && make && make install && \
rm -rf $SOURCEDIR	

RUN groupadd -r eibd && useradd -r -g eibd eibd
USER eibd

ENTRYPOINT eibd -T -S -i ipt:${GATEWAY_IP}
