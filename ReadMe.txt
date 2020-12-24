______                     ______                   _      
| ___ \                    |  _  \                 | |     
| |_/ /____      _____ _ __| | | |___  ___ ___   __| | ___ 
|  __/ _ \ \ /\ / / _ \ '__| | | / _ \/ __/ _ \ / _` |/ _ \
| | | (_) \ V  V /  __/ |  | |/ /  __/ (_| (_) | (_| |  __/
\_|  \___/ \_/\_/ \___|_|  |___/ \___|\___\___/ \__,_|\___| 
                                                           
              PowerShell Script Decoder
                                                            
    
-Author     : Giuseppe Malandrone 
-Email      : giusemaland@gmail.com
-University : Università degli Studi di Cagliari
-Department : Dipartimento di Ingegneria Elettrica ed Elettronica
 
PowerDecode is a PowerShell tool which allows to deobfuscate PowerShell obfuscated scripts across multiple layers. The tool also performs dynamic analysis, extracting malware hosting URLs and detecting malware IP traffic.         	

WARNING: Dynamic analysis requires script execution. Use the tool only in a isolated execution environment (sandbox). 


How to use the tool:

1-Save the PowerDecode.psm1 module in a generic directory (for example C:\workspace )
2-Launch PowerShell.exe in admin mode and enable script execution:

    Set-ExecutionPolicy bypass 


3-Select the directory where the module PowerDecode.psm1 is located:
  
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

-Before deobfuscating a script, remove all flags like:
  
   powershell , -NoP , -e , -WindowsStyle hidden   etc.
    
-To deobfuscate correctly base64 encoding, make sure the code contains no spacelines 
 
-Deobfuscation process fails if script contains some syntax errors

-For a correct IP traffic dynamic analysis close all other IP connections 
 














