Mopem is a Mono parallel environment manager, allowing the user to switch easily between different mono versions. Mopem can be used to install a new environment by tracking the proper branch in the mono repository, dependencies and downloading the needed source, compiling it and installing it in your ~/.mopem directory. It can then switch environments by changing environment variables and your path.

It also allows users to compile and install mono compatible projects from source and install them in a sandboxed mono environment.

When installing a target (mono, mono_addins, monodevelop, etc.), mopem will download the code to a directory in ~/.mopem/sources and compile the code from there. When installing mono, the binaries will be copied to a directory inside ~/.mopem/install. When installing any other target, the binaries will be installed in somewhere in ~/.mopem/install, depending on which mono version is currently being used.


##PREREQUISITES

You will need:
1. ruby 1.8.7 or better 
2. the versionomy ruby gem.

##SETUP

after cloning this project on your local machine, add this line to the end of your .bashrc file:

    [[ -s "[cloned repo location]/scripts/mopem" ]] && source "[cloned repo location]/scripts/mopem"

and change [cloned repo location] with the location where you cloned the repo.

##USAGE

To list all the available targets that can be installed:

    $ mopem list 

To install a target (mono, or any other target that shows up in the list above), type
    $ mopem install [target] [target_version]

For example, to install the latest mono from the 2.10 git branch:

    $ mopem install mono 2.10-HEAD

To install the 2.10.8 version of mono from the official tarball:

    $ mopem install mono 2.10.8

To install the latest mono from the HEAD of the master git branch:

    $ mopem install mono master-HEAD

To install gtk-sharp version 2.12.11. (Note: you must be using a mono runtime first with the use command. See below):

    $ mopem install gtk-sharp 2.12.11

To update your current 2.10-HEAD version of mono:

    $ mopem update 2.10-HEAD

To switch to a new mono environment, you will need the use command to specify which version of mono you want to switch to. Note that you will need to have installed that specific mono version first with the install command.

    $ mopem use 2.10-HEAD
    $ mopem use master-HEAD
    $ mopem use 2.10.8
