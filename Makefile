BASE_DIR=$(shell pwd)
CABAL_SANDBOX=$(BASE_DIR)/platform/geoindex

default: build

ghc-build: tags
	-@rm -r bin BUILD
	@mkdir -p BUILD bin
	@cp -r src/* BUILD
	cd BUILD && ghc --make Main-Index && mv Main-Index ../bin/geo-index 
	cd BUILD && ghc --make Main-Search && mv Main-Search ../bin/geo-search 
	cd BUILD && ghc --make Main-Server && mv Main-Server ../bin/geo-server 

#Default
build: tags 
	cabal configure
	cabal build

install: tags
	cabal install

prerequisites-init:
	cabal install hprotoc

sandbox-init:
	cabal sandbox init --sandbox $(CABAL_SANDBOX)
	cabal install --only-dependencies --force-reinstalls

install-deps:
	cabal install --only-dependencies --force-reinstalls

docs:
	cabal haddock --executables --hyperlink-source

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
	
kill:
	killall Geo-Index
	killall Geo-Search

ghci-index:
	cabal repl src/Main-Index.hs

ghci-search:
	cabal repl src/Main-Search.hs

generate-protocol-buffers:
	cd $(BASE_DIR)/etc && hprotoc --include_imports --haskell_out=$(BASE_DIR)/src $(BASE_DIR)/etc/indexformat.proto

clean-generated-protocol-buffers:
	@rm -r $(BASE_DIR)/src/PB

