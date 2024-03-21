[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=1)]
    [String]
    $ScanPath
)

Add-Type -AssemblyName 'System.Drawing'
Add-Type -AssemblyName 'System.Web'

Function New-ContactSheet {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=1)]
        [String]
        $ScanPath
    )

    $ContactSheetDir = "_Index"
    $ContactSheetTitle = "Cze and Peku"
    # $dirs = Get-ChildItem -Path $ScanPath -Include Ungridded, Gridless -Directory -Recurse
    $dirs = Get-ChildItem -Path $ScanPath -Exclude _* -Directory
    # $img  = Get-ChildItem -Path $ScanPath -Include *.jpg,*.png -File -Recurse
    $html = @"
    <!doctype html>
    <html lang="en">
        <head>
            <title>$($ContactSheetTitle) Maps</title>
            <meta name="viewport" content="user-scalable=no, width=device-width, initial-scale=1, maximum-scale=1">
	        <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
	        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
            <link href="https://cdn.jsdelivr.net/npm/nanogallery2@3/dist/css/nanogallery2.min.css" rel="stylesheet" type="text/css">
	        <link href="bootstrap.min.css" rel="stylesheet" type="text/css">
        </head>
    <body>
        <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/jquery@3.3.1/dist/jquery.min.js"></script>
        <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/nanogallery2@3/dist/jquery.nanogallery2.min.js"></script>
        <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
        <div ID="ngy2p" data-nanogallery2='{
            "itemsBaseURL": "file://$ScanPath/$ContactSheetDir/",
            "thumbnailWidth": "240",
            "thumbnailHeight": "auto",
            "thumbnailLabel": {
              "position": "overImageOnBottom",
              "titleMultiLine": true
            },
            "thumbnailHoverEffect2": "imageScale150",
            "thumbnailAlignment": "center",
            "gallerySorting": "titleasc",
            "galleryL1FilterTags": "description",
            "galleryFilterTagsMode": "multiple",
            "galleryFilterTags": "false",
            "galleryTheme": {
                "thumbnail": {
                    "background": "#000"
                }
            }
          }'>
"@
    $html += "`t`t<h1>$($ContactSheetTitle) Maps</h1>`n"
    # $html += "`t`t<p class='subtext'>Found $($dirs.Count) folders containing $($img.Count) images!</p>`n"

    Write-Output "Processing $($dirs.Count) folders."

    foreach ($dir in $dirs) {
        $rando = '{0:X}' -f (Get-Random -Maximum 65535)
        
        # $subdirs = Get-ChildItem -LiteralPath $dir -Directory
        # foreach ($subdir in $subdirs) {        
            If ($img = (Get-ChildItem -LiteralPath $dir.FullName -Filter GL_*Original*_Day.* -Recurse | Sort-Object Name -Desc | Select-Object -Last 1)) {
            } elseif ($img = (Get-ChildItem -LiteralPath $dir.FullName -Filter GL_*Day*_Original.* -Recurse | Sort-Object Name -Desc | Select-Object -Last 1)) {
            } elseif ($img = (Get-ChildItem -LiteralPath $dir.FullName -Filter GL_*Original.* -Recurse | Sort-Object Name -Desc | Select-Object -Last 1)) {
            } elseif ($img = (Get-ChildItem -LiteralPath $dir.FullName -Filter GL_*_Day.* -Recurse | Sort-Object Name -Desc | Select-Object -Last 1)) {
            } else { $img = (Get-ChildItem -LiteralPath $dir.FullName -Filter GL_*.* -Include *.jpg,*.png -Recurse | Sort-Object Name -Desc | Select-Object -Last 1) }
            # Missing "campaign" maps and some other non-map content. What to do with that?

            $imgs = (Get-ChildItem -LiteralPath $dir.FullName -Filter GL_*.* -Include *.jpg,*.png -Recurse)
            
            Write-Information "`n`n[Indexing and Resizing] $($dir.Name)"
            Write-Information "`nFound $($imgs.Length) images..."

            if ($null -ne $img) {
                $rszImg = Resize-Image -MaintainRatio -ShortSide 400 -ImagePath $img -NameModifier thumb -InterpolationMode Bilinear -SmoothingMode HighSpeed -PixelOffsetMode HighSpeed -OutputPath (Join-Path -Path $ScanPath -ChildPath $ContactSheetDir\albums)
                $html += "`t`t<a href=`"`" data-ngid=`"$($rando)`" data-ngkind=`"album`" data-ngthumb=`"$(Join-Path -Path $ScanPath -ChildPath $ContactSheetDir\albums\$rszImg)`">$($dir.Name)</a>`n"

                foreach ($gal_img in $imgs) {
                    Write-Information "`n`tProcessing $($gal_img)"
                    $rszGalImg = Resize-Image -MaintainRatio -ShortSide 400 -ImagePath $gal_img -NameModifier thumb -InterpolationMode Bilinear -SmoothingMode HighSpeed -PixelOffsetMode HighSpeed -OutputPath (Join-Path -Path $ScanPath -ChildPath $ContactSheetDir\images)
                    Write-Information "`n`t$($rszGalImg) resized"
                    $html += "`t`t<a href=`"$($gal_img.FullName)`" data-ngalbumid=`"$($rando)`" data-ngthumb=`"$(Join-Path -Path $ScanPath -ChildPath $ContactSheetDir\images\$rszGalImg)`" data-ngdesc=`"#test`">$($gal_img.Name.Substring(0,$gal_img.Name.Length-4))</a>`n"
                }

            }
        # }
    }

    $html += "</div>`n"
    $html += "</body></html>"
    $html | Out-File -FilePath $ScanPath\$ContactSheetDir\index.html -Force
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
                # $file = Get-ChildItem -LiteralPath $Image.FullName
                if (Resolve-Path -ErrorAction Silent $OutputPath) {
                    
                } else {
                    New-Item $OutputPath -ItemType "Directory"
                }
                $out = Get-Item (Resolve-Path $OutputPath)
                # $ImgRoot = $file.Directory
                # $OutputPath = (Join-Path -Path $out.FullName -ChildPath ($ImgRoot.Parent.Name + $file.Extension))
                # $startDir = Get-Item (Resolve-Path -LiteralPath $Path)
                # if ($ImgRoot.Parent.Parent.Name -eq $startDir.Name) {
                #     $indexname = $ImgRoot.Parent.Name + $file.Extension
                # } else {
                #     $indexname = $ImgRoot.Parent.Parent.Name + "-" + $ImgRoot.Parent.Name + $file.Extension
                # }
                $indexname = $Image.Name
                $OutputPath = (Join-Path -Path $out.FullName -ChildPath $Image.Name)
            }
            
            if ($null -ne $OutputPath -and !(Resolve-Path -LiteralPath $OutputPath -ErrorAction Silent)) {
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
                    if ($null -ne $OutputPath -and !(Resolve-Path -ErrorAction Silent -LiteralPath $OutputPath)) {
                        $Bitmap.Save($OutputPath)
                        $global:count++
                    }
                }
                
                $Bitmap.Dispose()
                $NewImage.Dispose()
                $OldImage.Dispose()
            }
        }
    }
    End { return $indexname }
}

$global:count = 0
New-ContactSheet -ScanPath $ScanPath
Write-Host "$($global:count) new images processed!"