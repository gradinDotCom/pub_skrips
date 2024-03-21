[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $Source,

    [Parameter()]
    [String]
    $Target
)

# Check if file (works with files with and without extension)
if ((Test-Path -Path $Source -PathType Leaf) -or (Test-Path -Path $Source -PathType Leaf)) {
    $Path = Get-ChildItem -Path $Source
} elseif (Test-Path -Path $Source -PathType Container) {
    $Path = Get-ChildItem -Path $Source -Filter *.zip
}

foreach ($file in $Path) {
    Write-Information "Processing $file"
    $split_FSItem = $file.BaseName -split "\W"
    $Filter = $split_FSItem[0] + "*"

    # change output path to a folder where you want the extracted
    # files to appear
    $OutPath = $Target

    # ensure the output folder exists
    $exists = Test-Path -Path $OutPath
    if ($exists -eq $false) {
        $null = New-Item -Path $OutPath -ItemType Directory -Force
    }

    # load ZIP methods
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    # open ZIP archive for reading
    $zip = [System.IO.Compression.ZipFile]::OpenRead($file.FullName)

    # find all files in ZIP that match the filter (i.e. file extension)
    $zip.Entries | 
    Where-Object { $_.FullName -like $Filter -and $_.FullName -notlike "*DS_Store" } |
    ForEach-Object {
        # extract the selected items from the ZIP archive
        # and copy them to the out folder
        Write-Information "#################"
        Write-Information "## $($_.FullName)"
        Write-Information "#################"
        if ($null = $_.FullName -match "(.+[]]*) - .+") {
            
        } 
        # else {
        #     $null = $_.FullName -match "(.+)\..+"
        # }
        $split_Filename = $_.FullName -split "/"
        $exists = Test-Path -LiteralPath (Join-Path -Path $OutPath -ChildPath $Matches[1])
        
        if ($exists -eq $false) {
            Write-Information "Directory $(Join-Path -Path $OutPath -ChildPath $Matches[1]) does not exist!"
            $null = New-Item -Path (Join-Path $OutPath $Matches[1]) -ItemType Directory -Force
            Write-Information "Created $(Join-Path $OutPath $Matches[1])"
        } elseif ($split_Filename.Count -gt 2) {
            $appndName = [System.IO.Path]::Combine([string[]]@($OutPath,$Matches[1]; $split_Filename[1..($split_Filename.Count-2)]))
            Write-Information "Checking on $appndName"
            $exists = Test-Path -LiteralPath $appndName
            if ($exists -eq $false) {
                $null = New-Item -Path $appndName -ItemType Directory -Force
                Write-Information "Created $appndName"
            } elseif ($split_Filename[1..($split_Filename.Count-1)] -like "*.*") {
                $appndName = [System.IO.Path]::Combine([string[]]@($OutPath,$Matches[1]; $split_Filename[1..($split_Filename.Count-1)]))
                Write-Output $appndName
                # TODO: Should we write more information to make better decisions?
                try { [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$appndName", $false) }
                catch { Write-Warning "$($appndName) exists..." }
            }
        }
    }

    # close ZIP file
    $zip.Dispose()
}
# open out folder
# explorer $OutPath
