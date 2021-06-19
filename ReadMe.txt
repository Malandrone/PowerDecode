______                     ______                   _      
| ___ \                    |  _  \                 | |     
| |_/ /____      _____ _ __| | | |___  ___ ___   __| | ___ 
|  __/ _ \ \ /\ / / _ \ '__| | | / _ \/ __/ _ \ / _` |/ _ \
| | | (_) \ V  V /  __/ |  | |/ /  __/ (_| (_) | (_| |  __/
\_|  \___/ \_/\_/ \___|_|  |___/ \___|\___\___/ \__,_|\___| 
                                                           
              PowerShell Script Decoder
                                                            
    
-Version    : 2.0    
-Author     : Giuseppe Malandrone 
-Email      : gmalandrone@numera.it
-Company    : Numera Sistemi e Informatica S.p.A
-Department : Ufficio Sicurezza Informatica
 
PowerDecode is a PowerShell-based tool for de-obfuscating PowerShell scripts obfuscated across multiple layers in different obfuscation forms including:
-string concatenate/reorder/reverse/replace
-base64 encoding  
-ASCII encoding
-Compression deflate/GZIP
 
The tool performs also code dynamic analysis, gathering useful informations about malware activity including:
-HTTP response status of URLs
-Payloads download attempts
-Attempts to start processes
-Shellcode injection attempts

WARNING: Dynamic analysis requires script execution. Use the tool only in a isolated execution environment ( VirtualBox for example). 


How to use the tool:

Run PowerDecode.bat to start the GUI

PowerDecode can work in two different modes:
1-Automatic decode mode
2-Manual decode mode 

-Automatic decode mode
Obfuscation layers of an input script are automatically detected and removed. A dynamic analysis is performed on the final layer. The following options are avaiable:
[1]-Decode a script from a single file: Takes as input the path of the file to analyze and the path of the file to save the report file (if this last field is left blank, report file will be saved in the PowerDecode folder) 
[2]-Decode multiple scripts from a folder (fast mode): Takes as input the folder path containg some files to analyze and the folder path to save the report files (if this last field is left blank, report files will be saved in the PowerDecode folder) 
[3]-Decode multiple scripts from a folder (step-by-step): Unlike the previous case, the user is asked for confirmation before continuing with the analysis of the next file
[0]-Go back: Go back: returns to the previous menu

-Manual decode mode 
User can select a set of task to perform on an input script to manually remove obfuscation layers. The following options are available:
[1]-Decode full script by regex: regular expression supported by PowerDecode are applied to the input script to remove a single obfuscation layer;
[2]-Decode full script by IEX overriding: input script is executed in a local environment where Invoke-Expression cmdlet is replaced with Write-Output cmdlet  
[3]-Decode base64: removes base64 encoding
[4]-Decode deflate payload: removes deflatestream compression
[5]-Decode GZIP payload: removes GZIPstream compression
[6]-Replace a string (raw): replaces a piece of the loaded script with a substring entered by the user
[7]-Replace a string (evaluate): replaces a piece of the loaded script with its evaluated form
[8]-Undo last task: deletes the last layer of code obtained
[9]-View obfuscation layers: shows the history of code changes due to tasks application
[10]-Export report file: allows to save all extracted code layers on a txt report file  
[0]-Go back: returns to the previous menu
 


Additional info:

-Before deobfuscating make sure the script is executable (deobfuscation process fails if script contains some syntax errors)
-Windows Defender might avoid the tool from working properly. Disable it temporarily if necessary.

