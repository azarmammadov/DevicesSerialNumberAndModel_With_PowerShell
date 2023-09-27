# Define the path to the Plink executable
$plinkPath = "C:\script\plink.exe"

# Define the SSH credentials
$sshUsername = "root"
$sshPassword = "xxxxxxxx"

# Define the path to the text file containing IP addresses
$ipAddressesFilePath = "C:\script\ip_addresses.txt"

# Read IP addresses from the text file
$ipAddresses = Get-Content -Path $ipAddressesFilePath

# Define the commands to run on the Linux server
$commands = @(
    "sudo dmidecode -s system-product-name",
    "sudo dmidecode -s system-serial-number"
)

# Initialize an array to store the results
$results = @()

# Loop through the IP addresses
foreach ($ipAddress in $ipAddresses)
{
    $pingResult = Test-Connection -ComputerName $ipAddress -Count 1 -ErrorAction SilentlyContinue

    if ($pingResult -eq $null)
    {
        $result = [PSCustomObject]@{
            IPAddress = $ipAddress
            Command = "IP is offline"
            Output = "IP is offline"
        }
        $results += $result
    }
    else
    {
        # Use echo command to send "Y" to the prompt
        echo "Y" | & $plinkPath -ssh -l $sshUsername -pw $sshPassword -noagent $ipAddress exit

        foreach ($command in $commands)
        {
            $sshOutput = & $plinkPath -ssh -l $sshUsername -pw $sshPassword -batch -noagent $ipAddress $command
            $result = [PSCustomObject]@{
                IPAddress = $ipAddress
                Output = $sshOutput -join "`r`n"  # Join array of lines into a string
            }
            $results += $result
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "C:\script\ssh_results.txt" -NoTypeInformation
