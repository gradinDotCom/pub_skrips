param([string]$file)

function GetTakenData($image) {
	try {
		return $image.GetPropertyItem(36867).Value
	}
	catch {
		return $null
	}
}

[Reflection.Assembly]::LoadFile('C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Drawing.dll') | Out-Null
$image = New-Object System.Drawing.Bitmap -ArgumentList $file
try {
	$takenData = GetTakenData($image)
	if ($takenData -eq $null) {
		return $null
	}
	$takenValue = [System.Text.Encoding]::Default.GetString($takenData, 0, $takenData.Length - 1)
	$taken = [DateTime]::ParseExact($takenValue, 'yyyy:MM:dd HH:mm:ss', $null)
	return $taken
}
finally {
	$image.Dispose()
}

gci *.jpg | foreach {
	Write-Host "$_`t->`t" -ForegroundColor Cyan -NoNewLine
	$date = (E:\Users\olaf\Projects\pub_scripts\get-exif.ps1 $_.FullName)
	if ($date -eq $null) {
		Write-Host '{ No ''Date Taken'' in Exif }' -ForegroundColor Cyan
		return
	}
	$newName = $date.ToString('yyyy-MM-dd HH.mm.ss') + '.jpg'
	$newName = (Join-Path $_.DirectoryName $newName)
	Write-Host $newName -ForegroundColor Cyan
	# mv $_ $newName
}