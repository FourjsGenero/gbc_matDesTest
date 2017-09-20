
export GBCPROJECT=../gbc-current-project
export CUSTOMNAME=$(shell basename $(PWD))
DISTBIN=../distbin
GBCBASE=..
FILES=$(shell find . -type f)

all: $(DISTBIN)/$(CUSTOMNAME).build

# Create a symbolic link to our custom gbc files
$(GBCPROJECT)/customization/$(CUSTOMNAME): 
	ln -s $(GBCBASE)/$(CUSTOMNAME) $@

# Build our custom gbc
$(DISTBIN)/$(CUSTOMNAME).build: $(GBCPROJECT)/customization/$(CUSTOMNAME) $(FILES)
	cd $(GBCPROJECT) && grunt --customization=customization/$(CUSTOMNAME) | tee $(DISTBIN)/$(CUSTOMNAME).build

$(DISTBIN): 
	mkdir $(DISTBIN)

# Package our custom gbc
$(DISTBIN)/$(CUSTOMNAME).zip: $(DISTBIN) $(GBCPROJECT)/dist/customization/$(CUSTOMNAME)
	cd $(GBCPROJECT)/dist/customization/$(CUSTOMNAME) && zip -r ../../../$@ *

dev:
	cd $(GBCPROJECT) && grunt --customization=customization/$(CUSTOMNAME) dev

