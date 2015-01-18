FROM haskell:7.8
MAINTAINER Matthew Brown <matt@ederoyd.co.uk>
ENV DEBIAN_FRONTEND noninteractive

ADD . /GeoIndex

RUN cabal update && \
 	cabal install cabal-install cabal

WORKDIR /GeoIndex
RUN cabal install

ENV PATH $PATH:/root/.cabal/bin

RUN mkdir -p /data && \ 
	cp /GeoIndex/test-data/geodata_uk.idx.xz /data/ && \
	xz --decompress /data/geodata_uk.idx.xz

ENTRYPOINT ["geo-search", "/data/geodata_uk.idx"]
