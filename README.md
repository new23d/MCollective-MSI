# MCollective-MSI


You could download a package I have compiled from the _release_ tab above, or build one yourself using instructions below.


## Usage


0. Configuration file usually at ```%ProgramData%\MCollective\etc\server.cfg```. It is autogenerated if not present.
0. Deploys _Facter CEF_. This is a Cache for Expensive Facts. Get's installed as a scheduled task, running every 10 minutes to save time consuming facts related to network interfaces on MS Windows in _facts.d_ .
0. _puppet_ and _service_ agents are included.
0. _facter_ facts plugin is included.


## Prerequisites


0. Puppet MSI from Puppet Labs installed. Tested with versions 3.3.2 and 3.4.3 . This setup [and the Windows Service] is configured to piggyback on the Gems and Ruby environment provided by the Puppet installation.


## Known Issues


0. If usage of _facter_ as a source of facts crashes with a debug message like ```in `rescue in block in get_fact' Failed to load facts: ThreadError: deadlock; recursive locking```, remove the ```%ProgramFiles(x86)%\Puppet Labs\Puppet\facter\lib\facter\processor.rb``` file.
0. If _mco puppet runonce_ fails rather too quickly, edit ```%ProgramFiles(x86)%\MCollective\plugins\mcollective\agent\puppet.rb:12``` to find the _puppet_ command at its absolute path as per your environment. Example, change ```"puppet agent"``` to ```"c:/program files (x86)/puppet labs/puppet/bin/puppet.bat agent"```.
0. The _Task Scheduler_ (```Schedule```) service must be running for the installation to succeed.


## Build Yourself


0. Install the WiX Toolset from https://wix.codeplex.com/releases/view/115492 .
0. Check out this code.
0. Extract the MCollective 2.5.1 tarball obtained from http://puppetlabs.com/misc/download-options into the _mco\_ directory.
0. Get best versions of _mcollective-puppet-agent_, _mcollective-puppet-common_, _mcollective-service-agent_, _mcollective-service-common_ and _mcollective-facter-facts_ RPMs from http://yum.puppetlabs.com/el/6/products/x86_64/ . Extract them and merge contents at _usr\libexec\mcollective\mcollective_ of the extract into the _mco\plugins\mcollective_ directory.
0. Change into the workspace directory: ```cd wks```
0. Set path to WiX binaries: ```set PATH="%ProgramFiles(x86)%\WiX Toolset v3.8\bin";%PATH%```
0. ```heat dir ..\mco -gg -sfrag -template fragment -ke -cg Tarball -dr ProgramFilesFolder_MCollective -srd -out files.wxs```
0. ```candle files.wxs ..\wxs\mcollective.wxs```
0. ```light -b ..\mco files.wixobj mcollective.wixobj -out ..\msi\mcollective-2.5.1002.msi```


## Versioning

Due to idiosyncrasies and limitations of the Windows Installer around upgrades, the version numbers here reflect the upstream MCollective major and minor version number accurately. The patch number is then first multiplied by 1000 and my own release number added afterwards. Therefore, 2.5.1002 here means 2.5.1 release 2.
