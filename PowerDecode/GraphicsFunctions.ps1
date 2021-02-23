<#
Function name: PrintLogo 
Description: Displays the PowerDecode logo and some info about the module   
Function calls: -
Input: -
Output: -   
#>
function PrintLogo( ) {
    param(  )
	
    $logo = @'
______                     ______                   _      
| ___ \                    |  _  \                 | |     
| |_/ /____      _____ _ __| | | |___  ___ ___   __| | ___ 
|  __/ _ \ \ /\ / / _ \ '__| | | / _ \/ __/ _ \ / _` |/ _ \
| | | (_) \ V  V /  __/ |  | |/ /  __/ (_| (_) | (_| |  __/
\_|  \___/ \_/\_/ \___|_|  |___/ \___|\___\___/ \__,_|\___| 

'@                                                           
          


$slogan ="                   PowerShell Script Decoder"

$about = @'

-Version    : 1.1.0   
-Author     : Giuseppe Malandrone 
-Email      : gmalandrone@numera.it
-Company    : Numera Sistemi e Informatica S.p.A
-Department : Ufficio Sicurezza Informatica 

'@



Write-Host $logo -Foregroundcolor yellow
Write-Host $slogan -Foregroundcolor yellow
Write-Host $about
   

    return
}
