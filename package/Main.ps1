<#
Function name: PowerDecode
Description: Main function. Implements de-obfuscation algorithm and generates a report. 
Function calls: PrintLogo, GetScriptFromFile, IsLayerAlreadyStored, IsBase64, DecodeBase64, GetSyntaxErrors, UpdateReport, GoodSyntax, DeobfuscateByOverriding, GetCompressionType, ExtractCompressedPayload, DecodeDeflate, DecodeGzip, DeobfuscateByRegex, GetObfuscationType, ExtractShellcode, ExtractUrls, UrlHttpResponseCheck, GetVariablesContent, GetVirusTotalReport, AnalyzeCode, IsRecordAlreadyStored, BuildRecordScript, StoreRecordScript, BuildRecordUrl, StoreRecordUrl, StoreRecordShellcode, BuildRecordShellcode
Input: $InputFile, $OutputFilePath, $Storage, $APIkey, $Timeout
Output: -
#>
function PowerDecode {
    param(
        [Parameter(Mandatory = $true)][PSObject[]]$InputFile ,
		[Parameter(Mandatory = $false)][ string ]$OutputFilePath ,
		[Parameter(Mandatory = $false)][ string ]$Storage	,
		[Parameter(Mandatory = $false)][ string ]$APIkey,
		[Parameter(Mandatory = $false)] $Timeout
	)

Clear-Host
PrintLogo
	
#Initializing variables	
$ObfuscatedScript = GetScriptFromFile $InputFile  
$ObfuscationLayers  = New-Object System.Collections.Generic.List[System.Object]
$ObfuscationLayers.Add($ObfuscatedScript)
$Report = ""
$ReportFileName = "PowerDecode_2020_Malware_Analysis_Temp_Report"
$ReportOutFile =  [System.IO.Path]::GetTempPath() + $ReportFileName +".txt" 
$Report | Out-File $ReportOutFile 
$MalwareType = "undefined"
$BadSyntax = $false
if(!($Timeout)){ $Timeout = 10 }
$Hash = ((Get-FileHash $InputFile).Hash)
$message = "Script loaded from file " + $InputFile + " (sha256: "+$Hash+" )"
Write-Host $message -ForegroundColor green
Write-Host "`n"

#Start primary deobfuscating loop
$TempObfuscatedScript = ''
$OldObfuscatedScript  = ''

while( $ObfuscatedScript -ne $OldObfuscatedScript ) {
	
	$OldObfuscatedScript = $ObfuscatedScript   

	#Checking Base64 encoding               
	if(IsBase64 $ObfuscatedScript ) {
	   if( !(IsStringBased $ObfuscatedScript) -and !(IsCompressed $ObfuscatedScript) -and !(IsEncoded $ObfuscatedScript)  ){
		  Write-Host "Base64 encoding recognized" -ForegroundColor blue
		  if(!(IsLayerAlreadyStored $ObfuscationLayers $ObfuscatedScript )){ $ObfuscationLayers.Add($ObfuscatedScript) }  
		  $ObfuscatedScript = DecodeBase64 $ObfuscatedScript
		  Write-Host "Base64 layer solved" -ForegroundColor green
		}
	}
		
	#Checking Compressed not dependentent of IEX
	try{
	if(IsCompressed $ObfuscatedScript  ) {
					#deflate
					if( (GetCompressionType $ObfuscatedScript) -eq "deflate" ){
					Write-Host "Deflate compression detected" -ForegroundColor magenta
					 
					 $StringBase64 = ExtractCompressedPayload $ObfuscatedScript
					 $DeobfuscationOutput = DecodeDeflate $StringBase64
					 
						if( GoodSyntax $DeobfuscationOutput ) {
						   if(!(IsLayerAlreadyStored $ObfuscationLayers $ObfuscatedScript )){ $ObfuscationLayers.Add($ObfuscatedScript) }  
						   $ObfuscatedScript = $DeobfuscationOutput
						   Write-Host "Compressed layer solved" -ForegroundColor green
						}
						else{
							$BadSyntax = $true
							$Errors = GetSyntaxErrors $DeobfuscationOutput
							Write-Host $DeobfuscationOutput
							Write-Host "Syntax error:" -ForegroundColor red	
							Write-Host $Errors
							$data = "Script contains some syntax errors:" + "`n" + $Errors+ "`n" 
							UpdateReport($data)
						 }
					}
				
					#gzip
					if( (GetCompressionType $ObfuscatedScript) -eq "gzip" ){
					Write-Host "Gzip compression detected" -ForegroundColor magenta
			
					 $StringBase64 = ExtractCompressedPayload $ObfuscatedScript
					 $DeobfuscationOutput = DecodeGzip $StringBase64
					 
						if( GoodSyntax $DeobfuscationOutput ) {
						   if(!(IsLayerAlreadyStored $ObfuscationLayers $ObfuscatedScript )){ $ObfuscationLayers.Add($ObfuscatedScript) }  
						   $ObfuscatedScript = $DeobfuscationOutput
						   Write-Host "Compressed layer solved" -ForegroundColor green
						}
						else{
							$BadSyntax = $true
							$Errors = GetSyntaxErrors $DeobfuscationOutput
							Write-Host $DeobfuscationOutput
							Write-Host "Syntax error:" -ForegroundColor red	
							Write-Host $Errors
							$data = "Script contains some syntax errors:" + "`n" + $Errors+ "`n" 
							UpdateReport($data)
						 }
						 
					}
				
				
	}
	}
	catch{}

	#Checking syntax
	if ( !(GoodSyntax $ObfuscatedScript) ) {
		$BadSyntax = $true
		$Errors = GetSyntaxErrors $ObfuscatedScript
		Write-Host "Syntax error:" -ForegroundColor red	
		Write-Host $Errors
		$data = "Script contains some syntax errors:" + "`n" + $Errors+ "`n" 
		UpdateReport($data)
	}

	#Deobfuscating by cmdlet overriding       
	Write-Host "Deobfuscating IEX-dependent layers" -ForegroundColor yellow
	   
	try {
		while( GoodSyntax $ObfuscatedScript){		
		
		 if(!(IsLayerAlreadyStored $ObfuscationLayers $ObfuscatedScript )){ $ObfuscationLayers.Add($ObfuscatedScript) }  
		 Write-Host "Syntax is good, layer stored successfully" -ForegroundColor green         
		  
		 $CleanedScript = CleanScript   $ObfuscatedScript
		 if(GoodSyntax $CleanedScript) { $ObfuscatedScript = $CleanedScript}
		 
		 Write-Host "Deobfuscating current layer by overriding" -ForegroundColor yellow          
		 $DeobfuscationOutput = ( DeobfuscateByOverriding $ObfuscatedScript $Timeout ) |Out-String
			  
			if(  (GoodSyntax $DeobfuscationOutput) -and ($DeobfuscationOutput -ne $ObfuscatedScript) -and ($DeobfuscationOutput.length -gt 50 )  ){				
				Write-Host "Layer deobfuscated successfully, moving to next layer" -ForegroundColor green     	 
				$ObfuscatedScript = $DeobfuscationOutput
				
				#ReChecking Base64 encoding               
				if(IsBase64 $ObfuscatedScript  ) {
					if( !(IsStringBased $ObfuscatedScript) -and !(IsCompressed $ObfuscatedScript) -and !(IsEncoded $ObfuscatedScript)  ){
					 Write-Host "Base64 encoding recognized" -ForegroundColor blue
					 if(!(IsLayerAlreadyStored $ObfuscationLayers $ObfuscatedScript )){ $ObfuscationLayers.Add($ObfuscatedScript) }   
					 $DeobfuscationOutput = DecodeBase64 $ObfuscatedScript
					 
						if( GoodSyntax $DeobfuscationOutput ) {
						   $ObfuscatedScript = $DeobfuscationOutput
						   Write-Host "Base64 layer solved" -ForegroundColor green
						}
						
					}
				}
			   
				#ReChecking Compressed not dependentent of IEX
				 if(IsCompressed $ObfuscatedScript  ) {
					#deflate
					if( (GetCompressionType $ObfuscatedScript) -eq "deflate" ){
					Write-Host "Deflate compression detected" -ForegroundColor magenta
					 if(!(IsLayerAlreadyStored $ObfuscationLayers $ObfuscatedScript )){ $ObfuscationLayers.Add($ObfuscatedScript) }  
					 
					 $StringBase64 = ExtractCompressedPayload $ObfuscatedScript
					 $DeobfuscationOutput = DecodeDeflate $StringBase64
					 
						if( GoodSyntax $DeobfuscationOutput ) {
						   $ObfuscatedScript = $DeobfuscationOutput
						   Write-Host "Compressed layer solved" -ForegroundColor green
						}
						else{
							$BadSyntax = $true
							$Errors = GetSyntaxErrors $DeobfuscationOutput
							Write-Host $DeobfuscationOutput
							Write-Host "Syntax error:" -ForegroundColor red	
							Write-Host $Errors
							$data = "Script contains some syntax errors:" + "`n" + $Errors+ "`n" 
							UpdateReport($data)
						 }
						 
					}
				
					#gzip
					if( (GetCompressionType $ObfuscatedScript) -eq "gzip" ){
					Write-Host "Gzip compression detected" -ForegroundColor magenta
			
					 if(!(IsLayerAlreadyStored $ObfuscationLayers $ObfuscatedScript )){ $ObfuscationLayers.Add($ObfuscatedScript) }  
					 
					 $StringBase64 = ExtractCompressedPayload $ObfuscatedScript
					 $DeobfuscationOutput = DecodeGzip $StringBase64
					 
						if( GoodSyntax $DeobfuscationOutput ) {
						   $ObfuscatedScript = $DeobfuscationOutput
						   Write-Host "Compressed layer solved" -ForegroundColor green
						}
						else{
							$BadSyntax = $true
							$Errors = GetSyntaxErrors $DeobfuscationOutput
							Write-Host $DeobfuscationOutput
							Write-Host "Syntax error:" -ForegroundColor red	
							Write-Host $Errors
							$data = "Script contains some syntax errors:" + "`n" + $Errors+ "`n" 
							UpdateReport($data)
						 }
						 
					}
				
				}
			
			}      
				 
			else {  
				 Write-Host "Detected IEX obfuscation layers have been removed" -ForegroundColor yellow
				 break;
			}
			    
		}
	}

	catch {	}

	#Removing obfuscation residuals by regex 
	Write-Host "Deobfuscating current layer by regex " -ForegroundColor yellow
	$Plainscript =  DeobfuscateByRegex $ObfuscatedScript 
 
	if ( $Plainscript -ne $ObfuscatedScript ) {
		 Write-Host "Some patterns matched by regex have been resolved " -ForegroundColor green  
		 $ObfuscatedScript = $Plainscript
		 if(!(IsLayerAlreadyStored $ObfuscationLayers $ObfuscatedScript )){ $ObfuscationLayers.Add($ObfuscatedScript) }  
	}
	else {
		 break;
	}
	
	
}#End primary loop 


#Printing layers 
$NumberOfLayers = $ObfuscationLayers.Count  
$LastLayerIndex = $NumberOfLayers - 1     

ForEach ($layer in $ObfuscationLayers){
            
	if ( $layer  -ne $Plainscript ) {
	    $ObfuscationType =  GetObfuscationType $layer
		$heading = "`n`n" + "Layer " + ($ObfuscationLayers.IndexOf($layer)+1) +" - Obfuscation type: " + ($ObfuscationType)
            
		Write-Host $heading -ForegroundColor yellow        
        Write-Host "`n"
        Write-Host $layer
	    Write-Host "`n`n"
    }
}
    
$heading = "Layer " + ($LastLayerIndex+1) + " - Plainscript"
Write-Host $heading -ForegroundColor yellow
Write-Host "`n"	 
Write-Host $Plainscript
Write-Host "`n`n"


$result =  ForEach ($layer in $ObfuscationLayers){
            
			if ( $layer  -ne $Plainscript ) {
			  $ObfuscationType =  GetObfuscationType $layer
			  $heading = "`n`n" + "Layer " + ($ObfuscationLayers.IndexOf($layer)+1) +" - Obfuscation type: " + ($ObfuscationType)
			  Write-Output $heading        
              Write-Output "`n"
              Write-Output $layer
			  Write-Output "`n`n"
            }
           }
   
$heading = "`n`n" +"Layer " + ($LastLayerIndex+1) + " - Plainscript"+ "`n"
$result += ($heading) + "`n`n" + ($Plainscript) + "`n`n"

#Malware analysis

 #Fetch data from report
 $Report = Get-Content $ReportOutFile
 $Actions = $Report | Out-String
 Remove-Item $ReportOutFile
 
 #Url analysis
 Write-Host "Checking URLs http response " -ForegroundColor yellow
 $UrlStatusList  = New-Object System.Collections.Generic.List[System.Object]
 $Urls = ExtractUrls  $Plainscript
 if($Urls) { 
    $MalwareType = "file-based"
	$UrlsReport = @()
	foreach ( $url in $Urls ) {
        $UrlStatus = UrlHttpResponseCheck $url 
		$UrlStatusList.Add($UrlStatus)
		$UrlsReport += $UrlStatus 
    }
 }
	
 #Variables analysis
 Write-Host "Checking variables content " -ForegroundColor yellow
 $VariablesContent = GetVariablesContent $Plainscript $Timeout
 
 #Shellcode check
 if (($Plainscript.toLower() -match "virtualalloc") -or( $Plainscript.toLower().replace(' ','') -match "[byte[]]")) {
    $MalwareType = "file-less"
	Write-Host "Checking shellcode " -ForegroundColor yellow
	      #Bxor check
	      $BxorPattern = [regex] "-bxor\s(\d{1,})"
	      $BxorMatches = $BxorPattern.matches($Plainscript.toLower())
		  
		  if ( $BxorMatches.Count -gt 0) {
		    $BxorKeyString  = (($BxorMatches[0]).value).replace("-bxor","").replace(" ","")
		    $BxorKey = [int] $BxorKeyString
		  	Write-Host "Shellcode detected seems to be obfuscated by bxor with value "$BxorKey -ForegroundColor yellow
		    $ShellcodeInfo = ExtractShellcode $Plainscript $BxorKey
		  }
		  
		  else {
            $ShellcodeInfo = ExtractShellcode $Plainscript
		  }
 }
 
 #Get malware rating from VirusTotal
 if ($APIkey -ne "Not set") {
	 Write-Host "Checking VirusTotal reputation " -ForegroundColor yellow
	 $VTrating =  GetVirusTotalReport $Hash $APIkey
 }
 
 #Static analysis (print and store)
 $heading = "`n`n" + "Static analysis report:" + "`n"
 Write-Host $heading -ForegroundColor yellow
 $StaticAnalysisData = New-Object System.Collections.Generic.List[System.Object]	
 $StaticAnalysisData = AnalyzeCode $Plainscript
 $result += $heading
 $result +=  ForEach ($tag in $StaticAnalysisData){
              Write-Output $tag
           }
 
 #Print and save VirusTotal rating
 if($VTrating){
  $heading = "`n`n" + "VirusTotal rating:" + "`n" 
  Write-Host $heading -ForegroundColor yellow
  $result += $heading 
  Write-Output $VTrating
  $result += $VTrating 
  $result += "`n" 
 }
 
 #Print and save URLs analysis report
 $heading = "`n`n" + "Malware hosting URLs report:" + "`n"
 Write-Host $heading -ForegroundColor yellow
 $result += $heading  
 if($URLs){
	foreach ( $url in $UrlsReport ) {
	 Write-Output $url 
	$result += $url + "`n"                
	}
 }	
 
 else {
	$ErrorMessage = "No valid URLs found."
	Write-Host $ErrorMessage  -ForegroundColor red
	$result += $ErrorMessage
 }

 #Print and save variables content
 $heading = "`n`n" + "Declared variables:" + "`n"
 Write-Host $heading -ForegroundColor yellow
 $result += $heading 
 Write-Output $VariablesContent
 $result += $VariablesContent + "`n" 

 #Print and save shellcode analysis report
 if($ShellcodeInfo){
	 $heading = "`n`n" + "Shellcode detected:" + "`n"
	 Write-Host $heading -ForegroundColor yellow
	 $result += $heading 
	 Write-Output $ShellcodeInfo
	 $result += $ShellcodeInfo + "`n" 
 }

 #Print and save dynamic analysis output
 if( GoodSyntax $Plainscript ) {
    $heading = "`n`n" +"Dynamic analysis report:"+ "`n"
    Write-Host $heading -ForegroundColor yellow
    Write-Output $Report 
    $result += $heading  
    $result += $Report 	
 }

 else {
    $BadSyntax = $true
    $heading = "`n`n" +"Syntax error:"+ "`n"
	Write-Host $heading -ForegroundColor red	
    $result += $heading
    $Errors = GetSyntaxErrors $Plainscript
    Write-Host $Errors	
    $result += $Errors		 
 }

#Export results on the report file  
$Logo = ReportLogo
$HashInfo = "`n"+"File sha256: "+$Hash+ "`n" 
$Report = $Logo + $HashInfo +$result
 
if($OutputFilePath) {
   $OutputFile =  $OutputFilePath ;  
}
else {
   $OutputFile ="PowerDecode_report_"+$Hash +".txt";
   }

$Report  | Out-File $OutputFile  

#Clean Temp folder
if (Test-Path ([System.IO.Path]::GetTempPath() +"Alias.txt") ) {
	Remove-Item ([System.IO.Path]::GetTempPath() +"Alias.txt")
}

#Check if script is already stored on DB
if (IsRecordAlreadyStored $Hash) {
	Write-Host "This is a well known malware sample!" -ForegroundColor magenta
 }
else {
	Write-Host "Sample was not on the repository!" -ForegroundColor yellow
    if ($BadSyntax) {
	Write-Host "Unable to store sample due to syntax errors" -ForegroundColor red	
	}
 
 #Database storage
  if (($Storage -eq "Enabled") -and ( $BadSyntax -eq $false  ) ) {
   #Build and store record script 
   $RecordScript = BuildRecordScript $ObfuscationLayers $MalwareType $Actions $Hash 
   StoreRecordScript $RecordScript

   #Build and store record url 
   $index=0
   foreach ( $url in $Urls){
   $RecordUrl = BuildRecordUrl $url $UrlStatusList[$index] $Hash
   $index++
   StoreRecordUrl $RecordUrl
   }
   
   #Build and store record shellcode
   if($MalwareType -eq "file-less"){     
	  try {
	  $RecordShellcode = BuildRecordShellcode $ShellcodeInfo $Hash
      StoreRecordShellcode $RecordShellcode
	  }
     catch {}	  
   }
      
   Write-Host "Stored now!" -ForegroundColor green

 }
 
}

return     
}