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

1-Save the PowerDecode.psm1 module in a directory ( for example "C:\workspace" )
2-Launch PowerShell.exe as admin user and enable script execution:

    Set-ExecutionPolicy bypass 


3-Select "C:\workspace" directory:
  
    cd C:\workspace 

4-Import the PowerDecode module on the PowerShell session:
    
	Import-Module  ./PowerDecode.psm1     

5-To deobfuscate a script:

   PowerDecode .\(parameter a)   (parameter b)  

  where:
   
  -(parameter a): [mandatory] .ps1 script path 
                  ( example:  script_folder\script.ps1)
 
  -(parameter b): [optional]  results file path 
                  ( example: C:\results_folder\result.txt ) 

 


Additional info:

-Before deobfuscating make sure the script is executable (deobfuscation process fails if script contains some syntax errors)
-Windows Defender might avoid the tool from working properly. Disable it temporarily if necessary.


 














