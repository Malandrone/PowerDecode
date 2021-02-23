<#
    
______                     ______                   _      
| ___ \                    |  _  \                 | |     
| |_/ /____      _____ _ __| | | |___  ___ ___   __| | ___ 
|  __/ _ \ \ /\ / / _ \ '__| | | / _ \/ __/ _ \ / _` |/ _ \
| | | (_) \ V  V /  __/ |  | |/ /  __/ (_| (_) | (_| |  __/
\_|  \___/ \_/\_/ \___|_|  |___/ \___|\___\___/ \__,_|\___| 
                                                           
              PowerShell Script Decoder

-Version    : 1.1.0    
-Author     : Giuseppe Malandrone 
-Email      : gmalandrone@numera.it
-Company    : Numera Sistemi e Informatica S.p.A
-Department : Ufficio Sicurezza Informatica

 
PowerDecode is a PowerShell module that allows to deobfuscate PowerShell scripts obfuscated across multiple layers. The tool performs code dynamic analysis, extracting malware hosting URLs and checking http response.It can also detect if the malware attempts to inject shellcode into memory.

WARNING: Dynamic analysis requires script execution. Use the tool only in a isolated execution environment (sandbox). 


How to use the tool:

1-Save the PowerDecode folder in a directory ( for example "C:\workspace" )
2-Launch PowerShell.exe as admin user and enable script execution:

    Set-ExecutionPolicy bypass 


3-Select "C:\workspace" directory:
  
    cd C:\workspace 

4-Import the PowerDecode module on the PowerShell session:
    
	Import-Module ./PowerDecode\PowerDecode.psd1     

3-To deobfuscate a script:

   PowerDecode .\(parameter a)   (parameter b)  

  where:
   
  -(parameter a): [mandatory] .ps1 script path 
                  ( example:  script_folder\script.ps1)
 
  -(parameter b): [optional]  results file path 
                  ( example: C:\results_folder\result.txt ) 

 


#>



@{

# Version number of this module.
ModuleVersion = '1.1.0'

# ID used to uniquely identify this module
GUID = 'd0a9150d-b6a4-4b17-a325-e3a24fed0ab9'

# Author of this module
Author = 'Giuseppe Malandrone'

# Copyright statement for this module
Copyright = 'GNU GENERAL PUBLIC LICENSE Version 3'

# Description of the functionality provided by this module
Description = 'PowerShell script decoder'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '2.0'

# Minimum version of the Windows PowerShell host required by this module
PowerShellHostVersion = '2.0'

# Script files (.ps1) that are run in the caller's environment prior to importing this module
ScriptsToProcess = @('GetScriptFromFileFunctions.ps1','DecodeBase64Functions.ps1','DeObfuscateByOverridingFunctions.ps1','DeObfuscateByRegexFunctions.ps1','MalwareAnalysisFunctions.ps1','GraphicsFunctions.ps1','Main.ps1')

# Functions to export from this module
FunctionsToExport = '*'

}
