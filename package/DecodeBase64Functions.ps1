<#
Function name: IsBase64
Description: Receives a string as input and returns true if base64 encoding is detected   
Function calls: -
Input: $InputString
Output: $true/$false
#>

function IsBase64() {
	param(
        [Parameter(
			Mandatory = $True)]
        [ string ] $InputString
    )


    #base 64 without header "powershell -e"... 
	$Pattern1 = [regex] "^([A-Za-z0-9\+\/]{4})*([A-Za-z0-9\+\/]{4}|[A-Za-z0-9\+\/]{3}=|[A-Za-z0-9\+\/]{2}==)$"
    $Matches1 = $Pattern1.match($InputString )
	
	if($Matches1.value ) {
		
		return $True
	}
	else {

        #base 64 with header "powershell -e..."
        $Pattern2 = [regex] "[\-\/][Ee^][NnCcOoDdEeDdMmAa]{0,14}\s{1,}[A-Za-z0-9\+\/\=]{5,}"
        $Matches2 = $Pattern2.match($InputString )
	
	 if( $Matches2.value  ) {
		
		return $True
	 }
	 else {
		return $False
	}

    }
}


<#
Function name: DecodeBase64
Description: Receives a string as input and removes base64 encoding from it     
Function calls: -
Input: $StringBase64
Output: $DecodedString
#>

function DecodeBase64() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$StringBase64
    )
	
	
	
	
	  #base 64 without header "powershell -e"... 
	if($StringBase64 -Match "^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$") 
	{
		
		$DecodedString = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($StringBase64))
	    return $DecodedString
     }
	
	#base 64 with header "powershell -e..."
	else 
	{
	  
	  $HeaderPattern = [regex] "[\-\/][Ee^][NnCcOoDdEeDdMmAa]{0,14}\s{1,}"
	  $StringPattern = [regex] "[\-\/][Ee^][NnCcOoDdEeDdMmAa]{0,14}\s{1,}[A-Za-z0-9\+\/\=]{5,}"
	  
	  
	  $HeaderMatches = $HeaderPattern.Matches($StringBase64)
      $StringMatches = $StringPattern.Matches($StringBase64)
	   
	 
	  $StringBase64 = $StringMatches.value   -replace "[\-\/][Ee^][NnCcOoDdEeDdMmAa]{0,14}\s{1,}", ""
	  
	  
	  
	   $DecodedString = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($StringBase64))
	   return $DecodedString
	
	
	}
    
	
}

<#
Function name: EncodeBase64
Description: Receives a string as input and applies base64 encoding to it     
Function calls: -
Input: $Script 
Output: $EncodedScript
#>

function EncodeBase64{
     param(
        [Parameter(
			Mandatory = $True)]
        [PSObject[]]$Script
	)
         
    $Bytes = [System.Text.Encoding]::UNICODE.GetBytes($Script)
    $EncodedScript =[Convert]::ToBase64String($Bytes)
    return $EncodedScript
}

