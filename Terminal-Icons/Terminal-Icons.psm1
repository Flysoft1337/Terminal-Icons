# Dot source public/private functions
# $public  = @(Get-ChildItem -Path ([IO.Path]::Combine($PSScriptRoot, 'Public/*.ps1'))  -Recurse -ErrorAction Stop)
# $private = @(Get-ChildItem -Path ([IO.Path]::Combine($PSScriptRoot, 'Private/*.ps1')) -Recurse -ErrorAction Stop)
# @($public + $private).ForEach({
#     try {
#         . $_.FullName
#     } catch {
#         throw $_
#         $PSCmdlet.ThrowTerminatingError("Unable to dot source [$($import.FullName)]")
#     }
# })

$moduleRoot    = $PSScriptRoot
$escape        = [char]27
$colorReset    = "${escape}[0m"
$defaultTheme  = 'devblackops'
$userThemePath = Get-ThemeStoragePath
$glyphs        = @{}
$colorSequences = @{}
$themeFilesLoaded = $false
$userThemeData = @{
    CurrentIconTheme  = $null
    CurrentColorTheme = $null
    Themes = @{
        Color = @{}
        Icon  = @{}
    }
}

# Load or create default prefs
$prefs = Import-Preferences

# Set current theme
$userThemeData.CurrentIconTheme  = $prefs.CurrentIconTheme
$userThemeData.CurrentColorTheme = $prefs.CurrentColorTheme

Save-Preferences -Preferences $prefs

# Export-ModuleMember -Function $public.Basename

Update-FormatData -Prepend ([IO.Path]::Combine($moduleRoot, 'Terminal-Icons.format.ps1xml'))
