<#
Function name: GoodSyntax
Description: Receives a script as input and returns true if it doesn't contains syntax errors    
Function calls: -
Input: $ObfuscatedScript
Output: $true/$false
#>
function GoodSyntax() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )
		
	$Errors = @()
	[void][System.Management.Automation.Language.Parser]::ParseInput($ObfuscatedScript, [ref]$Null, [ref]$Errors)
	
	return [bool]($Errors.Count -lt 1)
}

<#
Function name: GetSyntaxErrors
Description: Receives a script as input and returns its syntax errors    
Function calls: -
Input: $ObfuscatedScript
Output: $Errors
#>
function GetSyntaxErrors() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )
		
	$Errors = @()
	[void][System.Management.Automation.Language.Parser]::ParseInput($ObfuscatedScript, [ref]$Null, [ref]$Errors)
	
	return $Errors
}

<#
Function name: CleanScript
Description: Receives a script as input and removes spurious characters
Function calls: ThereAreNonCompatibleAsciiCharacters, RemoveNonAsciiCharacters, EscapeCharactersWithBadFormat, RemoveEscapeCharactersWithBadFormat
Input: $ObfuscatedScript
Output: $ObfuscatedScript
#>
function CleanScript() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )
	
	
	
	if(ThereAreNonCompatibleAsciiCharacters $ObfuscatedScript) {
		$ObfuscatedScript = RemoveNonAsciiCharacters $ObfuscatedScript
	}
	if(EscapeCharactersWithBadFormat $ObfuscatedScript) {
		$ObfuscatedScript = RemoveEscapeCharactersWithBadFormat $ObfuscatedScript
	}
	
	return $ObfuscatedScript
}

<#
Function name: ThereAreNonCompatibleAsciiCharacters
Description: Receives a script as input and returns true if it contains some non compatible ASCII characters 
Function calls: -
Input: $ObfuscatedScript
Output: $true/$false 
#>
function ThereAreNonCompatibleAsciiCharacters() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )
	
	$RegexMatch = [Regex]::Match($ObfuscatedScript, "(?!\r|\n|\t)[\x00-\x1f\x7f-\xff]")
	if($RegexMatch.Success) {
		return $True
	}
	else {
		return $False
	}
}

<#
Function name: RemoveNonAsciiCharacters
Description: Receives a script as input and removes all not ASCII characters 
Function calls: -
Input: $ObfuscatedScript
Output: $ObfuscatedScript
#>
function RemoveNonAsciiCharacters() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )
	
	$ObfuscatedScript = $ObfuscatedScript -replace "[^\x00-\x7e]+", ""
	
	return $ObfuscatedScript
}

<#
Function name: EscapeCharactersWithBadFormat
Description: Receives a script as input and returns true if it contains <"> characters   
Function calls: -
Input: $ObfuscatedScript
Output: $true/$false
#>
function EscapeCharactersWithBadFormat() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )
	
	if($ObfuscatedScript -Match '\"') {
		return $True
	}
	else {
		return $False
	}
}

<#
Function name: RemoveEscapeCharactersWithBadFormat
Description: Receives a script as input and returns the same script with <"> character replaced with <'> 
Function calls: -
Input: $ObfuscatedScript
Output: $ObfuscatedScript
#>
function RemoveEscapeCharactersWithBadFormat() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )
		
	$ObfuscatedScript = $ObfuscatedScript -replace '\\"', "'"
	
	return $ObfuscatedScript
}