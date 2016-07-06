# DellWarranty
A Dell warranty module that takes a CSV file input and outputs an object of results.

## Installing
This module can be installed from the [PowerShellGet Gallery](https://www.powershellgallery.com/packages/DellWarranty/),  You need [WMF 5](https://www.microsoft.com/en-us/download/details.aspx?id=44987) to use this feature.
```PowerShell
# To install DellWarranty, run the following command in the PowerShell prompt in Administrator mode:
Install-Module -Name DellWarranty
```

## Setup
The API key must be specified with each request, this can be achieved with the 'APIKey' parameter.
You can request an API key from Dell at http://en.community.dell.com/dell-groups/supportapisgroup
there is a PowerPoint file in the 'Get Started' link that gives you information on how to request one. 

Or you can setup a default paramenter value in your script or PowerShell profile as;
```PowerShell
$PSDefaultParameterValues = @{'Get-DellWarranty:APIKey'='abcdefg123456789abcdefgh12345678'}
```

The API key will be then used as the default option, the below examples assume you have done this.

## Examples
 A simple lookup (For testing you can use asset tags Test1 and Test2 these will give valid responses)
 ```PowerShell
Get-DellWarranty Test1
```
 
Looking up multiple assets
 ```PowerShell
'Test1','Test2' | Get-DellWarranty
```

Looking up multiple assets from a CSV file, you must have the headers 'Hostname' and 'AssetTag'
 ```PowerShell
Get-DellWarranty -InputObject (Import-Csv MyMachines.csv)
```

Looking up multiple assets from a CSV file and then exporting results to CSV 
 ```PowerShell
Get-DellWarranty -InputObject (Import-Csv MyMachines.csv) | Export-Csv Results.csv -NoTypeInformation
```

Calling a WMI query to a remote machine and returning the results
 ```PowerShell
Get-WmiObject -Class win32_bios -ComputerName DellComputerHostname | Get-DellWarranty
```
