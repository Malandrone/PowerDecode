#MAIN MENU
function DisplayMainMenu {
    param( )

$Settings = New-Object System.Collections.Generic.List[System.Object]
$Settings.Add("Enabled")  #Storage mode [Enabled/Disabled]
$Settings.Add("Disabled") #Step by step mode [Enabled/Disabled]

do {
 $Choice = "NONE"
 Clear-Host
 PrintLogo
 Write-Host "[1]-Automatic decode mode " -ForegroundColor yellow
 Write-Host "[2]-Manual decode mode " -ForegroundColor yellow
 Write-Host "[3]-Malware repository " -ForegroundColor yellow
 Write-Host "[4]-Settings " -ForegroundColor yellow
 Write-Host "[0]-Exit " -ForegroundColor yellow

 $Choice = Read-Host -Prompt 'Insert your choice'
 
 switch ( $Choice ) {
     1  { DisplayAutoMenu }
     2  { DisplayManualMenu}
	 3  { DisplayRepositoryMenu }
	 4  { $Settings = DisplaySettingsMenu $Settings }
 }

}

until($Choice -eq "0")

return  
}

#AUTO MENU
function DisplayAutoMenu {
    param( )

do {
 $Choice = "NONE"
 Clear-Host
 PrintLogo
 
 $StorageMode    = $Settings[0]
 $StepbyStepMode = $Settings[1] 
 if ($StorageMode -eq "Enabled") {Write-Host "Storage mode: Enabled" -ForegroundColor green} 
 else {Write-Host "Storage mode: Disabled" -ForegroundColor red }
 if ($StepbyStepMode -eq "Enabled") {Write-Host "Step by step mode: Enabled " -ForegroundColor green} 
 else {Write-Host "Step by step mode: Disabled" -ForegroundColor red }
 Write-Host "`r`n" 
 
 Write-Host "[1]-Decode a script from a single file " -ForegroundColor yellow
 Write-Host "[2]-Decode multiple scripts from a folder" -ForegroundColor yellow
 Write-Host "[0]-Go back " -ForegroundColor yellow
 
 $Choice = Read-Host -Prompt 'Insert your choice'

 switch ( $Choice ) {
    1  { SingleAutoDecode }
    2  { MultipleAutoDecode}
 }

}

until($Choice -eq "0")

return  
}

#SINGLE AUTO DECODE 
function SingleAutoDecode {
    param( )

Clear-Host
PrintLogo

Write-Host "Insert input file path"
$InputFilePath = Read-Host

if ( ($InputFilePath.length ) -eq 0) { 
$InputFilePath = "bad file path"
}

  while( ((Test-Path $InputFilePath) -eq $false)  ) {	 
	Clear-Host
    PrintLogo
    Write-Host "File path is not correct" -ForegroundColor red
	Write-Host "Insert input file path"
    $InputFilePath = Read-Host
    if ( ($InputFilePath.length ) -eq 0) { 
      $InputFilePath = "bad file path"
    }	
  }

Write-Host "[OPTIONAL]Insert output file path (if you leave it blank, report will be saved in the PowerDecode folder)"
$OutputFilePath = Read-Host 

   if ($Settings[0] -eq "Enabled") {
	PowerDecode $InputFilePath $OutputFilePath "store"
   }
   else {
	PowerDecode $InputFilePath $OutputFilePath
   }


if($OutputFilePath -eq "") {
    $DefaultPath = (Get-Location).Path
	$Message = "Decoding terminated. Report file has been saved to " + $DefaultPath
	Write-Host  $Message -ForegroundColor green
}
else {
	$Message = "Decoding terminated. Report file has been saved to " + $OutputFilePath
    Write-Host $Message -ForegroundColor green
}
pause

return  
}

