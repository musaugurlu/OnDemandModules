if (!$Global:OnDemandModulePath) { $Global:OnDemandModulePath = "$HOME\OnDemandModules" }

function Get-OnDemandModule
{
    <#
        .SYNOPSIS
        Gets Ondemand-imported modules

        .DESCRIPTION
        Scans imported modules and returns the ones imported OnDemand

        .PARAMETER Name
        Module Name

        .PARAMETER ListAvailable
        returns available modules as well as already imported modules

        .EXAMPLE
        Get-OnDemandModule -Name AzureAD

        .EXAMPLE
        Get-OnDemandModule -Name ImportExcel -ListAvailable | Import-OndemandModule

    #>
    [CmdletBinding()]
    param (
        [string] $Name,
        [switch] $ListAvailable
    )
    
    begin
    {
        $CurrentPSModulePath = $env:PSModulePath
        $env:PSModulePath = $env:PSModulePath + ";$OnDemandModulePath"
    }
    
    process
    {
        # try
        # {
            switch ($true) {
                ($ListAvailable -and $Name) { $Modules = Get-Module $Name -ListAvailable }
                ($ListAvailable -and -not($Name)) { $Modules = Get-Module -ListAvailable }
                (-not($ListAvailable) -and $Name) { $Modules = Get-Module -Name $Name }
                (-not($ListAvailable) -and -not($Name)) { $Modules = Get-Module }
            }

            $Modules = $Modules | Where-Object { $_.Path -like "$OnDemandModulePath*" }
        # }
        # catch
        # {
        #     throw "$Name Module couldn't be found in OndemandModulePath $OnDemandModulePath"
        # }
    }
    
    end
    {
        $env:PSModulePath = $CurrentPSModulePath
        $Modules
    }
}

function Import-OnDemandModule
{
    <#
        .SYNOPSIS
        Allows to import modules on demand.

        .DESCRIPTION
        When you install modules with Install-Module, it saves the modules to one of folder in `$env:PSModulePath. Those modules are imported automatically evrytime powershell is started. OnDemandModule allows you to import modules with their name only without specifying path

        .PARAMETER Name
        Name of the Module you would like to import

        .PARAMETER Path
        Path of the module. it is set to `$OnDemandModulePath by default

        .EXAMPLE
        Import-OnDemandModule -Name VMWare.PowerCLI

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $Name,
        [ValidateScript( { Test-Path $_ })]
        [string] $Path = $OnDemandModulePath
    )
    
    begin
    {
        $CurrentPSModulePath = $env:PSModulePath
        $env:PSModulePath = $env:PSModulePath + ";$OnDemandModulePath" 
    }
    
    process
    {
        if (-not(Get-OnDemandModule -Name $Name -ListAvailable))
        {
            $env:PSModulePath = $CurrentPSModulePath
            throw "$Name Module could not be found!"
            break
        }

        try
        {
            Import-Module "$OndemandModulePath\$Name"
        }
        catch
        {
            $env:PSModulePath = $CurrentPSModulePath
            throw $Error[0].Message        
        }
    }
    
    end
    {
        $env:PSModulePath = $CurrentPSModulePath
    }
}

function Install-OnDemandModule
{
    <#
        .SYNOPSIS
        It is a just placeholder. It returs a warning only.

        .DESCRIPTION
        It is a just placeholder. It returs a warning only.

        .PARAMETER Name
        Name of the Module you would like to install.

        .EXAMPLE
        Install-OnDemandModule -Name MSOnline

    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string] $Name
    )
    
    begin
    {      
    }
    
    process
    {
        Write-Warning "This cmdlet is just a placeholder. Please use `"Save-Module`" cmdlet with `"-Name $Name -Path `$OnDemandModulePath`" parameters it has more options. For more information, run `"Get-Help Save-Module`""
    }
    
    end
    {
    }
}

function Set-OnDemandModulePath
{
    <#
        .SYNOPSIS
        Sets OnDemandModule path to given path.

        .DESCRIPTION
        Import-OnDemandModule uses the path defined in `$OnDemandModulePath variable. This cmdlet will add settings to Profile.ps1 with given path. So `$OnDemandModulePath can be set to this path as a part of profile.

        .PARAMETER Path
        Desired Path for modules to be used with OnDemandModule 

        .EXAMPLE
        Set-OnDemandModule -Path "C:\Users\Musa\OnDemandModules"

    #>
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipelineByPropertyName = $true, 
            ValueFromPipeline = $true,
            Mandatory = $true
        )]        
        [ValidateScript( { Test-Path $_ })]
        [string] $Path
    )
    
    begin
    {
        
    }
    
    process
    {
        $Path = Resolve-Path -Path $Path
        $PSFolder = Split-Path -Path $profile -Parent
        $ProfilePath = Join-Path -Path $PSFolder -ChildPath "Profile.ps1"
        $PathVariable = "`$Global:OnDemandModulePath = `'$Path`'"

        if (-not(Test-Path -Path $PSFolder))
        {
            try
            {
                New-Item -Path (Split-Path -Path $PSFolder -Parent) -Name (Split-Path -Path $PSFolder -Leaf) -ItemType Directory | Out-Null   
            }
            catch
            {
                throw "Powershell User ($PSFolder) Folder does not exist!"
                break
            }
        }

        if (-not(Test-Path -Path $ProfilePath))
        {
            try
            {
                New-Item -Path $PSFolder -Name Profile.ps1 -ItemType File | Out-Null
            }
            catch
            {
                throw "User Profile file ($PSFolder\Profile.ps1) does not exist!"
                break
            }
        }

        if ($ProfilePath -and (Get-Content $ProfilePath | Where-Object { $_ -like '*Global:OnDemandModulePath*' }))
        {
            
            $ProfileContent = Get-Content -Path $ProfilePath 
            
            $ProfileContent | ForEach-Object { $_ -replace ".*Global:OnDemandModulePath.*", $PathVariable } | Set-Content -Path $ProfilePath -Encoding utf8

        }
        else
        {
            $Content = @"
`n
################## OnDemandModule Path ###################

$PathVariable

########### Generated by OnDemandModule module ###########
"@
            Add-Content -Path $ProfilePath -Value $Content
        }

        $Global:OnDemandModulePath = $Path

    }
    
    end
    {
    }
}