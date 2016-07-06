function Get-DellWarranty {
    param(
        #Specifies the Dell Service Tag of the device we want to check
        [Parameter(Mandatory = $false,
                   ValueFromPipelineByPropertyName = $true,
                   ValueFromPipeline = $true,
                   Position = 0)]
        [Alias('SerialNumber')]
        [String] $AssetTag,
        #Optionally pass a hostname for easier reporting on the results
        [Parameter(Mandatory = $false,
                   ValueFromPipelineByPropertyName = $true,
                   ValueFromPipeline = $false,
                   Position = 1)]
        [Alias('PSComputerName','ComputerName')]
        [String] $Hostname,
        #For multiple lookups in one request use input object, AssetTag and Hostname must be in the object
        [psobject] $InputObject,
        #The API given to you by Dell Support
        [string] $APIKey,
        #If you have an API for sandbox testing use this switch
        [switch] $UseSandboxAPI
    )

    begin
    {
        # Small function to stop null or empty errors
        function ConvertTo-Date {
            Param($RawDate)
            if([string]::IsNullOrEmpty($RawDate)){
                return $RawDate
            }else{
                return [datetime]$RawDate
            }
        }
    }

    process
    {
        #Check if object is used and combine asset tags
        if($InputObject){
            $AssetTag = ($InputObject | Select-Object -ExpandProperty AssetTag) -join ','
        }

        #Dell Web Service URI
        if($UseSandboxAPI){
            [uri]$ServiceURI="https://sandbox.api.dell.com/support/assetinfo/v4/getassetwarranty/$($AssetTag)?apikey=$($APIKey)"
        }else{
            [uri]$ServiceURI="https://api.dell.com/support/assetinfo/v4/getassetwarranty/$($AssetTag)?apikey=$($APIKey)"
        }

        #Connect to web service proxy
        try
        {
            $WebRequestResult = (Invoke-WebRequest -Uri $ServiceURI -ErrorAction Stop).Content
        }
        catch
        {
            Write-Error "Unable to connect to Dell warranty API URI '$ServiceURI' - $_"
            return
        }

        #Build output list up
        $OutputHeaders = @(
            #User provided hostname
            'Hostname'
            #Asset header data
            'ServiceTag'
            'BUID'
            'CountryLookupCode'
            'CustomerNumber'
            'IsDuplicate'
            'ItemClassCode'
            'LocalChannel'
            'MachineDescription'
            'OrderNumber'
            'ParentServiceTag'
            'ShipDate'
            #Product data header
            'LOB'
            'LOBFriendlyName'
            'ProductFamily'
            'ProductId'
            'SystemDescription'
            #Entitlement data
            'EntitlementType'
            'ItemNumber'
            'ServiceLevelCode'
            'ServiceLevelDescription'
            'ServiceLevelGroup'
            'ServiceProvider'
            'StartDate'
            'EndDate'
        )

        try
        {
            if(-not $Hostname){
                $Hostname = 'Not Provided'
            }

            #Retrive Dell warranty information based on asset tag
            $DellInfoAll = ($WebRequestResult | ConvertFrom-Json).AssetWarrantyResponse
            
            #loop through results
            foreach($DellInfo IN $DellInfoAll){ 
                #If the Dell info has entitlements loop through each one else just return the single result
                if($DellInfo.AssetEntitlementData){
                    Foreach($Entitlement IN $DellInfo.AssetEntitlementData){
                        $Out = '' | Select-Object $OutputHeaders
                        $Out.Hostname = $Hostname

                        $Out.ServiceTag         = $DellInfo.AssetHeaderData.ServiceTag
                        $Out.BUID               = $DellInfo.AssetHeaderData.BUID
                        $Out.CountryLookupCode  = $DellInfo.AssetHeaderData.CountryLookupCode
                        $Out.CustomerNumber     = $DellInfo.AssetHeaderData.CustomerNumber
                        $Out.IsDuplicate        = $DellInfo.AssetHeaderData.IsDuplicate
                        $Out.ItemClassCode      = $DellInfo.AssetHeaderData.ItemClassCode
                        $Out.LocalChannel       = $DellInfo.AssetHeaderData.LocalChannel
                        $Out.MachineDescription = $DellInfo.AssetHeaderData.MachineDescription
                        $Out.OrderNumber        = $DellInfo.AssetHeaderData.OrderNumber
                        $Out.ParentServiceTag   = $DellInfo.AssetHeaderData.ParentServiceTag
                        $Out.ShipDate           = ConvertTo-Date $DellInfo.AssetHeaderData.ShipDate

                        $Out.LOB               = $DellInfo.ProductHeaderData.LOB
                        $Out.LOBFriendlyName   = $DellInfo.ProductHeaderData.LOBFriendlyName
                        $Out.ProductFamily     = $DellInfo.ProductHeaderData.ProductFamily
                        $Out.ProductId         = $DellInfo.ProductHeaderData.ProductId
                        $Out.SystemDescription = $DellInfo.ProductHeaderData.SystemDescription

                        $Out.EntitlementType         = $Entitlement.EntitlementType
                        $Out.ItemNumber              = $Entitlement.ItemNumber
                        $Out.ServiceLevelCode        = $Entitlement.ServiceLevelCode
                        $Out.ServiceLevelDescription = $Entitlement.ServiceLevelDescription
                        $Out.ServiceLevelGroup       = $Entitlement.ServiceLevelGroup
                        $Out.ServiceProvider         = $Entitlement.ServiceProvider
                        $Out.StartDate               = ConvertTo-Date $Entitlement.StartDate
                        $Out.EndDate                 = ConvertTo-Date $Entitlement.EndDate

                        $Out
                    }
                }else{
                    $Out = '' | Select-Object $OutputHeaders
                    $Out.Hostname = $Hostname

                    $Out.ServiceTag         = $DellInfo.AssetHeaderData.ServiceTag
                    $Out.BUID               = $DellInfo.AssetHeaderData.BUID
                    $Out.CountryLookupCode  = $DellInfo.AssetHeaderData.CountryLookupCode
                    $Out.CustomerNumber     = $DellInfo.AssetHeaderData.CustomerNumber
                    $Out.IsDuplicate        = $DellInfo.AssetHeaderData.IsDuplicate
                    $Out.ItemClassCode      = $DellInfo.AssetHeaderData.ItemClassCode
                    $Out.LocalChannel       = $DellInfo.AssetHeaderData.LocalChannel
                    $Out.MachineDescription = $DellInfo.AssetHeaderData.MachineDescription
                    $Out.OrderNumber        = $DellInfo.AssetHeaderData.OrderNumber
                    $Out.ParentServiceTag   = $DellInfo.AssetHeaderData.ParentServiceTag
                    $Out.ShipDate           = ConvertTo-Date $DellInfo.AssetHeaderData.ShipDate

                    $Out.LOB               = $DellInfo.ProductHeaderData.LOB
                    $Out.LOBFriendlyName   = $DellInfo.ProductHeaderData.LOBFriendlyName
                    $Out.ProductFamily     = $DellInfo.ProductHeaderData.ProductFamily
                    $Out.ProductId         = $DellInfo.ProductHeaderData.ProductId
                    $Out.SystemDescription = $DellInfo.ProductHeaderData.SystemDescription

                    $Out.EntitlementType         = $null
                    $Out.ItemNumber              = $null
                    $Out.ServiceLevelCode        = $null
                    $Out.ServiceLevelDescription = $null
                    $Out.ServiceLevelGroup       = $null
                    $Out.ServiceProvider         = $null
                    $Out.StartDate               = $null
                    $Out.EndDate                 = $null

                    $Out
                }
            }
        }
        catch
        {
            Write-Error "Failed to obtain asset information for '$Hostname' using asset tag '$AssetTag' - $_"
            return
        }
    }

}