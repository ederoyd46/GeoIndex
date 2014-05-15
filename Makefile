BASE_DIR=$(shell pwd)
CABAL_SANDBOX=$(BASE_DIR)/platform/geoindex

default: cabal-build

#Default
ghc-build-clean:
	-@rm -r $(BASE_DIR)/$(PREFIX)/bin $(BASE_DIR)/$(PREFIX)/BUILD

ghc-build-init: ghc-build-clean tags
	@mkdir -p $(BASE_DIR)/$(PREFIX)/BUILD $(BASE_DIR)/$(PREFIX)/bin
	@cp -r src/* $(BASE_DIR)/$(PREFIX)/BUILD

ghc-build-index: ghc-build-init
	@cd $(BASE_DIR)/$(PREFIX)/BUILD && ghc --make Main-Index && mv Main-Index $(BASE_DIR)/$(PREFIX)/bin/geo-index 

ghc-build-search: ghc-build-init
	@cd $(BASE_DIR)/$(PREFIX)/BUILD && ghc --make Main-Search && mv Main-Search $(BASE_DIR)/$(PREFIX)/bin/geo-search 
	
ghc-build-server: ghc-build-init
	@cd $(BASE_DIR)/$(PREFIX)/BUILD && ghc --make Main-Server && mv Main-Server $(BASE_DIR)/$(PREFIX)/bin/geo-server 

ghc-build: ghc-build-index ghc-build-search ghc-build-server

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
	-@rm -r $(BASE_DIR)/$(PREFIX)/BUILD
	-@rm -r $(BASE_DIR)/$(PREFIX)/bin
	
kill:
	killall Geo-Index
	killall Geo-Search

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
