Mopem is a Mono parallel environment manager, allowing the user to switch easily between different mono versions. Mopem can be used to install a new environment by tracking the proper branch in the mono repository, dependencies and downloading the needed source, compiling it and installing it in /home. It can then switch environments by changing environment variables and path.

It also allows users to compile and install mono compatible projects from source and install them in a sandboxed mono version.

##PREREQUISITES

You will need ruby 1.8.7 or better and the versionomy gem.

##SETUP

after cloning this project on your local machine, add this line to the end of your .bashrc file:

    [[ -s "[cloned repo location]/scripts/mopem" ]] && source "[cloned repo location]/scripts/mopem"

and change [cloned repo location] with the location where you cloned the repo.

##USAGE

list all the available targets that can be installed
    $ mopem list 

install the latest in the 2.10 branch
    $ mopem install mono 2.10-HEAD

install the 2.10.5 version from 2.10.5
    $ mopem install mono 2.10.5

install the HEAD version in the master branch
    $ mopem install mono master-HEAD

install gtk-sharp version 2.12.11. Note: you must have selected a mono runtime first.
    $ mopem install gtk-sharp 2.12.11

update the branch
    $ mopem update 2.10-HEAD

switch to the selected environments by launching a new shell withing the existing one. I plan to replace the current shell at some point, but this isn't what it's doing at the moment.
    $ mopem use 2.10-HEAD
    $ mopem use master-HEAD
    $ mopem use 2.10.5
