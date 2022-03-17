.PHONY: all
all: malvm

.PHONY: malvm
malvm:
	rm -rf dist/malvm
	mkdir -p dist/malvm/packages
	cp malvm/*.ps1 dist/malvm
	cp -R packages/ghidra.vminit dist/malvm/packages
	cd dist && zip -r malvm.zip malvm

.PHONY: clean
clean:
	rm -rf dist
