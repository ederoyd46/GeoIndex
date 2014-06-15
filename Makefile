BASE_DIR=$(shell pwd)
CABAL_SANDBOX=$(BASE_DIR)/platform/geoindex
GHC_FLAGS=-O2 -rtsopts

# GHC Build #################################################################################

default: build

clean:
	-@rm -r $(BASE_DIR)/bin $(BASE_DIR)/BUILD

init: tags
	@mkdir -p $(BASE_DIR)/BUILD $(BASE_DIR)/bin
	@cp -r src/* $(BASE_DIR)/BUILD

build-index: init
	@cd $(BASE_DIR)/BUILD && ghc --make Main-Index $(GHC_FLAGS) && mv Main-Index $(BASE_DIR)/bin/geo-index 

build-search: init
	@cd $(BASE_DIR)/BUILD && ghc --make Main-Search $(GHC_FLAGS) && mv Main-Search $(BASE_DIR)/bin/geo-search 
	
build-server: init
	@cd $(BASE_DIR)/BUILD && ghc --make Main-Server $(GHC_FLAGS) && mv Main-Server $(BASE_DIR)/bin/geo-server 

build: build-index build-search build-server

tags:
	@hasktags -c src/

cleanMacFiles:
	-@find . -name '._*' -exec rm {} \;
	-@find . -name '.hdevtools.sock' -exec rm {} \;

cleanPlatform: clean cleanMacFiles
	-@rm $(BASE_DIR)/tags
	-@rm -r $(BASE_DIR)/dist
	-@rm cabal.sandbox.config
	-@rm -r platform
	
kill:
	killall Geo-Index
	killall Geo-Search
	killall Geo-Server

generate-protocol-buffers:
	@cd $(BASE_DIR)/etc && hprotoc --include_imports --haskell_out=$(BASE_DIR)/src $(BASE_DIR)/etc/indexformat.proto

clean-generated-protocol-buffers:
	@rm -r $(BASE_DIR)/src/PB

cabal2nix: 
	@cabal2nix --sha256=null GeoIndex.cabal > ~/.nixpkgs/haskell/geo-index-cabal2.nix

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
