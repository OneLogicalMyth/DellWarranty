# DellWarranty
A Dell warranty module that takes a CSV file input and outputs an object of results.

## Installing
To install Dell warranty download and copy to your 'My Documents' at;
```
My Documents\WindowsPowershell\Modules\DellWarranty
```

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
Import-Csv MyMachines.csv | Get-DellWarranty
```

Looking up multiple assets from a CSV file and then exporting results to CSV 
 ```PowerShell
Import-Csv MyMachines.csv | Get-DellWarranty | Export-Csv Results.csv -NoTypeInformation
```

Calling a WMI query to a remote machine and returning the results
 ```PowerShell
Get-WmiObject -Class win32_bios -ComputerName DellComputerHostname | Get-DellWarranty
```
