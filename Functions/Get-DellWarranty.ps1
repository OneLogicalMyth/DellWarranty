function Get-DellWarranty {
    param(
        #Specifies the Dell Service Tag of the device we want to check
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true,
                   ValueFromPipeline = $true,
                   Position = 0)]
        [Alias('SerialNumber')]
        [String] $AssetTag,
        [Parameter(Mandatory = $false,
                   ValueFromPipelineByPropertyName = $true,
                   ValueFromPipeline = $false,
                   Position = 1)]
        [Alias('PSComputerName')]
        [String] $Hostname,
        [uri]$ServiceURI='http://xserv.dell.com/services/assetservice.asmx?WSDL'
    )

    begin
    {
        $ErrorActionPreference = 'Stop'

        #Build output list up
        $OutputHeaders = @(
            'Hostname'
            'AssetTag'
            'ServiceTag'
            'SystemID'
            'Buid'
            'Region'
            'SystemType'
            'SystemModel'
            'SystemShipDate'
            'ServiceLevelCode'
            'ServiceLevelDescription'
            'Provider'             
            'StartDate'
            'EndDate'              
            'DaysLeft'       
            'EntitlementType'
        )

        #Connect to web service proxy
        try
        {
            $WebService = New-WebServiceProxy -uri $ServiceURI -Namespace WebServiceProxy
        }
        catch
        {
            Write-Error "Unable to connect to Dell warranty service URI - $_"
            return
        }
    }

    process
    {
        try
        {
            if(-not $Hostname){
                $Hostname = 'Not Provided'
            }

            $DellInfo = $WebService.GetAssetInformation('12345678-1234-1234-1234-123456789012','dellwarrantycheck',$AssetTag.Trim())
            
            if($DellInfo.Entitlements){
                Foreach($Entitlement IN $DellInfo.Entitlements){
                    $Out = '' | Select-Object $OutputHeaders
                    $Out.Hostname = $Hostname
                    $Out.AssetTag = $AssetTag
                    $Out.ServiceTag = $DellInfo.AssetHeaderData.ServiceTag
                    $Out.SystemID = $DellInfo.AssetHeaderData.SystemID
                    $Out.Buid = $DellInfo.AssetHeaderData.Buid
                    $Out.Region = $DellInfo.AssetHeaderData.Region
                    $Out.SystemType = $DellInfo.AssetHeaderData.SystemType
                    $Out.SystemModel = $DellInfo.AssetHeaderData.SystemModel
                    $Out.SystemShipDate = $DellInfo.AssetHeaderData.SystemShipDate
                    $Out.ServiceLevelCode = $Entitlement.ServiceLevelCode
                    $Out.ServiceLevelDescription = $Entitlement.ServiceLevelDescription
                    $Out.Provider = $Entitlement.Provider
                    $Out.StartDate = $Entitlement.StartDate
                    $Out.EndDate = $Entitlement.EndDate
                    $Out.DaysLeft = $Entitlement.DaysLeft
                    $Out.EntitlementType = $Entitlement.EntitlementType
                    $Out
                }
            }else{
                $Out = '' | Select-Object $OutputHeaders
                $Out.Hostname = $Hostname
                $Out.AssetTag = $AssetTag
                $Out.ServiceTag = $DellInfo.AssetHeaderData.ServiceTag
                $Out.SystemID = $DellInfo.AssetHeaderData.SystemID
                $Out.Buid = $DellInfo.AssetHeaderData.Buid
                $Out.Region = $DellInfo.AssetHeaderData.Region
                $Out.SystemType = $DellInfo.AssetHeaderData.SystemType
                $Out.SystemModel = $DellInfo.AssetHeaderData.SystemModel
                $Out.SystemShipDate = $DellInfo.AssetHeaderData.SystemShipDate
                $Out.ServiceLevelCode = $null
                $Out.ServiceLevelDescription = $null
                $Out.Provider = $null
                $Out.StartDate = $null
                $Out.EndDate = $null
                $Out.DaysLeft = $null
                $Out.EntitlementType = $null
                $Out
            }
        }
        catch
        {
            Write-Error "Failed to obtain asset information for '$Hostname' using asset tag '$AssetTag' - $_"
            return
        }
    }

    end
    {
        $ErrorActionPreference = 'Continue'
    }


}