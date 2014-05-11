BASE_DIR=$(shell pwd)
CABAL_SANDBOX=$(BASE_DIR)/platform/geoindex
PREFIX=

default: build

#Default
.PHONY build: tags
	-@rm -r bin BUILD
	@mkdir -p BUILD bin
	@cp -r src/* BUILD
	cd BUILD && ghc --make Main-Index && mv Main-Index ../bin/geo-index 
	cd BUILD && ghc --make Main-Search && mv Main-Search ../bin/geo-search 
	cd BUILD && ghc --make Main-Server && mv Main-Server ../bin/geo-server 

install: build

tags:
	@hasktags -c src/

cleanMacFiles:
	-@find . -name '._*' -exec rm {} \;
	-@find . -name '.hdevtools.sock' -exec rm {} \;

cleanPlatform: clean cleanMacFiles
	-@rm cabal.sandbox.config
	-@rm -r platform

clean:
	-@rm $(BASE_DIR)/tags
	-@rm -r $(BASE_DIR)/dist
	-@rm -r $(BASE_DIR)/BUILD
	-@rm -r $(BASE_DIR)/bin
	
kill:
	killall Geo-Index
	killall Geo-Search

generate-protocol-buffers:
	cd $(BASE_DIR)/etc && hprotoc --include_imports --haskell_out=$(BASE_DIR)/src $(BASE_DIR)/etc/indexformat.proto

clean-generated-protocol-buffers:
	@rm -r $(BASE_DIR)/src/PB

cabal2nix: 
	cabal2nix --sha256=null GeoIndex.cabal > ~/.nixpkgs/haskell/geo-index-cabal2.nix

# Wrap Cabal Commands ############################################
cabal-build: tags 
	cabal configure
	cabal build

cabal-install: tags
	cabal install

cabal-prerequisites-init:
	cabal install hprotoc

cabal-sandbox-init:
	cabal sandbox init --sandbox $(CABAL_SANDBOX)
	cabal install --only-dependencies --force-reinstalls

cabal-install-deps:
	cabal install --only-dependencies --force-reinstalls

cabal-docs:
	cabal haddock --executables --hyperlink-source

cabal-ghci-index:
	cabal repl src/Main-Index.hs

cabal-ghci-search:
	cabal repl src/Main-Search.hs
###################################################################
