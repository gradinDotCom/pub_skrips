# PowerShell Functions

## New-DirectoryStructure

This is a simple PowerShell script to generate an organized directory structure. The example provided covers a large effort, "Brazenthrone" which initially spawned my interest in creating this (not to mention the other Patreon collections I have that need desparate organization too!).

`New-DirectoryStructure.ps1 -filename .\brazenthrone_dir.txt -target "C:\maps\Matt Milby\Brazenthrone"`

_where_

`brazenthrone_dir.txt` contains:
- directory/folder names (1 per line)
- a special line prefixed with `sub:` and followed by a comma-delimited list of _standard_ subdirectories
    - `sub/sub` works as intended to generate directories _beneath_ the subdirectory desired

The `target` specified in the parameters will be created if it does not exist (I think).

## Results

C:\maps\Matt Milby\Brazenthrone

```

1 - The Old Palace (Ruins)
  1-INCH-GRID
  PRINT
  VTT
     Stacked
2 - The Old Quarter (Ruins)
  1-INCH-GRID
  PRINT
  VTT
     Stacked

```

..._etc_...

## Unzip-Files

Poorly named, but valuable script to unzip 'Cze and Peku' archives into a very manageable directory repository. It takes a source directory or filename, reads the contents, and places the cleaned output into a new target. This is a really touchy process and error prone as anyone who has tried to treat filename and directory hierarchies as a database can attest. That said, here are the known issues:

- Beach Kraken has no subdirectories and cannot be processed
- Chaos at the Coral Court Adventure is filled with ZIPs and cannot be processed
- Colossus Port is missing a space (Colossus Port \[70x108\]-...) and would need to renamed to get picked up, but...
- Colossus Port is missing any Gridded/Gridless subdirectories and (probably) cannot be processed.

### Clean means

- Windows users no longer have to delete MAC directories
- Top-level directory for each map strips off the reward level details

`unzip-files.ps1 -Source c:\Downloads\czepeku -Target c:\maps`

This will take several minutes to process a directory of say, 100 zips. As mentioned above, you may specify a directory or a file (ZIP) as your `-Source` property. The script outputs each file it expands.

![Source Archives](https://showntell.z20.web.core.windows.net/images/src.png)
![Target Directory](https://showntell.z20.web.core.windows.net/images/tgt.png)

## New-ContactSheet
This follows on the heels of 'unzip-files' above and simply adds a "contact sheet" as an index to understand what you have. It will create (by default) a new folder called "\_Index" in your scanned directory to place thumbnails of what I *think* are representative of the directories I find. The filtering logic prioritizes names like "Original Day" or some variation on that theme. It also constructs a name which represents the folder the image comes from, and the child folder if applicable (e.g. Ages of the Vale Pt.1 [27x39]-03 Tavern.jpg comes from _Ages of the Vale Pt.1\03 Tavern\GL\_Tavern\_Indoors\_NewBeginnings\_Day.jpg_).

`New-ContactSheet.ps1 -ScanPath "c:\Downloads\czepeku"`

![Contact Sheet](https://showntell.z20.web.core.windows.net/images/sheet.png)
