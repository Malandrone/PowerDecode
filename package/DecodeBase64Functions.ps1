<#
Function name: IsBase64
Description: Receives a string as input and returns true if base64 encoding is detected   
Function calls: UpdateLog
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
		UpdateLog ("[IsBase64]: matched the base64 pattern without header 'powershell -e '  ");
		return $True
	}
	else {

        #base 64 with header "powershell -e..."
        $Pattern2 = [regex] "[\-\/][Ee^][NnCcOoDdEeDdMmAa]{0,14}\s{1,}[A-Za-z0-9\+\/\=]{5,}"
        $Matches2 = $Pattern2.match($InputString )
	
	 if( $Matches2.value  ) {
		UpdateLog ("[IsBase64]: matched the base64 pattern with the header 'powershell -e '  ");
		return $True
	 }
	 else {
		UpdateLog ("[IsBase64]: no base64 encoding detected  ");
		return $False
	}

    }
}

<#
Function name: DecodeBase64
Description: Receives a string as input and removes base64 encoding from it     
Function calls: UpdateLog
Input: $StringBase64
Output: $DecodedString
#>
function DecodeBase64() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$StringBase64
    )
	
	#Remove Random Hash
	$pattern = [regex] "Random\sHash\:(\s{0,})([A-Fa-f0-9]{1,})"
	$matches = $pattern.matches($StringBase64)
	
	foreach($match in $matches){
		$StringBase64 = $StringBase64.replace($match.value , "")
	}
	
	  #base 64 without header "powershell -e"... 
	if($StringBase64 -Match "^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$") 
	{
		
		$DecodedString = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($StringBase64))
	    UpdateLog ("[DecodeBase64]: Base64 string without header 'powershell -e' decoded, result:  "+$DecodedString);
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
	   UpdateLog ("[DecodeBase64]: Base64 string with header 'powershell -e' decoded, result:  "+$DecodedString);
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

<#
Function name: ExtractCompressedPayload
Description: Receives a string as input and returns the extracted base64 compression deflate payload from it 
Function calls: UpdateLog
Input: $InputString
Output: $Payload
#>
function ExtractCompressedPayload() {
	param(
        [Parameter(
			Mandatory = $True)]
        [ string ] $InputString
    )

$Payload = ""
try{
$InputString = $InputString.replace(" ","").replace("`n","").replace("`r","");
$Regex1 =@"
[Ff][Rr][Oo][Mm][Bb][Aa][Ss][Ee][6][4][Ss][Tt][Rr][Ii][Nn][Gg]\((['"]{1,})[A-Za-z0-9\+\/\=]{1,}(['"]{1,})
"@
 
	$Pattern1 = [regex] $Regex1
    $Matches1 = $Pattern1.Matches($InputString )
	
	$RawPayload = ($Matches1[0]).Value
$Regex2 =@"
[Ff][Rr][Oo][Mm][Bb][Aa][Ss][Ee][6][4][Ss][Tt][Rr][Ii][Nn][Gg]\(
"@
   $Pattern2 = [regex] $Regex2
   $Matches2 = $Pattern2.Matches($RawPayload )

   $Payload = $RawPayload.replace((($Matches2[0]).Value),"").replace("'","").replace('"','')
}

catch{
	UpdateLog ("[ExtractCompressedPayload]: Exception raised!:  ");
}

UpdateLog ("[ExtractCompressedPayload]: Payload extracted:  "+$Payload);
return $Payload

}

<#
Function name: GetCompressionType
Description: Returns "deflate" or "gzip" depending on the compression encoding detected 
Function calls: UpdateLog
Input: $InputString
Output: $CompressionType  
#>
function GetCompressionType() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string ]$InputString
    )
	
#to lower conversion 
$lowerstring = $InputString.toLower() 

$CompressionType = ""


$DeflatePattern = [regex] "io\.compression\.deflatestream"
$GzipPattern = [regex] "io\.compression\.gzipstream"

$DeflateMatches = $DeflatePattern.matches($lowerstring)
$GzipMatches = $GzipPattern.matches($lowerstring)


if ($DeflateMatches.Count -gt 0){
     $CompressionType = "deflate"
	 UpdateLog ("[GetCompressionType]: deflate  ");
	 return $CompressionType
     }
	 
if ($GzipMatches.Count -gt 0){
	 $CompressionType = "gzip"
	 UpdateLog ("[GetCompressionType]: gzip  ");
     return $CompressionType
     } 


return $CompressionType 


}

<#
Function name: DecodeDeflate
Description: Receives a string as input and removes base64 compression deflate encoding from it     
Function calls: CleanScript, UpdateLog
Input: $StringBase64
Output: $DecodedString
#>
function DecodeDeflate() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$StringBase64
    )
	
	
	
	$DecodedString = ""

	  try{
		       $DecodedPayload = "#Error decoding deflate format"
			   $DecodedPayload = [System.Convert]::FromBase64String("$StringBase64")
      
               $MemoryStream = New-Object System.IO.MemoryStream
               $MemoryStream.Write($DecodedPayload, 0, $DecodedPayload.Length)
               $MemoryStream.Seek(0,0) | Out-Null
               $DeflateStream = New-Object System.IO.Compression.DeflateStream ($MemoryStream, [System.IO.Compression.CompressionMode]::Decompress)
               $StreamReader = New-Object System.IO.StreamReader($DeflateStream)
               $DecodedString = $StreamReader.readtoend()
		       $DecodedString = (CleanScript $DecodedString) |Out-String
		      }
		      catch{
				  UpdateLog ("[DecodeDeflate]: Exception raised!  ");
			  }

	UpdateLog ("[DecodeDeflate]: Decoded string:  "+$DecodedString);

	   return $DecodedString	
}

<#
Function name: DecodeGzip
Description: Receives a string as input and removes base64 compression gzip encoding from it     
Function calls: CleanScript, UpdateLog
Input: $StringBase64
Output: $DecodedString
#>
function DecodeGzip() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$StringBase64
    )
	
	
	
	$DecodedString = ""

    try{
		       $DecodedPayload = "#Error decoding GZIP format"
			   $DecodedPayload = [System.Convert]::FromBase64String("$StringBase64")
      
               $MemoryStream = New-Object System.IO.MemoryStream
               $MemoryStream.Write($DecodedPayload, 0, $DecodedPayload.Length)
               $MemoryStream.Seek(0,0) | Out-Null
               $GZipStream = New-Object System.IO.Compression.GZipStream ($MemoryStream, [System.IO.Compression.CompressionMode]::Decompress)
               $StreamReader = New-Object System.IO.StreamReader($GZipStream)
               $DecodedString = $StreamReader.readtoend()
		       $DecodedString = (CleanScript $DecodedString) |Out-String
		      }
		      catch{
				  UpdateLog ("[DecodeGzip]: Exception raised!  ");
			  }

	UpdateLog ("[DecodeGzip]: Decoded string:  "+$DecodedString);

	   return $DecodedString	
}