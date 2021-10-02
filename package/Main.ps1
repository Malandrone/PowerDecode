<#
Function name: PowerDecode
Description: Main function. Implements de-obfuscation algorithm and generates a report. 
Function calls: PrintLogo, GetScriptFromFile, IsBase64, DecodeBase64,GetSyntaxErrors, UpdateReport,  GoodSyntax, DeobfuscateByOverriding, DeobfuscateByRegex, GetObfuscationType, ExtractShellcode, ExtractUrls, UrlHttpResponseCheck,IsRecordAlreadyStored, BuildRecordScript , StoreRecordScript, BuildRecordUrl, StoreRecordUrl, StoreRecordShellcode, BuildRecordShellcode 
Input: $InputFile  
Output: -
#>

function PowerDecode {
    param(
        [Parameter(Mandatory = $true)][PSObject[]]$InputFile ,
		[Parameter(Mandatory = $false)][ string ]$OutputFileName ,
		[Parameter(Mandatory = $false)][ string ]$Store
	)

Clear-Host
PrintLogo
	
#Initializing variables	
$ObfuscatedScript = GetScriptFromFile $InputFile  
$ObfuscationLayers  = New-Object System.Collections.Generic.List[System.Object]
$Report = ""
$ReportFileName = "PowerDecode_2020_Malware_Analysis_Temp_Report"
$ReportOutFile =  [System.IO.Path]::GetTempPath() + $ReportFileName +".txt" 
$Report | Out-File $ReportOutFile 
$MalwareType = "undefined"
$BadSyntax = $false
$Hash = ((Get-FileHash $InputFile).Hash)
Write-Host "Obfuscated script file loaded" -ForegroundColor green    
#Checking Base64 encoding               
if(IsBase64 $ObfuscatedScript ) {
   if( !(IsStringBased $ObfuscatedScript) -and !(IsCompressed $ObfuscatedScript) -and !(IsEncoded $ObfuscatedScript)  ){
      Write-Host "Base64 encoding recognized" -ForegroundColor blue
      $ObfuscationLayers.Add($ObfuscatedScript)  
	  $ObfuscatedScript = DecodeBase64 $ObfuscatedScript
      Write-Host "Base64 layer solved" -ForegroundColor green
    }
}
	
#Checking syntax
if ( !(GoodSyntax $ObfuscatedScript) ) {
	$BadSyntax = $true
	$Errors = GetSyntaxErrors $ObfuscatedScript
	Write-Host "Syntax error:" -ForegroundColor red	
	Write-Host $Errors
	$data = "Script contains some syntax errors:" + "`r`n" + $Errors+ "`r`n" 
    UpdateReport($data)
}
	
#Deobfuscating by cmdlet overriding       
Write-Host "Deobfuscating IEX-dependent layers" -ForegroundColor yellow
   
try {
    while( GoodSyntax $ObfuscatedScript){		
     $ObfuscationLayers.Add($ObfuscatedScript)
     Write-Host "Syntax is good, layer stored successfully" -ForegroundColor green         
     $ObfuscatedScript = CleanScript   $ObfuscatedScript     
     Write-Host "Deobfuscating current layer by overriding" -ForegroundColor yellow          
     $DeobfuscationOutput = DeobfuscateByOverriding $ObfuscatedScript |Out-String	  
		  
		if(  (GoodSyntax $DeobfuscationOutput) -and ($DeobfuscationOutput -ne $ObfuscatedScript) -and ($DeobfuscationOutput.length -gt 4 )  ){
          	Write-Host "Layer deobfuscated successfully, moving to next layer" -ForegroundColor green     	 
		    $ObfuscatedScript = $DeobfuscationOutput
           
		    #ReChecking Base64 encoding               
            if(IsBase64 $ObfuscatedScript  ) {
				if( !(IsStringBased $ObfuscatedScript) -and !(IsCompressed $ObfuscatedScript) -and !(IsEncoded $ObfuscatedScript)  ){
				 Write-Host "Base64 encoding recognized" -ForegroundColor blue
		         $ObfuscationLayers.Add($ObfuscatedScript)  
		         $DeobfuscationOutput = DecodeBase64 $ObfuscatedScript
				 
				    if( GoodSyntax $DeobfuscationOutput ) {
					   $ObfuscatedScript = $DeobfuscationOutput
				       Write-Host "Base64 layer solved" -ForegroundColor green
				    }
              		 
			    }
		    }
		   
		}      
	         
		else {  
		     Write-Host "All detected obfuscation layers have been removed" -ForegroundColor yellow
			 break;
		}
		  
		  
    }
}

catch {	}

#Removing obfuscation residuals by regex 
Write-Host "Deobfuscating current layer by regex " -ForegroundColor yellow
$Plainscript =  DeobfuscateByRegex $ObfuscatedScript

if ( $PlainScript -ne $ObfuscatedScript ) {
     $ObfuscationLayers.Add($PlainScript)   
}
else {
	  $Plainscript = $ObfuscatedScript 
}
 
#Printing layers 
$NumberOfLayers = $ObfuscationLayers.Count  
$LastLayerIndex = $NumberOfLayers - 1     

ForEach ($layer in $ObfuscationLayers){
            
	if ( $layer  -ne $Plainscript ) {
	    $ObfuscationType =  GetObfuscationType $layer
		$heading = "`r`n`r`n" + "Layer " + ($ObfuscationLayers.IndexOf($layer)+1) +" - Obfuscation type: " + ($ObfuscationType)
            
		Write-Host $heading -ForegroundColor yellow        
        Write-Host "`r`n"
        Write-Host $layer
	    Write-Host "`r`n`r`n"
    }
}
    
$heading = "Layer " + ($LastLayerIndex+1) + " - Plainscript"
Write-Host $heading -ForegroundColor yellow
Write-Host "`r`n"	 
Write-Host $Plainscript
Write-Host "`r`n`r`n"

#Creating file to save results   
if($OutputFileName) {
   $OutputFile =  $OutputFileName ;  
}
else {
   $OutputFile = [System.IO.Path]:: "C:\"+ [GUID]::NewGuid().ToString() + ".txt";
   }
   

$result =  ForEach ($layer in $ObfuscationLayers){
            
			if ( $layer  -ne $Plainscript ) {
			  $ObfuscationType =  GetObfuscationType $layer
			  $heading = "`r`n`r`n" + "Layer " + ($ObfuscationLayers.IndexOf($layer)+1) +" - Obfuscation type: " + ($ObfuscationType)
			  Write-Output $heading        
              Write-Output "`r`n"
              Write-Output $layer
			  Write-Output "`r`n`r`n"
            }
           }
   
$heading = "`r`n`r`n" +"Layer " + ($LastLayerIndex+1) + " - Plainscript"+ "`r`n"
$result += ($heading) + "`r`n`r`n" + ($Plainscript) + "`r`n`r`n"

#Malware analysis    
 #Checking Shellcode
 if (($Plainscript.toLower() -match "virtualalloc") -or( $Plainscript.toLower().replace(' ','') -match "[byte[]]")) {
    $MalwareType = "file-less"
	Write-Host "Checking shellcode " -ForegroundColor yellow 
    $ShellcodeInfo = ExtractShellcode $Plainscript
 }

 #Fetching data from report
 $Report = Get-Content $ReportOutFile
 $Actions = $Report | Out-String
 Remove-Item $ReportOutFile
 
 #Variables analysis
 Write-Host "Checking variables content " -ForegroundColor yellow
 $VariablesContent = GetVariablesContent $Plainscript 

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
		
 #Printing and saving URLs report 
 $heading = "`r`n`r`n" + "Malware Hosting URLs Report:" + "`r`n"
 Write-Host $heading -ForegroundColor yellow
 $result += $heading 

    foreach ( $url in $UrlsReport ) {
      Write-Output $url 
      $result += $url + "`r`n"                
    }

 }
	
 else {
	$ErrorMessage = "No valid URLs found."
	Write-Host $ErrorMessage  -ForegroundColor red
	$result += $ErrorMessage
 }
 
 
 #Printing and saving variables content 
 $heading = "`r`n`r`n" + "Declared Variables:" + "`r`n"
 Write-Host $heading -ForegroundColor yellow
 $result += $heading 
 Write-Output $VariablesContent
 $result += $VariablesContent + "`r`n" 
 
 #Printing and saving shellcode info
 $heading = "`r`n`r`n" + "Shellcode detected:" + "`r`n"
 Write-Host $heading -ForegroundColor yellow
 $result += $heading 
 Write-Output $ShellcodeInfo
 $result += $ShellcodeInfo + "`r`n" 
 
 #Printing and saving execution output analysis
 if( GoodSyntax $Plainscript ) {
    $heading = "`r`n`r`n" +"Execution Report:"+ "`r`n"
    Write-Host $heading -ForegroundColor yellow
    Write-Output $Report 
    $result += $heading  
    $result += $Report 	
 }


 else {
    $BadSyntax = $true	 
    $heading = "`r`n`r`n" +"Syntax Error:"+ "`r`n"
	Write-Host $heading -ForegroundColor red	
    $result += $heading
    $Errors = GetSyntaxErrors $Plainscript
    Write-Host $Errors	
    $result += $Errors		 
 }

$Logo = ReportLogo
$Report = $Logo +$result  
$Report  | Out-File $OutputFile   



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
  if (($Store -eq "store") -and ( $BadSyntax -eq $false  ) ) {
   #Building and storage record script 
   $RecordScript = BuildRecordScript $ObfuscationLayers $MalwareType $Actions $Hash 
   StoreRecordScript $RecordScript

   #Building and storage record url 
   $index=0
   foreach ( $url in $Urls){
   $RecordUrl = BuildRecordUrl $url $UrlStatusList[$index] $Hash
   $index++
   StoreRecordUrl $RecordUrl
   }
   
   #Building and storage record shellcode
   if($MalwareType -eq "file-less"){
   $ShellcodeData = $result | Out-String 	   
   $RecordShellcode = BuildRecordShellcode $ShellcodeData $Hash
   StoreRecordShellcode $RecordShellcode 
   }
      
   
   Write-Host "Stored now!" -ForegroundColor green

 }
 
}


return 
    
}