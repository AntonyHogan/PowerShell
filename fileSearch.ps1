#  Script name:    fileSearch.ps1
#  Version:        PowerShell 2+
#  Created on:     04-11-2016
#  Purpose:        Searches for files with specific criteria (extensions, creation date, and size) and creates a report.

# Define the variables for the search (Search path, Log path, CreationTime in days, Size in MB and File extensions)
$searchPath = "C:\Users\"
$logFile = "C:\PSLogs\fileSearch.csv"
$creationTime = (Get-Date).AddDays(-365)
$fileSize = 500MB
$extFilters=@("*.mp4", "*.m4p", "*.m4v", "*.mpg", "*.mp2", "*.mpeg", "*.mpe", "*.mpv", "*.m2v", "*.mov", "*.avi", "*.mkv", "*.vob")

# Create a search variable
$searchAction = Get-ChildItem -Path $searchPath -Recurse -ErrorAction "SilentlyContinue" -Include $extFilters | Where {$_.CreationTime -lt $creationTime -and $_.Length -ge $fileSize}

# Run the search, select the data required, and export it
$searchAction | Select -Property Name, Extension, FullName, @{Label="FileSize";Expression={“{0:N2} MB” -f ($_.Length / 1MB)}}, CreationTime, LastAccessTime, LastWriteTime | Export-Csv $logFile

# Delete the files found from the search, remove the -WhatIf function when you're ready to delete for real
$searchAction | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue -WhatIf

# End