# OnDemandModule

When you install a module, the module files are saved into one of the folders in $env:PSModulePath. The modules in those folders are imported automatically each time you open powershell window. Some modules like Microsoft Azure Module(AZ or AzureRM -- 50 dependent modules) and VMWare Power CLI(VMWare.PowerCLI -- about 20 dependent modules) has lots of dependent modules as well. So it increases powershell's startup and process time as it will casue longer time to lookup the commands. If you use this modules once a week or couple of times a month, there is no point to have them imported each time you open powershell.

If you have redirected folders set up on your machine which use a network share as My Document folder, it makes the performance worse. If you also use VPN to connect to your Company network, you will have worst powershell performance.

There might be a coupe of solutions for this.
1. You can install the modules when you need it and remove when you don't (I know it doesn't sound good)
2. You can set PSModule path to a local folder. But, it doesn't solve the problem that the modules will be imported each time
3. You can save all your modules in a local folder and import them as you need with `Import-Module -Name "C:\LocalFolder\MySweetPSModule"`. But the problem with it is some modules have dependent module and Powershell imports them before import the module you want. If you didn't add the module path to $env:PSModule path, powershell will fail to import dependent modules.

OndemandModule is written to solve those problems.


## Installation

* You can install OnDemandModule from [Powershell Gallery](https://www.powershellgallery.com/packages/OnDemandModule/1.0.1) by running this command: 

    - `Install-Module OnDemandModule` for system level installation
        
    - or, `Install-Module OnDemandModule -Scope CurrentUser` for user level installation.

* For the first time, create a local folder and set that folder as your OnDemandModule path by this command: `Set-OnDemandModulePath -Path "C:\Path\To\Folder"`. This command will add `OnDemandModulePath` variable to your profile with the path given. Make sure OnDemandModule is imported before you run this command.

## Usage 

- Move your PowerShell modules into the folder you set above
- Run `Import-OnDemandModule -Name ModuleName` as needed
- if you need to change your Module path, you can run `Set-OnDemandModulePath` cmdlet

## Examples

* `Get-OnDemandModule -Name AzureAD`
* `Get-OnDemandModule -Name ImportExcel -ListAvailable | Import-OndemandModule`
* `Import-OnDemandModule -Name VMWare.PowerCLI`
* `Set-OnDemandModule -Path "C:\Users\Musa\OnDemandModules"`
* `Save-Module -Name MSOnline -Path $OnDemandModulePath` 

Note: The last example will install a module from PowershellGallery.com to use with OndemandModule