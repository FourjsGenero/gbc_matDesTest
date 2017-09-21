# gbc_matDesTest

Simple Genero 3.10 Application to test custom GBC build

Files / Folders in the repo:
* etc - .4st / .4ad
* gas - .xcf file
* gbc_matDesTest.4pw - Genero Project
* mygbc - Source for custom GBC
* pics - Images
* README.md - This readme
* src - Genero demo source
* src/lib - Genero library source

Files / Folders built by repo:
* bin - Genero object files
* distbin - built packages for application ( .gar ) and gbc ( .zip )

You need to create:
* gbc-current-project -> /opt/fourjs/gbc-1.00.39-project/ - Symbolic Link to GBC Project

### Genero Studio Setup

Special Build rule: Language 'GBC' - Library / Link :
Command Line:
```
bash -c "cd $(SourceDir) ; make"
```
Output Files:
```
$(TargetDir)/$(BinaryName).build
```

Special Package rule: Platform 'GBC':
Command Line:
```
bash -c "cd $(RootDir) ; zip -r $(DistDir)/$(PackageName) *"
```
Output Files:
```
$(DistDir)/$(PackageName)
```


