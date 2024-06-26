@{

# Script module or binary module file associated with this manifest.
#RootModule = 'Tatux.Utils'

# Version number of this module.
ModuleVersion = '0.2.61'

# ID used to uniquely identify this module
GUID = '061256e7-9e17-4571-9481-baca2e0bc13e'

# Author of this module
Author = 'Nigel Tatschner'

# Company or vendor of this module
CompanyName = 'Tatux Solutions'

# Copyright statement for this module
Copyright = '(c) 2023 . All rights reserved.'

# Description of the functionality provided by this module
Description = 'A Set of utilities ive created to help with various tasks'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

#Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = '*'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

NestedModules = @('Tatux.Utils.psm1')

RequiredModules = @( 'tatux.core' )

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{
        # ReleaseNotes of this module
        ReleaseNotes = 'Added Telemetry and updated Module status logic.'
    } # End of PSData hashtable

} # End of PrivateData hashtable

}