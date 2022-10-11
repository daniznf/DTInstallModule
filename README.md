# Daniele's Tools Install Module
DTInstallModule<br>
Installs powershell module in modules directory.<br>
Copyright (C) 2022 daniznf

### Description
This script installs module(s) found in containing directory, or parent directory, by copying necessary files into modules directory.<br>
The script is intended to be run inside the directory of the module to install, but can also be run from anywhere passing necessary parameters.

### Install
Copy this script inside the directory of the module to install, or inside a directory named DTInstallModule.<br>
Either will work:
- C:\my_module\DTInstallModule.ps1
- C:\my_module\DTInstallModule\DTInstallModule.ps1

### Run
Right-click or run from powershell.<br>
Installs module contained in local or parent directory:
```
PS C:\> .\DTInstallModule.ps1
```

Installs module contained in C:\my_module
```
PS C:\> .\DTInstallModule.ps1 -ModuleDir C:\my_module
```
