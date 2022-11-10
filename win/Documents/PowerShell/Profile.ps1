oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/jandedobbeleer.omp.json" | Invoke-Expression

# Needed for midnight commander
$Env:LANG = "en_EN.UTF8-8"

function Get-VsCodeDiff {
    & code -d $args
}

function Get-NVimDiff {
    & nvim -d $args
}

New-Alias -Name codediff -Value Get-VsCodeDiff -Force -Option AllScope
New-Alias -Name ndiff -Value Get-NVimDiff -Force -Option AllScope

function Get-SvnIgnoreTxt($DirPath = ".") {
    $svnAllNotAdded = (svn status) | select-string -pattern '\?'
    Set-Content -Path (Join-Path $Env:Tmp ignore-(New-Guid).txt) -Value $svnAllNotAdded
}

function Set-WindowsDarkTheme() {
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force
}

function Clear-WindowsDarkTheme() {
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 1 -Type Dword -Force
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 1 -Type Dword -Force
}

# pip powershell completion start
if ((Test-Path Function:\TabExpansion) -and -not `
    (Test-Path Function:\_pip_completeBackup)) {
    Rename-Item Function:\TabExpansion _pip_completeBackup
}
function TabExpansion($line, $lastWord) {
    $lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()
    if ($lastBlock.StartsWith("python.exe -m pip ")) {
        $Env:COMP_WORDS = $lastBlock
        $Env:COMP_CWORD = $lastBlock.Split().Length - 1
        $Env:PIP_AUTO_COMPLETE = 1
        (& python.exe -m pip).Split()
        Remove-Item Env:COMP_WORDS
        Remove-Item Env:COMP_CWORD
        Remove-Item Env:PIP_AUTO_COMPLETE
    }
    elseif (Test-Path Function:\_pip_completeBackup) {
        # Fall back on existing tab expansion
        _pip_completeBackup $line $lastWord
    }
}
# pip powershell completion end