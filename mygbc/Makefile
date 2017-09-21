
export GBCPROJECT=/opt/fourjs/gbc-current-project
export CUSTOMNAME=$(shell basename $(PWD))
GBCBASE=$(shell dirname $(PWD))
DISTBIN=$(GBCBASE)/distbin
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
$(DISTBIN)/$(CUSTOMNAME).zip: $(DISTBIN) $(DISTBIN)/$(CUSTOMNAME).build
	cd $(GBCPROJECT)/dist/customization/$(CUSTOMNAME) && zip -r $@ *

dev:
	cd $(GBCPROJECT) && grunt --customization=customization/$(CUSTOMNAME) dev

pack: $(DISTBIN)/$(CUSTOMNAME).zip
