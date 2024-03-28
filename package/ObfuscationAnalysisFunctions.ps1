<#
Function name: IsLayerAlreadyStored
Description: Takes an array of strings as input and a single string and determines if that string is in the array  
Function calls: -
Input: $ObfuscationLayers, $ObfuscatedScript 
Output: $true/$false
#>
function IsLayerAlreadyStored() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string[]]$ObfuscationLayers ,
		  [Parameter(
			Mandatory = $False)]
        [string]$ObfuscatedScript
	)

foreach($layer in $ObfuscationLayers ) {
	if($layer -eq $ObfuscatedScript) {
		return $true
	}
}

return $false
   
}

<#
Function name: GetObfuscationType
Description: Determines the obfuscation type of the obfuscated script received as input 
Function calls: IsCompressed, IsBase64, IsStringBased, IsEncoded.
Input: $ObfuscatedScript 
Output: (a string representing the obfuscation type)
#>
function GetObfuscationType() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )

  if( IsCompressed $ObfuscatedScript ) {
      return "Compressed"
   }
    
	if( IsStringBased $ObfuscatedScript ) {    
      return "String-Based"
  }
    
	if( IsEncoded $ObfuscatedScript ) { 
      return "Encoded"  
  }
      
  if( IsBase64 $ObfuscatedScript ) {   
      return "Base64"   
  }
    
  else {  
      return "Unknown" 
  }

   
}

<#
Function name: IsCompressed
Description: Returns true if the obfuscation type is compressed 
Function calls: -
Input: $ObfuscatedScript
Output: $true/$false  
#>
function IsCompressed() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string ]$ObfuscatedScript
    )
	
#to lower conversion 
$lowerstring = $ObfuscatedScript.toLower() 




$DeflatePattern = [regex] "io\.compression\.deflatestream"
$GzipPattern = [regex] "io\.compression\.gzipstream"

$DeflateMatches = $DeflatePattern.matches($lowerstring)
$GzipMatches = $GzipPattern.matches($lowerstring)


if ($DeflateMatches.Count -gt 0){
     return $true 
     }
	 
if ($GzipMatches.Count -gt 0){
     return $true 
     } 


return $false 


}

<#
Function name: IsEncoded
Description: Returns true if the obfuscation type is encoded
Function calls: -
Input: $ObfuscatedScript
Output: $true/$false   
#>
function IsEncoded() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )

$lowerstring = $ObfuscatedScript.toLower() 



#checking bxor
$pattern = [regex] "\-bxor"
$matches = $pattern.Matches($lowerstring)
   if ($matches.Count -gt 0){
     return $true 
     } 

#checking secure string
$pattern = [regex] "securestring"
$matches = $pattern.Matches($lowerstring)
   if ($matches.Count -gt 0){
     return $true 
     }
#checking hex\oct\bin 
$pattern = [regex]  "\[convert\]\:\:toint16"
$matches = $pattern.Matches($lowerstring)
   if ($matches.Count -gt 0){
     return $true 
     }


#remove spacelines 
$pattern = [regex]  " "
$matches = $pattern.Matches($lowerstring)

foreach  ($match in $matches) {

$ScriptNoSpacelines = $lowerstring.Replace( $match, '') 
}


#checking dec 
$pattern = [regex]  "\[int\]$_"
$matches = $pattern.Matches($ScriptNoSpacelines)
   if ($matches.Count -gt 0){
     return $true 
     }


return $false


}

<#
Function name: IsStringBased
Description: Returns true if the obfuscation type is string-based
Function calls: -
Input: $ObfuscatedScript
Output: $true/$false
#>
function IsStringBased() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )

#checking string formats 1
$regex= @"
(\(){0,}(\s){0,}[\"\'](\s){0,}(\{\d+\}){1,}(\s){0,}[\"\'](\s){0,}\-(\s){0,}[fF](.){0,}(\s){0,}(\)){0,}
"@

$pattern = [regex] $regex
$matches = $pattern.Matches($ObfuscatedScript) 

if ($matches.Count -gt 0){
    return $true
}

#checking string formats 2
$pattern = [regex] "(\{\d\}\'\s*-f)|(\'(.*?)\'\s*\+\s*\'(.*?)\')"
$matches = $pattern.Matches($ObfuscatedScript) 

if ($matches.Count -gt 0){
    return $true 
    }
    else {
		$lowerstring = $ObfuscatedScript.toLower() 
    
    $pattern = [regex] "\[char\]\d" 
    $matches = $pattern.Matches($lowerstring) 


if ($matches.Count -gt 0){
	return $true 
    }

#checking reverse string      
$pattern = [regex] "\'righttoleft\'" 
$matches = $pattern.Matches($lowerstring) 


if ($matches.Count -gt 0){
    return $true 
    }
      
    return $false
    }
}

<#
Function name: BitmapFetch
Description: Returns true if script contains bitmap image fetch instrucion
Function calls: -
Input: $ObfuscatedScript
Output: $true/$false
#>
function BitmapFetch() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string ]$ObfuscatedScript
    )
	
#to lower conversion 
$lowerstring = $ObfuscatedScript.toLower() 

$BitmapPattern = [regex] "system\.drawing\.bitmap"

$Matches = $BitmapPattern.matches($lowerstring)


if ($Matches.Count -gt 0){
     return $true 
     }
	 
return $false 


}