### git for powershell installation ##########################

# provider for powershell from internet
install-packageprovider -name nuget -minimumversion 2.8.5.201 -force

# installation
Install-Module -Name posh-git

# verification
Get-Module -Name posh-git -ListAvailable

### session linked to web login github #######################

Set-Location -Path $env:SystemDrive\
Clear-Host
 
$Error.Clear()
Import-Module -Name posh-git -ErrorAction SilentlyContinue
 
if (-not($Error[0])) {
    $DefaultTitle = $Host.UI.RawUI.WindowTitle
    $GitPromptSettings.BeforeText = '('
    $GitPromptSettings.BeforeForegroundColor = [ConsoleColor]::Cyan
    $GitPromptSettings.AfterText = ')'
    $GitPromptSettings.AfterForegroundColor = [ConsoleColor]::Cyan
    function prompt 
    {
 
        if (-not(Get-GitDirectory)) {
            $Host.UI.RawUI.WindowTitle = $DefaultTitle
            "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "   
        }
        else {
            $realLASTEXITCODE = $LASTEXITCODE
 
            Write-Host 'PS ' -ForegroundColor Green -NoNewline
            Write-Host "$($executionContext.SessionState.Path.CurrentLocation) " -ForegroundColor Yellow -NoNewline
 
            Write-VcsStatus
 
            $LASTEXITCODE = $realLASTEXITCODE
            return "`n$('$' * ($nestedPromptLevel + 1)) "   
        }
     }
 }
else {
    Write-Warning -Message 'Unable to load the Posh-Git PowerShell Module'
}

### send code as a commit to repository

Set-Location -Path 'C:\win10una1703frapro_home\sources\$oem$\$1\_util\web_interface_powershell_git'

git init

#Will add the files in the current git directory to the git repository
git add . 

#prepare the remote  git path for operations
git remote remove origin 

git remote add origin 'https://github.com/Wildboy85/web_interface_powershell.git'

#verify
git remote -v 

#Will commit for first publication
git commit -m "first commit"

git push origin master 