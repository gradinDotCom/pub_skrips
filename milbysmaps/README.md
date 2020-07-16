#Milby's Maps
[https://www.patreon.com/milbysmaps](Milby's Patreon)

This is a simple PowerShell script to generate an organized directory structure for fans of Mike Milby's fantastic illustrations. The example provided covers a large effort, "Brazenthrone" which initially spawned my interest in creating this (not to mention the other Patreon collections I have that need desparate organization too!).

`New-DirectoryStructure.ps1 -filename .\brazenthrone_dir.txt -target "C:\maps\Mike Milby\Brazenthrone"`

_where_

`brazenthrone_dir.txt` contains:
- directory/folder names (1 per line)
- a special line prefixed with `sub:` and followed by a comma-delimited list of _standard_ subdirectories
    - `sub/sub` works as intended to generate directories _beneath_ the subdirectory desired

The `target` specified in the parameters will be created if it does not exist (I think).