<#
Function name: GetScriptFromFile 
Description: Receives as input a file path and returns its content
Function calls: GetFileEncoding
Input:  $InputFile
Output: $ObfuscatedScript
#>

function GetScriptFromFile() {
	param(
        [Parameter(
			Mandatory = $True)]
        [PSObject[]]$InputFile
    )
	
    try {
		$FileEncoding = GetFileEncoding $InputFile
		if($FileEncoding -eq "ascii") {
			$FileContent = Get-Content $InputFile -ErrorAction Stop
		}
		else {
			$FileContent = Get-Content $InputFile -Encoding UTF8 -ErrorAction Stop
		}
		foreach($line in $FileContent) {
			$ObfuscatedScript += $line
		}
	}
    catch {
		throw "Error reading: '$($InputFile)'"
	}
	
	return $ObfuscatedScript
}


<#
Function name: GetFileEncoding
Description: Receives as input an object and returns a string representing the text encoding type (ascii or utf8 )
Function calls: -
Input:  $InputObject 
Output: "ascii"/"utf8"
#>

function GetFileEncoding() {
	param(
        [Parameter(
			Mandatory = $True)]
        [PSObject[]]$InputObject
    )
	
	[byte[]]$Bytes = Get-Content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $InputObject
	
	if($Bytes[0] -eq 0xef -and $Bytes[1] -eq 0xbb -and $Bytes[2] -eq 0xbf) {
		return "utf8"
	}
	else {
		return "ascii"
	}
}

