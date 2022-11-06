#MAIN MENU
function DisplayMainMenu {
    param( )

$Settings = New-Object System.Collections.Generic.List[System.Object]
$Settings.Add("Disabled")  #Storage mode [Enabled/Disabled]
$Settings.Add("Disabled") #Step by step mode [Enabled/Disabled]
$Settings.Add("Not set")  #VirusTotal API key 
$Settings.Add("2")        #Execution Timeout 

#Cleaning Temp folder
if (Test-Path ([System.IO.Path]::GetTempPath() +"Alias.txt") ) {
	Remove-Item ([System.IO.Path]::GetTempPath() +"Alias.txt")
}

do {
 $Choice = "NONE"
 Clear-Host
 PrintLogo
 Write-Host "[1]-Automatic decode mode " -ForegroundColor yellow
 Write-Host "[2]-Manual decode mode " -ForegroundColor yellow
 Write-Host "[3]-Malware repository " -ForegroundColor yellow
 Write-Host "[4]-Settings " -ForegroundColor yellow
 Write-Host "[5]-About " -ForegroundColor yellow
 Write-Host "[0]-Exit " -ForegroundColor yellow

 $Choice = Read-Host -Prompt 'Insert your choice'
 
 switch ( $Choice ) {
     1  { DisplayAutoMenu }
     2  { DisplayManualMenu}
	 3  { DisplayRepositoryMenu }
	 4  { $Settings = DisplaySettingsMenu $Settings }
	 5  { DisplayAboutMenu}
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

Write-Host "Select file to upload (file type must be .txt or .ps1)." 
$InputFilePath = DisplayDialogWindowFile

if ( $InputFilePath -eq ""){
 Write-Host "No file uploaded" -ForegroundColor red
 pause
 break;
}

Write-Host "[OPTIONAL]Insert output file path (default path: PowerDecode folder)"
    $OutputFolderPath = DisplayDialogWindowFolder
    $OutputFilePath = ""
    if ( $OutputFolderPath -ne ""){
       $OutputFileName = ((($InputFilePath.split("\"))[ -1 ]).split("."))[0]
       $OutputFilePath = $OutputFolderPath+"\PowerDecode_report_" + [GUID]::NewGuid().ToString() + ".txt"
    }
    else {
		$DefaultPath = (Get-Location).Path
		$OutputFilePath = $DefaultPath + [System.IO.Path]:: "C:\"+"\PowerDecode_report_" +[GUID]::NewGuid().ToString() + ".txt";
	}
   
	PowerDecode $InputFilePath $OutputFilePath $Settings[0] $Settings[2] $Settings[3]
   

	$Message = "Decoding terminated. Report file has been saved to " + $OutputFilePath
    Write-Host $Message -ForegroundColor green

pause

return  
}

#MULTIPLE AUTO DECODE
function MultipleAutoDecode {
	param( )
	
Clear-Host
PrintLogo

Write-Host "Select folder path where files are located" 
$InputFolderPath = DisplayDialogWindowFolder

if ( $InputFolderPath -eq ""){
 Write-Host "No folder selected" -ForegroundColor red
 pause
 break;
}

Write-Host "[OPTIONAL]Insert output folder path (default path: PowerDecode folder)"
$OutputFolderPath = DisplayDialogWindowFolder

$n=1 
foreach ( $file in (Get-Childitem -Name $InputFolderPath)   ){
     $number = $n.toString(); 
     $InputFilePath = Join-Path -path $InputFolderPath -childpath $file
     if ($OutputFolderPath -ne ""){
	    $OutputFilePath = $OutputFolderPath +"\"+ $number + ".txt"
	 } 
	 else {  
	    $DefaultPath = (Get-Location).Path
	    $OutputFilePath = $DefaultPath +"\"+ $number + ".txt"
	 }
	    PowerDecode $InputFilePath $OutputFilePath $Settings[0] $Settings[2] $Settings[3]
		
		
     $n++; 		

  if ($Settings[1] -eq "Enabled"){
     
 	    $Message = "Decoding terminated. Report file has been saved to "+ $OutputFilePath
	    Write-Host $Message  -ForegroundColor green
		
    pause
  }
}
	
return

}


#MANUAL MENU
function DisplayManualMenu {
    param(  )

Clear-Host
PrintLogo

Write-Host "Select file to upload (file type must be .txt or .ps1)." 
$InputFilePath = DisplayDialogWindowFile

if ( $InputFIlePath -eq ""){
 Write-Host "No file uploaded" -ForegroundColor red
 pause
 break;
}

$ObfuscatedScript = GetScriptFromFile $InputFilePath

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
Write-Host "[1]-Decode script by regex" -ForegroundColor yellow
Write-Host "[2]-Decode script by IEX overriding" -ForegroundColor yellow
Write-Host "[3]-Decode base64 encoding" -ForegroundColor yellow
Write-Host "[4]-Decode deflate payload" -ForegroundColor yellow
Write-Host "[5]-Decode GZIP payload" -ForegroundColor yellow
Write-Host "[6]-Replace a string(raw)" -ForegroundColor yellow
Write-Host "[7]-Replace a string(evaluate)" -ForegroundColor yellow
Write-Host "[8]-URLs analysis" -ForegroundColor yellow
Write-Host "[9]-Get variables content" -ForegroundColor yellow
Write-Host "[10]-Shellcode check" -ForegroundColor yellow
Write-Host "[11]-Get VirusTotal rating" -ForegroundColor yellow
Write-Host "[12]-Undo last decoding task" -ForegroundColor yellow
Write-Host "[13]-Report preview" -ForegroundColor yellow
Write-Host "[14]-Store and export report file" -ForegroundColor yellow
Write-Host "[0]-Go back " -ForegroundColor yellow

$Choice = Read-Host -Prompt 'Insert your choice'

switch ( $Choice )
 {
    

	1   { #Deobfuscating by regex	
    $InitialScript = $ObfuscatedScript	
	
	While ( $true ) {
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
	    Write-Host "Insert a substring to deobfuscate" -ForegroundColor yellow
		Write-Host "  @: select all" -ForegroundColor yellow
		Write-Host "  #: terminate the task" -ForegroundColor yellow
		
	    $Substring = Read-Host
       
	    if ($Substring -eq "#") {break;}
	    if ($Substring -eq "@" ) {$Substring = $ObfuscatedScript}
	  
	  
	    $DeobfuscatedString = DeobfuscateByRegex  $Substring
		
		Write-Host "Your entry:" -ForegroundColor yellow
        Write-Host $Substring  		
	    Write-Host "will be replaced with:" -ForegroundColor yellow
	    Write-Host $DeobfuscatedString

	    if (GoodSyntax $DeobfuscatedString ) { 
           Write-Host "Syntax will remain correct " -ForegroundColor green 
          }
          else {
           Write-Host "There are syntax errors" -ForegroundColor red
          }
          Write-Host "Continue ? [y/n]"
		  $Response = Read-Host  
		
         if ($Response -eq "y") { 
	   	  $ObfuscatedScript = $ObfuscatedScript.replace( $Substring , $DeobfuscatedString ) 
		 }
	 
	 }
		
	if ( ( $ObfuscatedScript -ne $InitialScript) ) {
          $ObfuscationLayers.Add($ObfuscatedScript)  
           
     }
	
	}
	
    2   { #Deobfuscating by IEX overriding
	     
		while($true) {
			
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
	        Write-Host "Insert a substring to deobfuscate" -ForegroundColor yellow
		    Write-Host "  @: select all" -ForegroundColor yellow
		    Write-Host "  #: terminate the task" -ForegroundColor yellow
		
	        $Substring = Read-Host
       
	       if ($Substring -eq "#" ) {break;}
	       if ($Substring -eq "@" ) {$Substring = $ObfuscatedScript}
		   if ($SubString -ne ""  ) {
			
	
        	 try {
	            $DeobfuscatedString = "#Deobfuscation error"
				$DeobfuscatedString = (DeobfuscateByOverriding  $Substring $Settings[3] ) |Out-String 
             }
            catch{}		   
	      
		  
		    if (  ($DeobfuscatedString -ne "" ) -and($DeobfuscatedString -ne $Substring) ) {
           
		     $DeobfuscatedScript = $ObfuscatedScript.replace($Substring, $DeobfuscatedString)
		     $ObfuscationLayers.Add($DeobfuscatedScript)  
             $ObfuscatedScript = $DeobfuscatedScript  
            }
	
	
	        }
		}
	
	
	}
	
    3   { #Decode base64
	
	    while($true) {
	
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
	        Write-Host "Insert a substring to decode" -ForegroundColor yellow
		    Write-Host "  @: select all" -ForegroundColor yellow
		    Write-Host "  #: terminate the task" -ForegroundColor yellow
		
	        $Substring = Read-Host
       
	       if ($Substring -eq "#" ) {break;}
	       if ($Substring -eq "@" ) {$Substring = $ObfuscatedScript}
		   if ($SubString -ne ""  ) {
		 
		       try{
			       $DeobfuscatedString = "#Error decoding base64 format"
				   $DeobfuscatedString = DecodeBase64 $Substring
		           $DeobfuscatedString = (CleanScript $DeobfuscatedString) |Out-String
		        }
	           catch{}

             if ( $DeobfuscatedString.length -gt 0 ) {
			 $DeobfuscatedScript = $ObfuscatedScript.replace($Substring, $DeobfuscatedString)	 
             $ObfuscationLayers.Add($DeobfuscatedScript)  
             $ObfuscatedScript = $DeobfuscatedScript  
             }
	
		   }
	    }
	
	}
	
	4   { #Decode deflate playload
		
		while($true) {
		
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
	        Write-Host "Insert a deflate payload to decode" -ForegroundColor yellow
		    Write-Host "  @: select all" -ForegroundColor yellow
		    Write-Host "  #: terminate the task" -ForegroundColor yellow
		
	        $Substring = Read-Host
			
		   if ($Substring -eq "#" ) {break;}
	       if ($Substring -eq "@" ) {$Substring = $ObfuscatedScript}
		   if ($SubString -ne ""  ) {
		
	
		    $DeobfuscatedString = DecodeDeflate $SubString
		
	  	      if ( $DeobfuscatedString.length -gt 0 ) {
				 $DeobfuscatedScript = $ObfuscatedScript.replace($Substring, $DeobfuscatedString) 
                 $ObfuscationLayers.Add($DeobfuscatedScript)  
                 $ObfuscatedScript = $DeobfuscatedScript  
                 
	          }
	
		    }
	
		}
	
	
	}
	
	5 { #Decode GZIP payload
	   
	   while($true) {
		
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
	        Write-Host "Insert a GZIP payload to decode" -ForegroundColor yellow
		    Write-Host "  @: select all" -ForegroundColor yellow
		    Write-Host "  #: terminate the task" -ForegroundColor yellow
		
	        $Substring = Read-Host
			
		   if ($Substring -eq "#" ) {break;}
	       if ($Substring -eq "@" ) {$Substring = $ObfuscatedScript}
		   if ($SubString -ne ""  ) {
		
		    $DeobfuscatedString = DecodeGzip $SubString
		
	  	      if ( $DeobfuscatedString.length -gt 0 ) {
				 $DeobfuscatedScript = $ObfuscatedScript.replace($Substring, $DeobfuscatedString) 
                 $ObfuscationLayers.Add($DeobfuscatedScript)  
                 $ObfuscatedScript = $DeobfuscatedScript  
                 
	          }
	
		    }
	
		}
        
	}
	
	
	6   { #Replace a string (raw)
    $InitialScript = $ObfuscatedScript
	
	While ( $true ) {
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
    $InitialScript = $ObfuscatedScript	
	While ( $true ) {
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
	      $EvaluatedString = ExecString $String
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
          
		  #Bxor check
		  $BxorChoice = "n"
	      $BxorPattern = [regex] "-bxor\s(\d{1,})"
	      $BxorMatches = $BxorPattern.matches($ObfuscatedScript.toLower())
		  
		  if ( $BxorMatches.Count -gt 0) {
		    $BxorKeyString  = (($BxorMatches[0]).value).replace("-bxor","").replace(" ","")
		    $BxorKey = [int] $BxorKeyString
		  	Write-Host "Shellcode detected seems to be obfuscated by bxor with value "$BxorKey -ForegroundColor yellow
		    Write-Host "Do you want to take this into account? [y/n]" -ForegroundColor yellow
		    
			$BxorChoice = Read-Host
			Clear-Host
            PrintLogo
			 
		  }
		  
		    if ($BxorChoice -eq "y") {
				$ShellcodeInfo = ExtractShellcode $ObfuscatedScript $BxorKey
	
			}
			else {
			    Write-Host "Please insert the bxor operand decimal vaue ( press Enter to ignore bxor )" -ForegroundColor yellow
			    $BxorChoice = Read-Host
				if ($BxorChoice -eq "") {
			        $ShellcodeInfo = ExtractShellcode $ObfuscatedScript
				}
				else{
					$BxorKey = [int] $BxorChoice
					$ShellcodeInfo = ExtractShellcode $ObfuscatedScript   $BxorKey
				}
            }

    	Clear-Host
        PrintLogo
		$heading = "`r`n`r`n" + "Shellcode detected:" + "`r`n"
        Write-Host $heading -ForegroundColor yellow
        Write-Output $ShellcodeInfo	  
	  }
	  else{
		$ErrorMessage = "Nothing found"
	    Write-Host $ErrorMessage  -ForegroundColor red
	  }
	pause
	}
	
	11   { #Get VirusTotal rating
	
	Clear-Host
    PrintLogo
	
	$heading = "`r`n`r`n" + "VirusTotal rating:" + "`r`n" 
    Write-Host $heading -ForegroundColor yellow
    $VTrating =  GetVirusTotalReport $Hash $Settings[2]
    Write-Output $VTrating
	
	pause
	}
	
	12   { #Undo last decoding task
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
	
	13   { #Report preview
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
	  
	  if($VTrating){
        $heading = "`r`n`r`n" + "VirusTotal rating:" + "`r`n" 
        Write-Host $heading -ForegroundColor yellow 
        Write-Output $VTrating 
      }
	
	pause 
	}

    14 { #Store and export report file
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
	
	Write-Host "[OPTIONAL]Insert output file path (default path: PowerDecode folder)"
    $OutputFolderPath = DisplayDialogWindowFolder
    $OutputFilePath = ""
    if ( $OutputFolderPath -ne ""){
       $OutputFileName = ((($InputFilePath.split("\"))[ -1 ]).split("."))[0]
       $OutputFilePath = $OutputFolderPath+"\PowerDecode_report_" + [GUID]::NewGuid().ToString() + ".txt"
    }
    else {
		$DefaultPath = (Get-Location).Path
		$OutputFilePath = $DefaultPath + [System.IO.Path]:: "C:\"+"\PowerDecode_report_" +[GUID]::NewGuid().ToString() + ".txt";
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
		
		if($VTrating){
         
		  $heading = "`r`n`r`n" + "VirusTotal rating:" + "`r`n"
          $Report += $heading
          $Report += $VTrating 
          $Report += "`r`n" 
        
		}
	    
		
		$Report  | Out-File $OutputFilePath
	
   


	$Message = "Decoding terminated. Report file has been saved to: " + $OutputFilePath
    Write-Host $Message -ForegroundColor green


	

    
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
                  
			    $ShellcodeData = $ShellcodeInfo + "##########"	   
                $RecordShellcode = BuildRecordShellcode $ShellcodeData $Hash
                UpdateRecordShellcode $RecordShellcode 
            } 	 
			
		  Write-Host "Sample updated!" -ForegroundColor green
		  }
	
	}
	else {
          
		  Write-Host "Sample was not on the repository!" -ForegroundColor yellow

          $StorageMode = $Settings[0]	      
	      if(  $StorageMode -eq "Enabled") {
		  
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
		  
		  else {
		     Write-Host "Not stored due to storage mode set to: " -ForegroundColor yellow -nonewline
             Write-Host $StorageMode -ForegroundColor red 			 
		  }
	
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
 Write-Host "[3]-Query DB for a shellcode" -ForegroundColor yellow
 Write-Host "[4]-Malware statistics" -ForegroundColor yellow
 Write-Host "[5]-Export all original scripts " -ForegroundColor yellow
 Write-Host "[6]-Export all URLs " -ForegroundColor yellow
 Write-Host "[7]-Export all Shellcodes " -ForegroundColor yellow
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
	 7  { ExportAllShellcodes 
	 }
	 
 }

}

until($Choice -eq "0")

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

 
 Write-Host "[3]-Set VirusTotal API key, current key: " -ForegroundColor yellow -nonewline
 Write-Host $Settings[2]
 
 Write-Host "[4]-Set execution timeout, current value (seconds): " -ForegroundColor yellow -nonewline
 Write-Host $Settings[3]

 Write-Host "[0]-Go back " -ForegroundColor yellow

 $Choice = Read-Host -Prompt 'Insert your choice'
 
 switch ( $Choice ) {
     1  { 
	    if( $Settings[0]  -eq "Enabled") { $Settings[0] = "Disabled" } else{ $Settings[0] = "Enabled" }
	 }
     
	 2  {  
	    if( $Settings[1]  -eq "Enabled") { $Settings[1] = "Disabled" } else{ $Settings[1] = "Enabled" }
	 }
	 
	 3  {
		Clear-Host
		PrintLogo
		
		Write-Host "Insert your VirusTotal API key"
		 
		$Settings[2] = Read-Host 
	 }
	 
	  4  {
		Clear-Host
		PrintLogo
		
		Write-Host "Insert new execution timeout value"
		 
		$Settings[3] = Read-Host 
	 }
	
 
 
 
 
 }

}

until($Choice -eq "0")



return  $Settings
}

#ABOUT MENU
function DisplayAboutMenu {
    param()

Clear-Host
PrintLogo


$about = @'

-Version    : 2.6.1  
-Author     : Giuseppe Malandrone 
-Email      : giusemaland@gmail.com
-Linkedin   : linkedin.com/in/giuseppe-malandrone-8b3938130/
'@

$license = @'
                    GNU GENERAL PUBLIC LICENSE
                       Version 3, 29 June 2007

 Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>

'@

Write-Host $about
Write-Host "`n`r"
Write-Host $license -ForegroundColor yellow  
Pause
return
}

#PowerDecode module import
Import-Module ./package\PowerDecode.psd1

#LiteDB library import
Add-Type -Path "litedb.5.0.11\lib\net45\LiteDB.dll"

#Capstone library import
Add-Type -Path "capstone\lib\capstone.dll"


#START GUI
DisplayMainMenu