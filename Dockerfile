FROM haskell:7.10.2
MAINTAINER Matthew Brown <matt@ederoyd.co.uk>
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y xz-utils

ADD . /GeoIndex
WORKDIR /GeoIndex

RUN cabal update && \
 	cabal install cabal-install cabal

RUN cabal install

ENV PATH $PATH:/root/.cabal/bin

RUN mkdir -p /data && \
	cp /GeoIndex/test-data/geodata_*.idx.xz /data/ && \
	xz --decompress /data/geodata_*.idx.xz

ENTRYPOINT ["geo-search", "/data/geodata_uk.idx"]
