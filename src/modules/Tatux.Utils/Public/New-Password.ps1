<#
	.SYNOPSIS
		Generates a password based on a series of characters in a random order
	
	.DESCRIPTION
		Generates a password based on a series of characters in a random order
	
	.PARAMETER length
		Length of the password to generate
	
	.NOTES
		Additional information about the function.
#>
function Generate-Password {
	[CmdletBinding()]
	param
	(
		[Parameter(HelpMessage = 'Enter length of the password you would like to generate in numbers')]
		[int]$length = 10
	)
	begin {
        try {
            $CurrentConfig = Get-ModuleConfig
			$TelmetryArgs = @{
				ModuleName = $CurrentConfig.ModuleName
				ModulePath = $CurrentConfig.ModulePath
				ModuleVersion = $MyInvocation.MyCommand.Module.Version
				CommandName = $MyInvocation.MyCommand.Name
				URI = 'https://telemetry.tatux.in/api/telemetry'
			}
			if ($CurrentConfig.BasicTelemetry -eq 'True') {
				$TelmetryArgs.Add('Minimal', $true)
			}
			Invoke-TelemetryCollection @TelmetryArgs -Stage Start -ClearTimer
        } catch {
            Write-Verbose "Failed to load telemetry"
        }
	}
	process {
		Invoke-TelemetryCollection @TelmetryArgs -Stage 'In-Progress'	
		$SourceData = $NULL; For ($a = 33; $a –le 126; $a++) { $SourceData += , [char][byte]$a } # Converts numbers to legal character bytes for output
	
		For ($loop = 1; $loop –le $length; $loop++) {
			# Loops for the amount of length specified
		
			$Password += ($SourceData | Get-Random) # Gets a random character from list and stores it for output
		
		}
	
		$Props = @{ 'Password' = $Password } # Creates the property for the output object
	
		$Password = New-Object -TypeName PSObject -Property $Props # creates the output object
	
		Write-Output $Password
		Invoke-TelemetryCollection @TelmetryArgs -Stage End -ClearTimer
	}
} # End of the function