function Import-XmlThemes {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [cmdletbinding()]
    param()

    if ($script:themeFilesLoaded) {
        return
    }

    $iconThemesPath     = [IO.Path]::Combine($script:moduleRoot, 'Data', 'iconThemes.xml')
    $colorThemesPath    = [IO.Path]::Combine($script:moduleRoot, 'Data', 'colorThemes.xml')
    $colorSequencesPath = [IO.Path]::Combine($script:moduleRoot, 'Data', 'colorSequences.xml')
    $glyphsPath         = [IO.Path]::Combine($script:moduleRoot, 'Data', 'glyphs.xml')

    if ((Test-Path $iconThemesPath) -and
        (Test-Path $colorThemesPath) -and
        (Test-Path $colorSequencesPath) -and
        (Test-Path $glyphsPath)) {
        $iconThemes             = Import-Clixml -Path $iconThemesPath
        $colorThemes            = Import-Clixml -Path $colorThemesPath
        $script:colorSequences  = Import-Clixml -Path $colorSequencesPath
        $script:glyphs          = Import-Clixml -Path $glyphsPath
    } else {
        $script:glyphs = . ([IO.Path]::Combine($script:moduleRoot, 'Data', 'glyphs.ps1'))
        $iconThemes    = Import-IconTheme
        $colorThemes   = Import-ColorTheme

        $script:colorSequences = @{}
        $colorThemes.GetEnumerator().ForEach({
            $script:colorSequences[$_.Name] = ConvertTo-ColorSequence -ColorData $_.Value
        })
    }

    $colorThemes.GetEnumerator().ForEach({
        $script:userThemeData.Themes.Color[$_.Name] = $_.Value
    })
    $iconThemes.GetEnumerator().ForEach({
        $script:userThemeData.Themes.Icon[$_.Name] = $_.Value
    })

    # Load user icon and color themes. Ignore the old theme.xml from Terminal-Icons v0.3.1 and earlier.
    (Get-ChildItem $script:userThemePath -Filter '*_icon.xml').ForEach({
        $userIconTheme = Import-CliXml -Path $_.FullName
        $script:userThemeData.Themes.Icon[$userIconTheme.Name] = $userIconTheme
    })
    (Get-ChildItem $script:userThemePath -Filter '*_color.xml').ForEach({
        $userColorTheme = Import-CliXml -Path $_.FullName
        $script:userThemeData.Themes.Color[$userColorTheme.Name] = $userColorTheme
        $script:colorSequences[$userColorTheme.Name] = ConvertTo-ColorSequence -ColorData $userColorTheme
    })

    $script:themeFilesLoaded = $true
}
