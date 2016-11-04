#  Script name:    computerInventory.ps1
#  Version:        PowerShell 2+
#  Created on:     04-11-2016
#  Purpose:        Searches the WMI records on remote computers to pull data into a CSV

$logFile = "C:\PSLogs\ComputerInventory.csv"
$Array = @()
$Computers = (Get-Content "C:\PSScripts\Computers.txt")
$liveCred = Get-Credential

foreach ($Computer in $Computers) {

    # Create object to hold the data
    $Result = "" | Select PCName,Manufacturer,Model,SerialNumber,MacAddress,IPAddress,RAM,HDDSize,HDDFree,CPU,OS,SP,User,BootTime

    # Collect the WMI data
    $computerSystem = Get-WMIObject Win32_ComputerSystem -Computer $Computer -Credential $liveCred
    $computerBIOS = Get-WMIObject Win32_BIOS -Computer $Computer -Credential $liveCred
    $computerNET = Get-WMIObject -Class "Win32_NetworkAdapterConfiguration" -Filter "IpEnabled = TRUE" -Computer $Computer -Credential $liveCred
    $computerOS = Get-WMIObject Win32_OperatingSystem -Computer $Computer -Credential $liveCred
    $computerHDD = Get-WMIObject Win32_LogicalDisk -Filter drivetype=3 -ComputerName $Computer -Credential $liveCred
    $computerCPU = Get-WMIObject Win32_Processor -ComputerName $Computer -Credential $liveCred

    # Sort the relevant WMI data into Results
    $Result.PCName = $computerSystem.Name
    $Result.Manufacturer = $computerSystem.Manufacturer
    $Result.Model = $computerSystem.Model
    $Result.SerialNumber = $computerBIOS.SerialNumber
    $Result.MacAddress = $computerNET.MacAddress
    $Result.IPAddress = $computerNET.IPAddress[0]
    $Result.RAM = "{0:N2}" -f ($computerSystem.TotalPhysicalMemory/1GB)
    $Result.HDDSize = "{0:N2}" -f ($computerHDD.Size/1GB)
    $Result.HDDFree = "{0:P2}" -f ($computerHDD.FreeSpace/$computerHDD.Size)
    $Result.CPU = $computerCPU.Name
    $Result.OS = $computerOS.Caption
    $Result.SP = $computerOS.ServicePackMajorVersion
    $Result.User = $computerSystem.UserName
    $Result.BootTime = $computerOS.ConvertToDateTime($computerOS.LastBootUpTime)

    # Push all the data into the Array
    $Array += $Result

}

# Export all data to a CSV
$Array | Export-Csv -Path $logFile -NoTypeInformation

# End
