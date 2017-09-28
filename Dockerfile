FROM fpco/stack-build
LABEL author Matthew Brown <matt@ederoyd.co.uk>
ENV DEBIAN_FRONTEND noninteractive

ADD . /GeoIndex
WORKDIR /GeoIndex
RUN stack setup
RUN stack install

ENV PATH $PATH:/root/.local/bin

RUN mkdir -p /data && \
	cp /GeoIndex/test-data/geodata_*.idx.xz /data/ && \
	xz --decompress /data/geodata_*.idx.xz

ENTRYPOINT ["geo-search", "/data/geodata_uk.idx"]
