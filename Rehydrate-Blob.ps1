# Initialize these variables with your values.
$subscription = "Gradin"
$rgName = "Gradin-Prod"
$accountName = "2muse2zephbak"
$srcContainerName = "syno-hyperback"
$destContainerName = "syno-hyperback"
$srcBlobName = "<source-blob>"
$destBlobName = "<dest-blob>"

# Get the storage account context
$ctx = (Get-AzStorageAccount `
        -ResourceGroupName $rgName `
        -Name $accountName).Context

# Copy the source blob to a new destination blob in Hot tier with Standard priority.

    $hydrate = Get-AzStorageBlob -Context $azsa -Container syno-hyperback |where {$_.AccessTier -eq "Archive" -and $_.Name -notmatch "Pool"}

    foreach ($blob in $hydrate) {
        $blob.BlobClient.SetAccessTier("Cool", $null, "Standard")
    }