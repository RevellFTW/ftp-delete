param (
    [string]$configFilePath
)

# Function to read configuration from the file
function Read-ConfigFile {
    param (
        [string]$configFilePath
    )

    $config = Get-Content $configFilePath | ConvertFrom-Json
    return $config
}

# Function to connect to the FTP server and delete files
function Delete-RemoteFiles {
    param (
        [string]$remoteUrl,
        [string]$remoteUsername,
        [string]$remotePassword,
        [string]$remoteBasePath,
        [string]$csvFilePath
    )

    # Create WebClient object
    $webClient = New-Object System.Net.WebClient
    $webClient.Credentials = New-Object System.Net.NetworkCredential($remoteUsername, $remotePassword)
    
 
    # Read the CSV file containing files to delete
    $filesToDelete = Get-Content $csvFilePath

    # Delete files on the remote server
    foreach ($file in $filesToDelete) {
        $remoteFilePath = "$remoteBasePath/$file"
        Write-Host "Connecting to: ftp://$remoteUrl/$remoteFilePath"
        $remoteUri = New-Object Uri("ftp://$remoteUrl/$remoteFilePath")

        $ftpRequest = [System.Net.FtpWebRequest]::Create($remoteUri)
        $ftpRequest.Credentials = New-Object System.Net.NetworkCredential($remoteUsername, $remotePassword)
        $ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::RemoveDirectory

         # Execute the request
        try {
            $ftpResponse = $ftpRequest.GetResponse()
            $ftpResponse.Close()
            Write-Host "Deleted: $remoteFilePath"
        }
        catch {
            Write-Host "Error deleting ${remoteFilePath}: $_"
        }
    }

    # Dispose WebClient object
    $webClient.Dispose()
}



# Main script logic
try {
    # Read configuration from the file
    $config = Read-ConfigFile -configFilePath $configFilePath

    # Call the function to delete remote files
    Delete-RemoteFiles -remoteUrl $config.remoteUrl -remoteUsername $config.remoteUsername -remotePassword $config.remotePassword -remoteBasePath $config.remoteBasePath -csvFilePath $config.csvFilePath
}
catch {
    Write-Host "Error: $_"
}