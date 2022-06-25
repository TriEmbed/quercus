### Build and other support tools

Todo: Get a project name!!! Then this and repo and the others
      can have be <name abbreviation>-tools. How about 
      "Free Bird" or FB? Or "Fast Free Bird" or FFB so folks
      will wonder what the extra F in front of FaceBook 
      stands for. :-)

This repo primarily holds scripts for automated installs of Espressif IDF, nvm/node/npm, project repositories as well as prerequisit packages

Initial support is for straight Linux with Windows WSL in the pipes. Windows support is expected to follow via Powershell.

There are subdirectories for each OS type plus a common directory for shared items such as default variable values and functions that can be used on multiple platforms. The common directory will develop as WSL support shapes up.

Each OS has an "installit" script for full installation and "cleanit" for removal of everything but OS packages (that can be removed with the "-total" option switch).
