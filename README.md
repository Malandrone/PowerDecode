![alt text](https://raw.githubusercontent.com/Malandrone/PowerDecode/main/Logo.PNG)
# PowerDecode
PowerDecode is a PowerShell-based tool for de-obfuscating PowerShell scripts obfuscated across multiple layers in different obfuscation forms including:
- String concatenate/reorder/reverse/replace
- Base64 encoding  
- ASCII encoding
- Compression deflate/GZIP
 
The tool performs also code dynamic analysis, gathering useful informations about malware activity including:
- HTTP response status of URLs
- Declared variables
- Payloads download attempts
- Attempts to start processes
- Shellcode injection attempts



**WARNING**: 
 - Dynamic analysis requires script execution. Use the tool only in a isolated execution environment ( VirtualBox for example) 
 - Before de-obfuscating make sure the script is executable (automatic de-obfuscation process fails if script contains some syntax errors)
 - Windows Defender might avoid the tool from working properly. Disable it temporarily if necessary.

**REQUIREMENTS**:
 - Windows PowerShell v5.1
 - OS Windows 10 64 bit
 
### How to use the tool
 - Enable scripts execution: launch PowerShell as Administrator and run the command:
 
   ```Set-ExecutionPolicy bypass```
 - If it doesn't work, open Registry Editor as Administrator and go to:
   
   ```Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell```
   
   Set the parameter "ExecutionPolicy" on value "Bypass"
 - Disable any antivirus software in order to allow the tool to analyze malware without interruption.
 - Click on **PowerDecode.bat** to start the GUI

PowerDecode can work in two different modes:
- Automatic decode mode
- Manual decode mode 

### Automatic decode mode
Obfuscation layers of an input script are automatically detected and removed. A dynamic analysis is performed on the final layer. The following options are available:
- **[1]-Decode a script from a single file:** takes as input a file to analyze and a folder to save the report file (if this last is not set, report file will be saved in the PowerDecode folder)
- **[2]-Decode multiple scripts from a folder:** takes as input a folder containg some files to analyze and a folder to save the report files (if this last is not set, report files will be saved in the PowerDecode folder)
- **[0]-Go back:** returns to the previous menu

### Manual decode mode 
User can select a set of tasks to perform on an input script to manually remove obfuscation layers. The following options are available:
- **[1]-Decode script by regex:** regular expression supported by PowerDecode are applied to the input string to remove a single obfuscation layer
- **[2]-Decode script by IEX overriding:** input string is executed in a local environment where Invoke-Expression cmdlet is replaced with Write-Output cmdlet (might execute malicious actions!)
- **[3]-Decode base64 encoding:** removes base64 encoding
- **[4]-Decode deflate payload:** removes deflatestream compression
- **[5]-Decode GZIP payload:** removes GZIPstream compression
- **[6]-Replace a string (raw):** replaces a piece of the loaded script with a substring entered by the user
- **[7]-Replace a string (evaluate):** replaces a piece of the loaded script with its execution output (might execute malicious actions!)
- **[8]-URLs analysis:** extracts URLs and checks their HTTP response status code
- **[9]-Get variables content:** extracts declared variables and shows their names and contents (might execute malicious actions!)
- **[10]-Shellcode check:** extracts shellcode as hexadecimal instructions. This feature could be efficiently integrated with [SCDBG](http://sandsprite.com/blogs/index.php?uid=7&pid=152). In order to activate the debugger, the scdbg.exe file must be placed on the PowerDecode\ folder  
- **[11]-Perform static analysis and get VirusTotal rating:** Analyzes the code without executing it and provides a description of the malware. If the API key is set shows the [VirusTotal](https://www.virustotal.com/) rating of the malware via API call
- **[12]-Undo last decoding task:** deletes the last layer of code obtained
- **[13]-Report preview:** shows all collected data as it will be saved on the report file
- **[14]-Store and export report file:** saves all collected data on a .txt report file and stores the sample in the MalwareRepository.db
- **[0]-Go back:** returns to the previous menu
 
### Malware repository
PowerDecode includes a malware database( MalwareRepository.db) based on [LiteDB](https://www.litedb.org/). On this section, following options are avaiable:

- **[1]-Query DB for a script:** checks if a script from an input file is stored on DB and if it is present, shows its de-obfuscated version
- **[2]-Query DB for a URL:** checks if an input URL is stored on DB and also shows stored malwares that connect to it 
- **[3]-Query DB for a shellcode:** checks if an input shellcode(string of hex values) is stored on DB  and if it is present shows stored malwares that inject it
- **[4]-Malware statistics:** shows some statistics about malware samples stored on MalwareRepository.db
- **[5]-Export all original scripts:** allows to export all orginal malware samples from MalwareRepository.db to an output folder. Each sample will be saved on a .txt file. WARNING: use this feature only on a isolated execution environment, exported files are malicious!  
- **[6]-Export all URLs:** allows to export all stored URLs from MalwareRepository.db to an output file
- **[6]-Export all Shellcodes:** allows to export all stored shellcodes from MalwareRepository.db to an output folder. Each sample will be saved on a .txt file
- **[0]-Go back:** returns to the previous menu

### Settings
Following parameters can be set:
- **[1]-Switch storage mode:** if it is set to "Enabled" analyzed scripts will be stored on MalwareRepository.db
- **[2]-Switch step-by-step mode:** if it is set to "Enabled", decoding multiple scripts from a folder, the user is asked for confirmation before continuing with the analysis of the next file
- **[3]-Set VirusTotal API key:** allows to load a VirusTotal API key to interact with the VirusTotal API
- **[4]-Set execution timeout:** allows to set the maximum time limit in seconds of script execution during de-obfuscation process
- **[5]-Switch logging mode:** if it is set to "Enabled" log files are saved on the package\logs folder

### License
 GPL-3.0 
  
### Paper
G. M. Malandrone, G. Virdis, G. Giacinto , D. Maiorca. [PowerDecode: a PowerShell Script Decoder Dedicated to Malware Analysis](http://ceur-ws.org/Vol-2940/paper19.pdf). 5th Italian Conference on CyberSecurity (ITASEC), 2021.
