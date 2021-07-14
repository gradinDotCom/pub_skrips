[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=1)]
    [String]
    $ScanPath
)

Add-Type -AssemblyName 'System.Drawing'
Function New-ContactSheet {
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=1)]
    [String]
    $ScanPath
)

$ContactSheetDir = "_Index"
$dirs = Get-ChildItem -Path $ScanPath -Include Ungridded, Gridless -Directory -Recurse

Write-Output "Processing $($dirs.Count) folders"

foreach ($dir in $dirs) {
    If ($img = (Get-ChildItem -LiteralPath ${dir} -Filter *Original_Day.jpg -Recurse | Sort-Object Name -Desc | Select-Object -Last 1)) {
    } elseif ($img = (Get-ChildItem -LiteralPath ${dir} -Filter *Original.jpg -Recurse | Sort-Object Name -Desc | Select-Object -Last 1)) {
    } elseif ($img = (Get-ChildItem -LiteralPath ${dir} -Filter *_Day.jpg -Recurse | Sort-Object Name -Desc | Select-Object -Last 1)) {
    } else {
        $img = Get-ChildItem -LiteralPath ${dir} -Recurse | Sort-Object Name -Desc | Select-Object -Last 1
    }
    Write-Information "`n`n[Indexing and Resizing] $($dir.FullName)"
    # Resize-Image -MaintainRatio -ShortSide 240 -ImagePath $img.FullName -NameModifier thumb -InterpolationMode Bilinear -SmoothingMode HighSpeed -PixelOffsetMode HighSpeed -OutputPath (Join-Path -Path $ScanPath -ChildPath $ContactSheetDir)
    Resize-Image -MaintainRatio -ShortSide 240 -ImagePath $img -NameModifier thumb -InterpolationMode Bilinear -SmoothingMode HighSpeed -PixelOffsetMode HighSpeed -OutputPath (Join-Path -Path $ScanPath -ChildPath $ContactSheetDir)
}
}

Function Resize-Image() {
    [CmdLetBinding(
        SupportsShouldProcess=$true, 
        PositionalBinding=$false,
        ConfirmImpact="Medium",
        DefaultParameterSetName="Absolute"
    )]
    Param (
        [Parameter(Mandatory=$True)]
        # [ValidateScript({
        #     $_ | ForEach-Object {
        #         Test-Path -LiteralPath $_
        #     }
        # })]
        [System.IO.FileInfo[]]$ImagePath,
        # [String[]]$ImagePath,
        [Parameter(Mandatory=$False)][Switch]$MaintainRatio,
        [Parameter(Mandatory=$False, ParameterSetName="Absolute")][Int]$Height,
        [Parameter(Mandatory=$False, ParameterSetName="Absolute")][Int]$Width,
        [Parameter(Mandatory=$False, ParameterSetName="Percent")][Double]$Percentage,
        [Parameter(Mandatory=$False)][System.Drawing.Drawing2D.SmoothingMode]$SmoothingMode = "HighQuality",
        [Parameter(Mandatory=$False)][System.Drawing.Drawing2D.InterpolationMode]$InterpolationMode = "HighQualityBicubic",
        [Parameter(Mandatory=$False)][System.Drawing.Drawing2D.PixelOffsetMode]$PixelOffsetMode = "HighQuality",
        [Parameter(Mandatory=$False)][String]$NameModifier = "resized",
        [Parameter(Mandatory=$False)][String]$OutputPath,
        [Parameter(Mandatory=$False)][Int]$ShortSide
    )
    Begin {
        If ($Width -and $Height -and $MaintainRatio) {
            Throw "Absolute Width and Height cannot be given with the MaintainRatio parameter."
        }
 
        If (($Width -xor $Height) -and (-not $MaintainRatio)) {
            Throw "MaintainRatio must be set with incomplete size parameters (Missing height or width without MaintainRatio)"
        }
 
        If ($Percentage -and $MaintainRatio) {
            Write-Warning "The MaintainRatio flag while using the Percentage parameter does nothing"
        }
    }
    Process {
        ForEach ($Image in $ImagePath) {
            $Path = (Resolve-Path -LiteralPath $Image.FullName).Path
            $Dot = $Path.LastIndexOf(".")

            #Add name modifier (OriginalName_{$NameModifier}.jpg)
            if($OutputPath -eq "") {
                $OutputPath = $Path.Substring(0,$Dot) + "_" + $NameModifier + $Path.Substring($Dot,$Path.Length - $Dot)
            } else {
                $file = Get-ChildItem -LiteralPath $Image.FullName
                if (Resolve-Path -ErrorAction Silent $OutputPath) {
                    
                } else {
                    New-Item $OutputPath -ItemType "Directory"
                }
                $out = Get-Item (Resolve-Path $OutputPath)
                $ImgRoot = $file.Directory
                # $OutputPath = (Join-Path -Path $out.FullName -ChildPath ($ImgRoot.Parent.Name + $file.Extension))
                $startDir = Get-Item (Resolve-Path $ScanPath)
                if ($ImgRoot.Parent.Parent.Name -eq $startDir.Name) {
                    $indexname = $ImgRoot.Parent.Name + $file.Extension
                } else {
                    $indexname = $ImgRoot.Parent.Parent.Name + "-" + $ImgRoot.Parent.Name + $file.Extension
                }
                $OutputPath = (Join-Path -Path $out.FullName -ChildPath $indexname)
            }
            
            $OldImage = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $Path
            # Grab these for use in calculations below. 
            $OldHeight = $OldImage.Height
            $OldWidth = $OldImage.Width
 
            If ($MaintainRatio) {
                $OldHeight = $OldImage.Height
                $OldWidth = $OldImage.Width
                If ($Height) {
                    $Width = $OldWidth / $OldHeight * $Height
                }
                If ($Width) {
                    $Height = $OldHeight / $OldWidth * $Width
                }
                If ($ShortSide) {
                    if ($Height -lt $Width) {
                        $Height = $ShortSide
                        $Width = $OldWidth / $OldHeight * $Height
                    } else {
                        $Width = $ShortSide
                        $Height = $OldHeight / $OldWidth * $Width
                    }
                }
            }
 
            If ($Percentage) {
                $Product = ($Percentage / 100)
                $Height = $OldHeight * $Product
                $Width = $OldWidth * $Product
            }

            $Bitmap = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $Width, $Height
            $NewImage = [System.Drawing.Graphics]::FromImage($Bitmap)
             
            #Retrieving the best quality possible
            $NewImage.SmoothingMode = $SmoothingMode
            $NewImage.InterpolationMode = $InterpolationMode
            $NewImage.PixelOffsetMode = $PixelOffsetMode
            $NewImage.DrawImage($OldImage, $(New-Object -TypeName System.Drawing.Rectangle -ArgumentList 0, 0, $Width, $Height))

            If ($PSCmdlet.ShouldProcess("Resized image based on $Path", "save to $OutputPath")) {
                $Bitmap.Save($OutputPath)
            }
            
            $Bitmap.Dispose()
            $NewImage.Dispose()
            $OldImage.Dispose()
        }
    }
}

New-ContactSheet -ScanPath $ScanPath