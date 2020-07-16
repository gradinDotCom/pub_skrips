[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true,
    HelpMessage="File containing list of entries (1 line, 1 directory). Use 'sub:' followed by a comma-delimted list for a common subdirectory scheme to apply to all directories.")]
    [String[]]
    $filename,

    [Parameter(HelpMessage="Target directory (will be created if needed). You will need to be running with admin privileges if you're putting this in a 'protected' location. **Defaults to local directory**")]
    [String[]]
    $target="./"
)

New-Item -ItemType Directory -Path $target -ErrorAction SilentlyContinue

foreach($line in (Get-Content $filename)) {
    $DirCount = $line.Length
    if($line -match "sub:[\s]*(.*)") {
        $arr_subs = $matches[1] -split ",[\s]*", 0, "RegexMatch"
        $DirCount--
    } else {
        if($arr_subs.Count -gt 0) {
            foreach ($item in $arr_subs) {
                New-Item -Path "$($target)/$($line)" -Name $item -ItemType Directory -ErrorAction SilentlyContinue
            }
        } else {
            New-Item -Path $target -ItemType Directory -Name $line -ErrorAction SilentlyContinue
        }
    }
}

Write-Output "$($DirCount) directory(s) created at $((Get-Item $target).FullName)!"