<#
	.SYNOPSIS
		Querie WMI for MSI installed applications.
		
	.DESCRIPTION
		Queries WMI for applications installed by MSI by calling the Win32_Product class,
		all parameters are optional and the -Computer Parameter and be piped to by name only and have multiple entries.

	.PARAMETER  Computername
		Specifies the computer to query, can be an array of computers and can be name piped to.
		Default is localhost.

	.PARAMETER  Software
		Used to search for specific software, e.g *java* or "Java Auto Updater". Wrap strings with Double quotations (").
		Default is "*" wildcard meaning all items.
		
	.PARAMETER  Uninstall
		Uninstalls all found software using the Uninstall() Method.
		
	.PARAMETER  Credentials
		This Switch specifies credentials for remote machines. 
		Just using -Credentials will prompt you to enter your credentials when executing the command.
	
	.PARAMETER Showprogress
		
		Shows the progress on a per machine basis(works better if you have a few machines to check on).
		Default is off.
	
	.EXAMPLE
		This will query the local machine for anything installed like "Java" and return it to screen.
		PS C:\> Get-NTSoftware -Software "*java*"
		
		This will export all Software installed in the local machine to a file called File.csv With only the Name and installed date selected.
		PS C:\> Get-NTSoftware | Select-Object -Property name,InstallDate | Export-Csv -Path C:\MyPath\File.csv -NoTypeInformation
		
		This Searches for software on the computers in the file C:\ListofComputers.txt that match "*Java*" and return it to screen.
		PS C:\> Get-NTSoftware -Software "*java*" -Computername (Get-Content -Path C:\ListofComputers.txt)

	.EXAMPLE
		This will ask you for your credentials and query the machine BAD-USER and BAD-USER2 for any software that matches the term "*itunes*" and returns it to screen with a progress bar.
		PS C:\> Get-NTSoftware -Credentials -Computername BAD-USER,BAD-USER2 -Software "*iTunes*" -showprogress
		
		This will to the same as the command above but then uninstall the software and display a return code
		(0 usually means it was successful, 1603 usually means no permissions)
		PS C:\> Get-NTSoftware -Credentials -Computername BAD-USER,BAD-USER2 -Software "*iTunes*" -Uninstall

#>

function Get-Software {
	
	[CmdletBinding()]
	param (
		
		[Parameter(ValueFromPipelineByPropertyName = $True, ValueFromPipeline = $True)]
		[System.String[]]$Computername = "localhost",
		$Software = "*",
		[Switch]$Uninstall = $false,
		[Switch]$Credentials = $false,
		[Switch]$Showprogress = $false
	)
	
	BEGIN {
		if ($Credentials) { $credstore = Get-Credential }
		
		$Count = (100 / ($Computername).Count -as [Decimal])
		[Decimal]$Complete = "0"
	}
	
	PROCESS {
		
		Foreach ($Computer in $Computername) {
			
			try {
				$TestConnection = Test-Connection -Count 1 -ComputerName $Computer -ea Stop
				$Computer_Active = $true
				
			}
			catch {
				
				Write-Warning -Message "$computer was not reachable"
				$Computer_Active = $false	
			}
			if ($Computer_Active) {
				if ($Showprogress) { Write-Progress -Activity "Looking for $Software on $Computer" -CurrentOperation "Connecting to WMI on $Computer" -PercentComplete $Complete }
				
				if ($Credentials) { $Var1 = Get-WmiObject -Credential $credstore -Class Win32_Product -ComputerName $Computer | Where-Object { $_.name -Like "$Software" } }
				else { $Var1 = Get-WmiObject -Class Win32_Product -ComputerName $Computer | Where-Object { $_.name -Like "$Software" } }
				
				Write-Output -InputObject $Var1
				
				if ($Uninstall) { $Var1.Uninstall() }
				
				$Complete += $Count
				
			}
			
			if ($Showprogress) { Write-Progress -Activity "Finished with $Computer" -CurrentOperation "Done" -PercentComplete $Complete }
		}
		
		
		if ($Showprogress) { Write-Progress -Activity "Done" -Completed }
		
	}
	END { }
}	