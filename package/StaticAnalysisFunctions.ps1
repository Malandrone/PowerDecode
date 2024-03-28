<#
Function name: FindEvidences
Description: Takes as input a regex string and a code string and returns a list containing the matches
Function calls: -
Input: $Script $regex
Output: $Evidences
#>
function FindEvidences {	
	param(
        [Parameter(Mandatory = $true)][string] $Script ,
		[Parameter(Mandatory = $true)][string] $regex
	)
	
$Evidences = New-Object System.Collections.Generic.List[System.Object]	
$pattern = [regex] $regex
$matches = $pattern.matches($script)

foreach($match in $matches){
$Evidences.add($match.value)	
}	
	
return $Evidences
}

<#
Function name: WriteHostReport
Description: Takes Title, Evidences, Description strings as input and prints them on the screen with a specific layout
Function calls: -
Input: $Title, $Evidences, $Description
Output: - 
#>
function WriteHostReport {
	param(
        [Parameter(Mandatory = $true)][string] $Title ,
		[Parameter(Mandatory = $true)][string[]] $Evidences ,
		[Parameter(Mandatory = $true)][string] $Description
	)

Write-Host $Title -Foregroundcolor black -Backgroundcolor yellow
Write-Host "-Evidences: " 
Write-Host $Evidences
Write-Host "-Description: "
Write-Host $Description
Write-Host "--------------"

return
}	

<#
Function name: BuildDataForReport
Description: Takes Title, Evidences, Description strings as input and embeds them in a variable to be written to the report file
Function calls: 
Input: $Title, $Evidences, $Description
Output: $Data
#>
function BuildDataForReport {
		param(
        [Parameter(Mandatory = $true)][string] $Title ,
		[Parameter(Mandatory = $true)][string[]] $Evidences ,
		[Parameter(Mandatory = $true)][string] $Description
	)

$Data = ""

$Data += $Title + "`n" 
$Data +=  "-Evidences: "+"`n"  
$Data += $Evidences+"`n" 
$Data +=  "-Description: "+"`n" 
$Data +=  $Description+"`n" 
$Data += "--------------"+"`n" 

return $Data
}

<#
Function name: AnalyzeCode
Description: Statically analyzes the code for specific keywords that identify typical malware behaviors
Function calls: FindEvidences, WriteHostReport, BuildDataForReport
Input: $Script
Output: $ReportData
#>
function AnalyzeCode {
	param(
        [Parameter(Mandatory = $true)][string] $Script
	)

$Script = $Script.toLower()

$ReportData = New-Object System.Collections.Generic.List[System.Object]	

#Bytes
$Title = " Shellcode injector "
$HitBytes = $false
$regex = @"
\[(\s*)byte(\s*)\[(\s*)\](\s*)\]
"@
$Evidences = FindEvidences $Script $regex
if($Evidences.count -gt 0) {
	$HitBytes = $true
	$Description = Get-Content ("package\knowledge\Bytes.txt") | Out-String
	WriteHostReport $Title $Evidences $Description
	$Data = BuildDataForReport $Title $Evidences $Description
	$ReportData.add($Data)
}

#Net.WebClient
$Title = " Downloader "
$HitNetWebClient = $false
$regex = @"
net.webclient
"@
$Evidences = FindEvidences $Script $regex
if($Evidences.count -gt 0) {
	$HitNetWebClient = $true
	$Description = Get-Content ("package\knowledge\NetWebClient.txt") | Out-String
	WriteHostReport $Title $Evidences $Description
	$Data = BuildDataForReport $Title $Evidences $Description
	$ReportData.add($Data)
}

#RunDLL32
$Title = " DLL loader "
$HitRunDLL = $false
$regex = @"
rundll32
"@
$Evidences = FindEvidences $Script $regex
if($Evidences.count -gt 0) {
	$HitRunDLL = $true
	$Description = Get-Content ("package\knowledge\RunDLL32.txt") | Out-String
	WriteHostReport $Title $Evidences $Description
	$Data = BuildDataForReport $Title $Evidences $Description
	$ReportData.add($Data)
}

#Regsvr32
$Title = " DLL loader "
$HitRegsvr = $false
$regex = @"
regsvr32
"@
$Evidences = FindEvidences $Script $regex
if($Evidences.count -gt 0) {
	$HitRegsvr = $true
	$Description = Get-Content ("package\knowledge\Regsvr32.txt") | Out-String
	WriteHostReport $Title $Evidences $Description
	$Data = BuildDataForReport $Title $Evidences $Description
	$ReportData.add($Data)
}

return $ReportData
}