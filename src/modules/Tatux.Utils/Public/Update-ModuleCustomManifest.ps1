function Update-ModuleCustomManifest {
    [CmdletBinding()]
    param(
        [ValidateScript({
                if (-Not (Test-Path -Path $_) -or $_.EndsWith(".psd1") -eq $false) {
                    throw "Enter a valid manifest file."
                }
                else {
                    $true
                }
            })]
            [string]$Path
        )
        try {
            $CurrentConfig = Get-ModuleConfig
			$TelmetryArgs = @{
				ModuleName = $CurrentConfig.ModuleName
				ModulePath = $CurrentConfig.ModulePath
				ModuleVersion = $CurrentConfig.ModuleVersion
				CommandName = $MyInvocation.MyCommand.Name
				URI = 'https://telemetry.tatux.in/api/telemetry'
			}
			if ($CurrentConfig.BasicTelemetry -eq 'True') {
				$TelmetryArgs.Add('Minimal', $true)
			}
			Invoke-TelemetryCollection @TelmetryArgs -Stage start -ClearTimer
        } catch {
            Write-Verbose "Failed to load telemetry"
        }
        Invoke-TelemetryCollection @TelmetryArgs -Stage 'In-Progress'
        # Test if field CmdletsToExport exists in the manifest file
        $ManifestFileContent = Get-Content -Path $Path
        $ModuleRoot = Split-Path -Path $Path -Parent
        $PublicFunctions = Join-Path -Path $ModuleRoot -ChildPath "Public"
        if ([string]::IsNullOrEmpty($ManifestFileContent -match '[\s|\t]*CmdletsToExport\s*=.*') -eq $false) {
            $LineWithCmdletsToExport = $($ManifestFileContent | Select-String -Pattern '^[\s|\t]*CmdletsToExport\s*=(.*)$')
            $LineNumber = $LineWithCmdletsToExport.LineNumber - 1
            $CmdletsToExport = $(Get-ChildItem -Path $PublicFunctions -Filter "*.ps1" | Where-Object {$_.Name -notlike "*.tests.ps1" } | % {'"' + $($_ | Select-Object -ExpandProperty BaseName) + '"' } ) -join ', '
            $NewLine = " @($CmdletsToExport)"
            Write-Output "Replacing line: $($LineWithCmdletsToExport.Matches.Groups[1].Value) with $NewLine"
            $ManifestFileContent[$LineNumber] = $ManifestFileContent[$LineNumber] -replace [regex]::Escape($LineWithCmdletsToExport.Matches.Groups[1].Value), $NewLine
            Set-Content -Path $Path -Value $ManifestFileContent
        } else {
            Write-Error "CmdletsToExport field could not be found in the manifest file."
            Invoke-TelemetryCollection @TelmetryArgs -Stage End -ClearTimer -Failed $true -Exception $_
            break
        }
        Invoke-TelemetryCollection @TelmetryArgs -Stage End -ClearTimer
}