#MULTIPLE AUTO DECODE
function MultipleAutoDecode{
	param( )
	
Clear-Host
PrintLogo

Write-Host "Insert input folder path"
$InputFolderPath = Read-Host
while( (Test-Path $InputFolderPath) -eq $false ) {	 
	Clear-Host
    PrintLogo
    Write-Host "Folder path is not correct" -ForegroundColor red
	Write-Host "Insert input folder path"
    $InputFolderPath = Read-Host 
}
Write-Host "[OPTIONAL]Insert output folder path (if you leave it blank, report will be saved in the PowerDecode folder)"
$OutputFolderPath = Read-Host

$n=1 
foreach ( $file in (Get-Childitem -Name $InputFolderPath)   ){
     $number = $n.toString(); 
     $InputFilePath = Join-Path -path $InputFolderPath -childpath $file
     if ($OutputFolderPath -ne ""){$OutputFilePath = $OutputFolderPath +"\"+ $number + ".txt"} 
    
             
	          if ($Settings[0] -eq "Enabled") {
	           PowerDecode $InputFilePath $OutputFilePath "store"
              }
              else {
	           PowerDecode $InputFilePath $OutputFilePath
              }
    
     $n++; 		

  if ($Settings[1] -eq "Enabled"){
  
     if($OutputFolderPath -eq "") {
 	    $DefaultPath = (Get-Location).Path
 	    $Message = "Decoding terminated. Report file has been saved to "+ $DefaultPath
	    Write-Host $Message  -ForegroundColor green
      }
      else{
        $Message = "Decoding terminated. Report file has been saved to " +$OutputFilePath
        Write-Host  $Message	-ForegroundColor green
      }

    pause
  }
}
	
return

}

#SETTINGS MENU
function DisplaySettingsMenu {
    param( 
	[Parameter(Mandatory = $true)][PSObject[]] $Settings
	)

Clear-Host
PrintLogo

do {
 $Choice = "NONE"
 Clear-Host
 PrintLogo
 Write-Host "[1]-Switch storage mode, current state: " -ForegroundColor yellow -nonewline
 
 if( $Settings[0]  -eq "Enabled") { Write-Host  $Settings[0]  -ForegroundColor green } 
 else{ Write-Host  $Settings[0]  -ForegroundColor red  }
 
 Write-Host "[2]-Switch step by step mode, current state: " -ForegroundColor yellow -nonewline
 if( $Settings[1]  -eq "Enabled") { Write-Host  $Settings[1]  -ForegroundColor green } 
 else{ Write-Host  $Settings[1]  -ForegroundColor red  }

 Write-Host "[0]-Go back " -ForegroundColor yellow

 $Choice = Read-Host -Prompt 'Insert your choice'
 
 switch ( $Choice ) {
     1  { 
	    if( $Settings[0]  -eq "Enabled") { $Settings[0] = "Disabled" } else{ $Settings[0] = "Enabled" }
	 }
     2  {  
	    if( $Settings[1]  -eq "Enabled") { $Settings[1] = "Disabled" } else{ $Settings[1] = "Enabled" }
	 }
	
 }

}

until($Choice -eq "0")



return  $Settings
}

#MANUAL MENU
function DisplayManualMenu {
    param(  )

Clear-Host
PrintLogo

Write-Host "Insert input file path ( file type must be .txt or .ps1 )"
$InputFilePath = Read-Host 

$correct = $false 
while($correct -eq $false ) {
 try {
	$correct = $true
	$ObfuscatedScript = GetScriptFromFile $InputFilePath
 }
 catch {
	$correct = $false 
	Clear-Host
    PrintLogo
    Write-Host "Please insert a correct file path" -ForegroundColor red
	$InputFilePath = Read-Host 
	
 }
}

$ObfuscationLayers  = New-Object System.Collections.Generic.List[System.Object]
$ObfuscationLayers.Add($ObfuscatedScript) 
$ObfuscationLayersOutput = ""
$Report = ""
$ReportFileName = "PowerDecode_2020_Malware_Analysis_Temp_Report"
$ReportOutFile =  [System.IO.Path]::GetTempPath() + $ReportFileName +".txt" 
$Report | Out-File $ReportOutFile
$MalwareType = "undefined"
$Hash = ((Get-FileHash $InputFilePath).Hash)

do {
$Choice = "NONE"
Clear-Host
PrintLogo

if (GoodSyntax $ObfuscatedScript ) { 
   Write-Host "[Syntax: OK] Current script:" -ForegroundColor green 
   }
else {
   Write-Host "[Syntax Error] Current script:" -ForegroundColor red
   $Errors = GetSyntaxErrors $ObfuscatedScript
   Write-Host $Errors  -ForegroundColor red
}

Write-Output $ObfuscatedScript 
Write-Host "`n`r"
Write-Host "Choose a task to perform: " -ForegroundColor yellow   
Write-Host "[1]-Decode full script by regex" -ForegroundColor yellow
Write-Host "[2]-Decode full script by IEX overriding" -ForegroundColor yellow
Write-Host "[3]-Decode base64" -ForegroundColor yellow
Write-Host "[4]-Decode deflate payload" -ForegroundColor yellow
Write-Host "[5]-Decode GZIP payload" -ForegroundColor yellow
Write-Host "[6]-Replace a string(raw)" -ForegroundColor yellow
Write-Host "[7]-Replace a string(evaluate)" -ForegroundColor yellow
Write-Host "[8]-URLs analysis" -ForegroundColor yellow
Write-Host "[9]-Get variables content" -ForegroundColor yellow
Write-Host "[10]-Shellcode check" -ForegroundColor yellow
Write-Host "[11]-Undo last decoding task" -ForegroundColor yellow
Write-Host "[12]-Report preview" -ForegroundColor yellow
Write-Host "[13]-Store and export report file" -ForegroundColor yellow
Write-Host "[0]-Go back " -ForegroundColor yellow

$Choice = Read-Host -Prompt 'Insert your choice'

switch ( $Choice )
 {
    1   { #Deobfuscating by regex
	     
		$DeobfuscatedScript = (DeobfuscateByRegex  $ObfuscatedScript)  
		 
        if ( ($DeobfuscatedScript -ne "" ) -and ($DeobfuscatedScript -ne $ObfuscatedScript) ) {
          $ObfuscationLayers.Add($DeobfuscatedScript)  
          $ObfuscatedScript = $DeobfuscatedScript  
            }
      
	
	
	}
    2   { #Deobfuscating by IEX overriding
	     try {
	          $DeobfuscatedScript = (DeobfuscateByOverriding  $ObfuscatedScript) |Out-String 
           }
         catch{}		   
	     if (  ($DeobfuscatedScript -ne "" ) -and($DeobfuscatedScript -ne $ObfuscatedScript) ) {
          $ObfuscationLayers.Add($DeobfuscatedScript)  
          $ObfuscatedScript = $DeobfuscatedScript  
            }
	
	}
	
    3   { #Decode base64  
		 try{
			 $DeobfuscatedScript = DecodeBase64 $ObfuscatedScript 
		     $DeobfuscatedScript = (CleanScript $DeobfuscatedScript) |Out-String
		   }
	     catch{}

        if ( $DeobfuscatedScript.length -gt 0 ) {
          $ObfuscationLayers.Add($DeobfuscatedScript)  
          $ObfuscatedScript = $DeobfuscatedScript  
            }
	
	}
	
	4   { #Decode deflate playload
		Clear-Host
        PrintLogo 
		
		try{
		$DecodedPayload = [System.Convert]::FromBase64String("$ObfuscatedScript")
       
         $MemoryStream = New-Object System.IO.MemoryStream
         $MemoryStream.Write($DecodedPayload, 0, $DecodedPayload.Length)
         $MemoryStream.Seek(0,0) | Out-Null
         $DeflateStream = New-Object System.IO.Compression.DeflateStream ($MemoryStream, [System.IO.Compression.CompressionMode]::Decompress)
         $StreamReader = New-Object System.IO.StreamReader($DeflateStream)
         $DeobfuscatedScript = $StreamReader.readtoend()
		 $DeobfuscatedScript = (CleanScript $DeobfuscatedScript) |Out-String
		}
		catch{}
		
		if ( $DeobfuscatedScript.length -gt 0 ) {
          $ObfuscationLayers.Add($DeobfuscatedScript)  
          $ObfuscatedScript = $DeobfuscatedScript  
          Write-Host "Payload decoded successfully"  -ForegroundColor green
		  pause
		}
		else {
		  Write-Host "Error,payload was not a valid format"  -ForegroundColor red
		  pause	
		}  
		
	}
	
	5 { #Decode GZIP payload
		Clear-Host
        PrintLogo 
		
		try{
		 $DecodedPayload = [System.Convert]::FromBase64String("$ObfuscatedScript")
         $MemoryStream = New-Object System.IO.MemoryStream
         $MemoryStream.Write($DecodedPayload, 0, $DecodedPayload.Length)
         $MemoryStream.Seek(0,0) | Out-Null
         $DeflateStream = New-Object System.IO.Compression.GZipStream($MemoryStream, [System.IO.Compression.CompressionMode]::Decompress)
         $StreamReader = New-Object System.IO.StreamReader($DeflateStream)
         $DeobfuscatedScript = $StreamReader.readtoend()
		 $DeobfuscatedScript = (CleanScript $DeobfuscatedScript) |Out-String 
		}
		catch{ }
		
		if ( $DeobfuscatedScript.length -gt 0 ) {
          $ObfuscationLayers.Add($DeobfuscatedScript)  
          $ObfuscatedScript = $DeobfuscatedScript  
          Write-Host "Payload decoded successfully"  -ForegroundColor green
		  pause
		}
		else {
		  Write-Host "Error,payload was not a valid format"  -ForegroundColor red
		  pause	
		}
        
	}
	
	
	6   { #Replace a string (raw)
	$ContinueDeobfuscating = $true
    $InitialScript = $ObfuscatedScript	
	While ( $ContinueDeobfuscating -eq $true ) {
	Clear-Host
    PrintLogo
	  if (GoodSyntax $ObfuscatedScript ) { 
         Write-Host "[Syntax: OK] Current script:" -ForegroundColor green 
     }
      else {
         Write-Host "[Syntax Error] Current script:" -ForegroundColor red
		 $Errors = GetSyntaxErrors $ObfuscatedScript
         Write-Host $Errors  -ForegroundColor red
      } 
      Write-Output $ObfuscatedScript  
      Write-Host "`n`r"
	  Write-Host "Insert a string to replace ( insert # to terminate the task)" -ForegroundColor yellow
	  $String = Read-Host
	  if ($String -eq "#") {break;}
		
	  Write-Host "Insert replace" -ForegroundColor yellow
	  $Replace = Read-Host
       
	  try {
		  $NewScript = $ObfuscatedScript.replace( $String , $Replace)
	  }
      catch{}	
	  Write-Host "Your entry:" -ForegroundColor yellow
      Write-Host $String  		
	  Write-Host "will be replaced with:" -ForegroundColor yellow
	  Write-Host $Replace
		

	  if (GoodSyntax $NewScript ) { 
        Write-Host "Syntax will remain correct " -ForegroundColor green 
      }
      else {
        Write-Host "There are syntax errors" -ForegroundColor red
      }
      Write-Host "Continue ? [y/n]"
	  $Response = Read-Host  
		
      if ($Response -eq "y") { 
		$ObfuscatedScript = $NewScript  
	   }        
  
	}
	
	if ( $ObfuscatedScript -ne $InitialScript){ 
		$ObfuscationLayers.Add($ObfuscatedScript)  
    }

	}
	
	7   { #Replace a string (evaluate) 
	$ContinueDeobfuscating = $true
    $InitialScript = $ObfuscatedScript	
	While ( $ContinueDeobfuscating -eq $true ) {
	Clear-Host
    PrintLogo
	  
	if (GoodSyntax $ObfuscatedScript ) { 
        Write-Host "[Syntax: OK] Current script:" -ForegroundColor green 
     }
    else {
        Write-Host "[Syntax Error] Current script:" -ForegroundColor red
		$Errors = GetSyntaxErrors $ObfuscatedScript
        Write-Host $Errors  -ForegroundColor red
      } 
      Write-Output $ObfuscatedScript  
      Write-Host "`n`r"

	  Write-Host "Insert a string to evaluate ( insert # to terminate the task)" -ForegroundColor yellow
	  $String = Read-Host
       
	  if ($String -eq "#") {break;}
	  
	  $EvaluatedString = "" 
	  try { 
	      $EvaluatedString = IEX $String
		  $EvaluatedString = "'"+$EvaluatedString+"'"
		  $NewScript = $ObfuscatedScript.replace( $String , $EvaluatedString)
		  }
      catch{}	
		Write-Host "Your entry:" -ForegroundColor yellow
        Write-Host $String  		
		Write-Host "will be replaced with:" -ForegroundColor yellow
		Write-Host $EvaluatedString

		if (GoodSyntax $NewScript ) { 
         Write-Host "Syntax will remain correct " -ForegroundColor green 
        }
        else {
         Write-Host "There are syntax errors" -ForegroundColor red
        }
        Write-Host "Continue ? [y/n]"
		$Response = Read-Host  
		
        if ($Response -eq "y") { 
		  $ObfuscatedScript = $NewScript  
		}
	 
	 }
		
	if ( $ObfuscatedScript -ne $InitialScript){ 
		   $ObfuscationLayers.Add($ObfuscatedScript)  
        }
	}
	
	8    { #URL analysis 
	Clear-Host
    PrintLogo
	
	Write-Host "Checking URLs http response " -ForegroundColor yellow
    $UrlStatusList  = New-Object System.Collections.Generic.List[System.Object]	
    $Urls = ExtractUrls  $ObfuscatedScript
     if($Urls) {
		$MalwareType = "file-based"
        $UrlsReport = @()
	   
	     foreach ( $url in $Urls ) {
		  $UrlStatus = UrlHttpResponseCheck $url 
		  $UrlStatusList.Add($UrlStatus)
		  $UrlsReport += $UrlStatus 
		 }
		 
       $heading = "`r`n`r`n" + "Malware Hosting URLs Report:" + "`r`n"
       Write-Host $heading -ForegroundColor yellow
	   
	     $URLresult = ""
         foreach ( $url in $UrlsReport ) {
           Write-Host $url 
           $URLresult += $url + "`r`n"                
         }

     }
	
     else {
	    $ErrorMessage = "No valid URLs found."
	    Write-Host $ErrorMessage  -ForegroundColor red
	    $URLresult = $ErrorMessage
     }

	pause
	}
	
	9    { #Get variables content 
	
	Clear-Host
    PrintLogo

	$heading = "`r`n`r`n" + "Variables Content:" + "`r`n"
	Write-Host  $heading -ForegroundColor yellow
	$VariablesContent = GetVariablesContent $ObfuscatedScript
	Write-Host $VariablesContent 
	pause
	}
	
	10   { #Shellcode check 
	  Clear-Host
      PrintLogo
	  
	  if (($ObfuscatedScript.toLower() -match "virtualalloc") -or( $ObfuscatedScript.toLower().replace(' ','') -match "[byte[]]")) {
        $MalwareType = "file-less"
		$heading = "`r`n`r`n" + "Shellcode detected:" + "`r`n"
        Write-Host $heading -ForegroundColor yellow
		
		$ShellcodeInfo = ExtractShellcode $ObfuscatedScript
        Write-Host $ShellcodeInfo	  
	  }
	  else{
		$ErrorMessage = "Nothing found"
	    Write-Host $ErrorMessage  -ForegroundColor red
	  }
	pause
	}
	
	11   { #Undo last decoding task
	Clear-Host
    PrintLogo 
    $NumberOfLayers = $ObfuscationLayers.Count
    if ($NumberOfLayers -eq "1"){
	    Write-Host "No task to cancel" -ForegroundColor red
    }
    else {
		  $LastLayerIndex = $NumberOfLayers - 1     
          $ObfuscationLayers.RemoveAt($LastLayerIndex)
		  $NumberOfLayers = $ObfuscationLayers.Count
          $LastLayerIndex = $NumberOfLayers - 1 
		  $ObfuscatedScript = $ObfuscationLayers[$LastLayerIndex]
          Write-Host "Last layer removed" -ForegroundColor green
	}
     pause
	
	}
	
	12   { #Report preview
	Clear-Host
    PrintLogo
	$NumberOfLayers = $ObfuscationLayers.Count
    $LastLayerIndex = $NumberOfLayers - 1     
    $Plainscript = $ObfuscationLayers[$LastLayerIndex] 
	
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
    
    $heading = "Layer " + ($LastLayerIndex+1) + " - Final Script"
    Write-Host $heading -ForegroundColor yellow
    Write-Host "`r`n"	 
    Write-Host $Plainscript
	Write-Host "`r`n`r`n"
	
	$heading = "`r`n`r`n" + "Malware Hosting URLs Report:" + "`r`n"
    Write-Host $heading -ForegroundColor yellow
	
	if($Urls) { 
       foreach ( $url in $UrlsReport ) {
           Write-Host $url                 
       }

    }
	
	$heading = "`r`n`r`n" + "Variables Content:" + "`r`n"
	Write-Host  $heading -ForegroundColor yellow
	Write-Host $VariablesContent 
	
	if (($ObfuscatedScript.toLower() -match "virtualalloc") -or( $ObfuscatedScript.toLower().replace(' ','') -match "[byte[]]")) {
        $heading = "`r`n`r`n" + "Shellcode detected:" + "`r`n"
        Write-Host $heading -ForegroundColor yellow
        Write-Host $ShellcodeInfo	  
	  }
	
	
	pause 
	}

    13 { #Store and export report file
	$NumberOfLayers = $ObfuscationLayers.Count
    $LastLayerIndex = $NumberOfLayers - 1     
    $Plainscript = $ObfuscationLayers[$LastLayerIndex]
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
   
    $heading = "`r`n`r`n" +"Layer " + ($LastLayerIndex+1) + " - Final Layer"+ "`r`n"
    $result += ($heading) + "`r`n`r`n" + ($Plainscript) + "`r`n`r`n"
	   
	Clear-Host
    PrintLogo
	Write-Host "[OPTIONAL]Insert output file path (if you leave it blank, report will be saved in the PowerDecode folder)"
    $OutputFilePath = Read-Host 

    $correct = $false 
    while($correct -eq $false ) {
     try {
	    $correct = $true
		
	     if ($OutputFilePath -eq "" ) {
           $OutputFilePath = [System.IO.Path]:: "C:\"+ [GUID]::NewGuid().ToString() + ".txt";
          }
		 
		 $Logo = ReportLogo
         $Report = $Logo +$result
		if($Urls) {
			
            $heading = "`r`n`r`n" + "Malware Hosting URLs Report:" + "`r`n"
			$Report += $heading 
			$Report += $URLresult
        }
	    else {
		   $heading = "No valid URLs found."
		   $Report += $heading 
	    }
		
		$heading = "`r`n`r`n" + "Variables Content:" + "`r`n"
		$Report += $heading 
		$Report += $VariablesContent
		
		if (($ObfuscatedScript.toLower() -match "virtualalloc") -or( $ObfuscatedScript.toLower().replace(' ','') -match "[byte[]]")) {
           
		   $heading = "`r`n`r`n" + "Shellcode detected:" + "`r`n"
           $Report += $heading
		   $Report += $ShellcodeInfo
	
	    }
	    
		
		$Report  | Out-File $OutputFilePath
		 
    }
	 
     catch {
	   $correct = $false 
	   Clear-Host
       PrintLogo
       Write-Host "File path is not correct" -ForegroundColor red
	   Write-Host "[OPTIONAL]Insert output file path (if you leave it blank, report will be saved in the PowerDecode folder)"
       $OutputFilePath = Read-Host  
	
     }
    }

    Write-Host "Report file has been saved to " $OutputFilePath 	-ForegroundColor yellow
    
	if (IsRecordAlreadyStored $Hash) {
	      Write-Host "This is a well known malware sample!" -ForegroundColor magenta
          $Update = Read-Host "Do you want to update it? [Y/N]"
		  if ($Update -eq "Y") {
			
			UpdateRecordScript $Hash $MalwareType $ObfuscationLayers
			
			if($MalwareType -eq "file-based"){
			    $index=0
                foreach ( $url in $Urls){
                  $RecordUrl = BuildRecordUrl $url $UrlStatusList[$index] $Hash
                  $index++
                  UpdateRecordUrl $RecordUrl
                }
			
			
			}
          
            if($MalwareType -eq "file-less"){
                  
			    $ShellcodeData = $ShellcodeInfo + "Execution"	   
                $RecordShellcode = BuildRecordShellcode $ShellcodeData $Hash
                UpdateRecordShellcode $RecordShellcode 
            } 	 
			
		  Write-Host "Sample updated!" -ForegroundColor green
		  }
	
	}
	else {
          Write-Host "Sample was not on the repository!" -ForegroundColor yellow
	      
	      $RecordScript = BuildRecordScript $ObfuscationLayers $MalwareType $Actions $Hash 
          StoreRecordScript $RecordScript

          $index=0
          foreach ( $url in $Urls){
             $RecordUrl = BuildRecordUrl $url $UrlStatusList[$index] $Hash
             $index++
             StoreRecordUrl $RecordUrl
          }
   
          
          if($MalwareType -eq "file-less"){
             $ShellcodeData = ($ShellcodeInfo + "Execution")|Out-String		   
             $RecordShellcode = BuildRecordShellcode $ShellcodeData $Hash
			 StoreRecordShellcode $RecordShellcode 
          }
    Write-Host "Stored now!" -ForegroundColor green
	}
	pause
}
    
}

}

until($Choice -eq "0")

return  
}

#REPOSITORY MENU
function DisplayRepositoryMenu {
    param(  )

do {
 $Choice = "NONE"
 Clear-Host
 PrintLogo

 Write-Host "[1]-Query DB for a script " -ForegroundColor yellow
 Write-Host "[2]-Query DB for a URL " -ForegroundColor yellow
 Write-Host "[3]-Query DB for shellcode" -ForegroundColor yellow
 Write-Host "[4]-Malware statistics" -ForegroundColor yellow
 Write-Host "[5]-Export all original scripts " -ForegroundColor yellow
 Write-Host "[6]-Export all URLs " -ForegroundColor yellow
 Write-Host "[0]-Go back " -ForegroundColor yellow

 $Choice = Read-Host -Prompt 'Insert your choice'
 
 switch ( $Choice ) {
     1  { ScriptQuery 
	 }
     2  { UrlQuery 
	 }
	 3  { ShellcodeQuery 
	 }
	 4  { MalwareStatistics 
	 }
	 5  { ExportAllOriginalScripts 
	 }
	 6  { ExportAllURLs 
	 }
	 
 }

}

until($Choice -eq "0")

return
}


#SCRIPT QUERY
function ScriptQuery {
    param( )

Clear-Host
PrintLogo

Write-Host "Insert input file path"
$InputFilePath = Read-Host

if ( ($InputFilePath.length ) -eq 0) { 
$InputFilePath = "bad file path"
}

  while( ((Test-Path $InputFilePath) -eq $false)  ) {	 
	Clear-Host
    PrintLogo
    Write-Host "File path is not correct" -ForegroundColor red
	Write-Host "Insert input file path"
    $InputFilePath = Read-Host
    if ( ($InputFilePath.length ) -eq 0) { 
      $InputFilePath = "bad file path"
    }	
  }

$Hash = ((Get-FileHash $InputFilePath).Hash)

$CurrentPath= (Get-Location).path
$DBPath = $CurrentPath+"\MalwareRepository.db"
$Database = [LiteDB.LiteDatabase]::new($DBPath)
$Collection = $Database.GetCollection("PSscripts",[LiteDB.BsonAutoId]::Int64)

$Entry = "Hash ="+ "'"+$Hash+"'" 
$Result = $Collection.Find($Entry)

$Original = $Result.RawValue["Original"].RawValue
$Plainscript = $Result.RawValue["Plainscript"].RawValue

Clear-Host
PrintLogo

 if (($Result |Out-String) -eq ""   ) {
	
	Write-Host "No records found" -ForegroundColor red
	$Database.Dispose()
	pause
  }
  else {
	
	Write-Host "Records found:" -ForegroundColor green
	Write-Host "Original script:" -ForegroundColor yellow
	Write-Host $Original
	Write-Host "Deobfuscated script:" -ForegroundColor yellow
	Write-Host $Plainscript
	$Database.Dispose()
    pause	
  }



return  
}


#URL QUERY
function UrlQuery {
    param( )

Clear-Host
PrintLogo

Write-Host "Insert URL"
$InputUrl = Read-Host

$CurrentPath= (Get-Location).path
$DBPath = $CurrentPath+"\MalwareRepository.db"
$Database = [LiteDB.LiteDatabase]::new($DBPath)
$URLsCollection = $Database.GetCollection("URLs",[LiteDB.BsonAutoId]::Int64)

$Entry = "Url ="+ "'"+$InputUrl+"'" 
$URLResult = $URLsCollection.Find($Entry)


Clear-Host
PrintLogo

 if (($URLResult |Out-String) -eq ""   ) {
	
	Write-Host "No records found" -ForegroundColor red
	$Database.Dispose()
	pause
  }
  else {
	
	Write-Host "Record found:" -ForegroundColor green
	
	$i =0
	foreach ( $result in $URLResult) {
		
		if($i -eq "0"){
	    $OutputUrl = $result.RawValue["Url"].RawValue
        $Status    = $result.RawValue["Status"].RawValue
	    Write-Host "URL: "$OutputUrl"          Status: "$Status	
		Write-Host "`r`nFollowing malicious scripts connect to it:`r`n" -ForegroundColor yellow
        }

        $Hash = $result.RawValue["Hash"].RawValue
		
		$PSscriptsCollection = $Database.GetCollection("PSscripts",[LiteDB.BsonAutoId]::Int64)
        $Entry = "Hash ="+ "'"+$Hash+"'" 
        $ScriptResult = $PSScriptsCollection.Find($Entry)
        $Plainscript = $ScriptResult.RawValue["Plainscript"].RawValue
		
		Write-Host "Script" ($i+1)"- Hash value: "$Hash  -ForegroundColor yellow
		Write-Host $Plainscript
	$i++
	}
	
	
	$Database.Dispose()
    pause	
  }



return  
}

#SHELLCODE QUERY
function ShellcodeQuery {
    param( )

Clear-Host
PrintLogo

Write-Host "Insert Shellcode"
$InputShellcode = Read-Host

$CurrentPath= (Get-Location).path
$DBPath = $CurrentPath+"\MalwareRepository.db"
$Database = [LiteDB.LiteDatabase]::new($DBPath)
$ShellcodesCollection = $Database.GetCollection("Shellcodes",[LiteDB.BsonAutoId]::Int64)

$Entry = "Hexstring ="+ "'"+$InputShellcode+"'" 
$ShellcodeResult = $ShellcodesCollection.Find($Entry)


Clear-Host
PrintLogo

 if (($ShellcodeResult |Out-String) -eq ""   ) {
	
	Write-Host "No records found" -ForegroundColor red
	$Database.Dispose()
	pause
  }
  else {
	
	Write-Host "Record found:" -ForegroundColor green
	
	$i =0
	foreach ( $result in $ShellcodeResult) {
		
		if($i -eq "0"){
	    $OutputShellcode = $result.RawValue["Hexstring"].RawValue
	    Write-Host "Shellcode: "$OutputShellcode	
		Write-Host "`r`nFollowing malicious scripts inject it:`r`n" -ForegroundColor yellow
        }

        $Hash = $result.RawValue["Hash"].RawValue
		
		$PSscriptsCollection = $Database.GetCollection("PSscripts",[LiteDB.BsonAutoId]::Int64)
        $Entry = "Hash ="+ "'"+$Hash+"'" 
        $ScriptResult = $PSScriptsCollection.Find($Entry)
        $Plainscript = $ScriptResult.RawValue["Plainscript"].RawValue
		
		Write-Host "Script" ($i+1)"- Hash value: "$Hash  -ForegroundColor yellow
		Write-Host $Plainscript
	$i++
	}
	
	
	$Database.Dispose()
    pause	
  }



return  
}



#MALWARE STATISTICS
function MalwareStatistics {
    param( )

Clear-Host
PrintLogo

$CurrentPath= (Get-Location).path
$DBPath = $CurrentPath+"\MalwareRepository.db"
$Database = [LiteDB.LiteDatabase]::new($DBPath)
$PSscriptsCollection = $Database.GetCollection("PSscripts",[LiteDB.BsonAutoId]::Int64)
$URLsCollection = $Database.GetCollection("URLs",[LiteDB.BsonAutoId]::Int64)
$ShellcodesCollection = $Database.GetCollection("Shellcodes",[LiteDB.BsonAutoId]::Int64)

#Total malwares
$Entry = "_id > 0" 
$TotalResult = $PSscriptsCollection.Find($Entry)
$Totalcount = 0

foreach ($result in $TotalResult ) {
	$Totalcount++
}

#Fileless malwares
$Entry = "Type = 'file-less'" 
$FilelessResult = $PSscriptsCollection.Find($Entry)
$Filelesscount = 0

foreach ($result in $FilelessResult ) {
	$Filelesscount++
}

#Filebased malwares
$Entry = "Type = 'file-based'" 
$FilebasedResult = $PSscriptsCollection.Find($Entry)
$Filebasedcount = 0

foreach ($result in $FilebasedResult ) {
	$Filebasedcount++
}
#Fileless malwares
$Entry = "Type = 'file-less'" 
$FilelessResult = $PSscriptsCollection.Find($Entry)
$Filelesscount = 0

foreach ($result in $FilelessResult ) {
	$Filelesscount++
}


#Base64 obfuscation layers
$Entry = "Base64 > '0'" 
$Base64Result = $PSscriptsCollection.Find($Entry)


$Base64count = 0

foreach ($result in $Base64Result ) {
	$string = $result.RawValue["Base64"].RawValue
	
	$n= [int]$string 
	$Base64count = $Base64count + $n 
	
}

#String-based layers
$Entry = "StringBased > '0'" 
$StringBasedResult = $PSscriptsCollection.Find($Entry)


$StringBasedcount = 0

foreach ($result in $StringBasedResult ) {
	$string = $result.RawValue["StringBased"].RawValue
	
	$n= [int]$string 
	$StringBasedcount = $StringBasedcount + $n 
	
}

#Encoded layers count
$Entry = "Encoded > '0'" 
$EncodedResult = $PSscriptsCollection.Find($Entry)


$Encodedcount = 0

foreach ($result in $EncodedResult ) {
	$string = $result.RawValue["Encoded"].RawValue
	
	$n= [int]$string 
	$Encodedcount = $Encodedcount + $n 
	
}

#Compressed layers count
$Entry = "Compressed > '0'" 
$CompressedResult = $PSscriptsCollection.Find($Entry)


$Compressedcount = 0

foreach ($result in $CompressedResult ) {
	$string = $result.RawValue["Compressed"].RawValue
	
	$n= [int]$string 
	$Compressedcount = $Compressedcount + $n 
	
}

$FilebasedRate = [math]::Round(  (100*($Filebasedcount/$Totalcount)) ,2 )
$FilelessRate =  [math]::Round(     (100*($Filelesscount/$Totalcount)) , 2 ) 
$TotalLayersCount =  $Base64count + $StringBasedcount + $Encodedcount + $Compressedcount  
$Base64Rate =  [math]::Round(       (100*($Base64count/$TotalLayersCount)) , 2 )
$StringbasedRate =  [math]::Round(  (100*($StringBasedcount/$TotalLayersCount)) , 2 )
$EncodedRate =  [math]::Round(  (100*($Encodedcount/$TotalLayersCount)) , 2 )
$CompressedRate =  [math]::Round(   (100*($Compressedcount/$TotalLayersCount)) ,2 )


#URLs total count
$Entry = "_id > 0" 
$TotalResult = $URLsCollection.Find($Entry)


$UrlList = New-Object System.Collections.Generic.List[System.Object]
$UrlStatusList = New-Object System.Collections.Generic.List[System.Object]

foreach ($result in $TotalResult ) {
	$url    = $result.RawValue["Url"].RawValue
	$status = $result.RawValue["Status"].RawValue
	$UrlList.add($url)
	$UrlStatusList.add($url + " - "+$status )
	
}

$UrlChart =  $UrlStatusList | Group-Object | Sort-Object -Property Count -Descending | Select Count,Name
$UrlDistinctList = $UrlList | Group-Object | Sort-Object -Property Count -Descending | Select Name

$UrlsCount = $UrlChart.length


#Active URLs count [status:200]
$Entry = "Status = '[200: Url is Active]'" 
$ActiveResult = $URLsCollection.Find($Entry)

$ActiveUrlList = New-Object System.Collections.Generic.List[System.Object]

foreach ($result in $ActiveResult ) {
	$url    = $result.RawValue["Url"].RawValue
	$ActiveUrlList.add($url)
}

$ActiveUrlDistinctList = $ActiveUrlList | Group-Object | Sort-Object -Property Count -Descending | Select Name
$ActiveUrlsCount = $ActiveUrlDistinctList.length
$ActivityRate = [math]::Round(   (100*($ActiveUrlsCount/$UrlsCount)) ,2 )

#Offline URLs count [status:404]
$Entry = "Status = '[404: Not Found]'" 
$OfflineResult = $URLsCollection.Find($Entry)

$OfflineUrlList = New-Object System.Collections.Generic.List[System.Object]

foreach ($result in $OfflineResult ) {
	$url    = $result.RawValue["Url"].RawValue
	$OfflineUrlList.add($url)
}

$OfflineUrlDistinctList = $OfflineUrlList | Group-Object | Sort-Object -Property Count -Descending | Select Name
$OfflineUrlsCount = $OfflineUrlDistinctList.length
$OfflineRate = [math]::Round(   (100*($OfflineUrlsCount/$UrlsCount)) ,2 )


Write-Host "Malware Statistics:`r`n" -ForegroundColor yellow

Write-Host "Malware samples stored: " $Totalcount 
Write-Host "File-based malwares: " $Filebasedcount  "(" $FilebasedRate "%)"
Write-Host "File-less malwares: " $Filelesscount "(" $FilelessRate "%)"
Write-Host "Base64 obfuscation layers: " $Base64count "(" $Base64Rate "%)"
Write-Host "String-based obfuscation layers: " $StringBasedcount "(" $StringbasedRate "%)"
Write-Host "Encoded obfuscation layers: " $Encodedcount "(" $EncodedRate "%)"
Write-Host "Compressed obfuscation layers: " $Compressedcount "(" $CompressedRate "%)"
Write-Host "URLs stored: " $UrlsCount
Write-Host "Active URLs [status: 200]:" $ActiveUrlsCount "(" $ActivityRate "%)"
Write-Host "Offline URLs [status: 404]:" $OfflineUrlsCount "(" $OfflineRate "%)"
Write-Host "`r`n"


$Database.Dispose()
pause

return
}

#EXPORT ALL SCRIPTS
function ExportAllOriginalScripts {
    param( )

Clear-Host
PrintLogo

Write-Host "Insert output folder path"
$OutputFolderPath = Read-Host
while( (Test-Path $OutputFolderPath) -eq $false ) {	 
	Clear-Host
    PrintLogo
    Write-Host "Folder path is not correct" -ForegroundColor red
	Write-Host "Insert input folder path"
    $OutputFolderPath = Read-Host 
}

Clear-Host
PrintLogo

Write-Host "Exporting..."  -ForegroundColor yellow
$CurrentPath= (Get-Location).path
$DBPath = $CurrentPath+"\MalwareRepository.db"
$Database = [LiteDB.LiteDatabase]::new($DBPath)
$PSscriptsCollection = $Database.GetCollection("PSscripts",[LiteDB.BsonAutoId]::Int64)

$Entry = "_id > 0" 
$TotalResult = $PSscriptsCollection.Find($Entry)

$n=1
foreach ($result in $TotalResult ) {
	$Original = $result.RawValue["Original"].RawValue
	$number = $n.toString()
	$OutputFilePath = $OutputFolderPath +"\"+$number+".txt"
	$Original | Out-File $OutputFilePath
    $n++	
}

$message = "All scripts have been exported on "+ $OutputFolderPath  
Write-Host $message -ForegroundColor green

$Database.Dispose()
pause

return
}

#EXPORT ALL URLs
function ExportAllURLs {
    param( )

Clear-Host
PrintLogo

Write-Host "Insert output folder path"
$OutputFolderPath = Read-Host
while( (Test-Path $OutputFolderPath) -eq $false ) {	 
	Clear-Host
    PrintLogo
    Write-Host "Folder path is not correct" -ForegroundColor red
	Write-Host "Insert input folder path"
    $OutputFolderPath = Read-Host 
}

Clear-Host
PrintLogo

Write-Host "Exporting..."  -ForegroundColor yellow
$CurrentPath= (Get-Location).path
$DBPath = $CurrentPath+"\MalwareRepository.db"
$Database = [LiteDB.LiteDatabase]::new($DBPath)
$URLsCollection = $Database.GetCollection("URLs",[LiteDB.BsonAutoId]::Int64)

$Entry = "_id > 0" 
$TotalResult = $URLsCollection.Find($Entry)


$UrlList = New-Object System.Collections.Generic.List[System.Object]

foreach ($result in $TotalResult ) {
	$url    = $result.RawValue["Url"].RawValue
	$status    = $result.RawValue["Status"].RawValue
	$UrlList.add($url + "   -   "+ $status)
}

$UrlRanking =  $UrlList | Group-Object | Sort-Object -Property Count -Descending | Select Count,Name


$OutputFilePath = $OutputFolderPath +"\MaliciousUrlsRanking.txt"
$UrlRanking | Out-File $OutputFilePath


$message = "All URLs have been exported on "+ $OutputFilePath  
Write-Host $message -ForegroundColor green

$Database.Dispose()
pause

return
}

#PowerDecode module import
Import-Module ./package\PowerDecode.psd1

#LiteDB library import
Add-Type -Path "litedb.5.0.11\lib\net45\LiteDB.dll"


#START GUI
DisplayMainMenu