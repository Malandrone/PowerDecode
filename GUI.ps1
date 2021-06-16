#MAIN MENU
function DisplayMainMenu {
    param(  )

do {
$Choice = "NONE"
Clear-Host
PrintLogo
Write-Host "[1]-Automatic decode mode " -ForegroundColor yellow
Write-Host "[2]-Manual decode mode " -ForegroundColor yellow
Write-Host "[0]-Exit " -ForegroundColor yellow


$Choice = Read-Host -Prompt 'Insert your choice'
 

switch ( $Choice )
 {
    1   { DisplayAutoMenu }
    2  { DisplayManualMenu}
}

}

until($Choice -eq "0")



return  
}


#AUTO MENU
function DisplayAutoMenu {
    param(  )

do {
$Choice = "NONE"
Clear-Host
PrintLogo
Write-Host "[1]-Decode a script from a single file" -ForegroundColor yellow
Write-Host "[2]-Decode multiple scripts from a folder (fast mode) " -ForegroundColor yellow
Write-Host "[3]-Decode multiple scripts from a folder (step-by-step) " -ForegroundColor yellow
Write-Host "[0]-Go back " -ForegroundColor yellow



$Choice = Read-Host -Prompt 'Insert your choice'

switch ( $Choice )
 {
    1  { SingleAutoDecode }
    2  { MultipleAutoDecode1}
	3  { MultipleAutoDecode2}
	
}

}

until($Choice -eq "0")



return  
}



#SINGLE AUTO DECODE 
function SingleAutoDecode {
    param(  )

Clear-Host
PrintLogo

Write-Host "Insert input file path ( file type must be .txt or .ps1 )"
$InputFilePath = Read-Host 
Write-Host "[OPTIONAL]Insert output file path (if you leave it blank, report will be saved in the PowerDecode folder)"
$OutputFilePath = Read-Host 


$correct = $false 
while($correct -eq $false ) {
 try {
	$correct = $true
	PowerDecode $InputFilePath $OutputFilePath
 }
 catch {
	$correct = $false 
	Clear-Host
    PrintLogo
    Write-Host "File path is not correct" -ForegroundColor red
	Write-Host "Insert input file path ( file type must be .txt or .ps1 )"
    $InputFilePath = Read-Host 
    Write-Host "[OPTIONAL]Insert output file path (if you leave it blank, report will be saved in the PowerDecode folder)"
    $OutputFilePath = Read-Host  
	
 }
}


if($OutputFilePath -eq "") {
	$DefaultPath = (Get-Location).Path
	Write-Host "Decoding terminated. Report file has been saved to " $DefaultPath  -ForegroundColor yellow
}
else{
Write-Host "Decoding terminated. Report file has been saved to " $OutputFilePath 	-ForegroundColor yellow
}
pause

return  
}

#MULTIPLE AUTO DECODE (FAST)
function MultipleAutoDecode1{
	param(  )
	
Clear-Host
PrintLogo

Write-Host "Insert input folder path"
$InputFolderPath = Read-Host 
Write-Host "[OPTIONAL]Insert output folder path (if you leave it blank, report will be saved in the PowerDecode folder)"
$OutputFolderPath = Read-Host

try {
	$n=1 
    foreach ( $file in (Get-Childitem -Name $InputFolderPath)   ){

     $number = $n.toString(); 
     $InputFilePath = Join-Path -path $InputFolderPath -childpath $file
     if ($OutputFolderPath -ne ""){$OutputFilePath = $OutputFolderPath +"\"+ $number + ".txt"} 


     PowerDecode $InputFilePath $OutputFilePath 
     $n++; 		
    }
	
}

catch{}



return

}

#MULTIPLE AUTO DECODE (STEP BY STEP)
function MultipleAutoDecode2{
	param(  )
	
Clear-Host
PrintLogo

Write-Host "Insert input folder path"
$InputFolderPath = Read-Host 
Write-Host "[OPTIONAL]Insert output folder path (if you leave it blank, report will be saved in the PowerDecode folder)"
$OutputFolderPath = Read-Host
try{
$n=1 
foreach ( $file in (Get-Childitem -Name $InputFolderPath)   ){

 $number = $n.toString(); 
 $InputFilePath = Join-Path -path $InputFolderPath -childpath $file
 if ($OutputFolderPath -ne ""){$OutputFilePath = $OutputFolderPath +"\"+ $number + ".txt"} 


 PowerDecode $InputFilePath $OutputFilePath 
 $n++; 	

 if($OutputFolderPath -eq "") {
 	$DefaultPath = (Get-Location).Path
 	Write-Host "Decoding terminated. Report file has been saved to "$DefaultPath  -ForegroundColor red
 }
 else{
 Write-Host "Decoding terminated. Report file has been saved to " $OutputFilePath 	-ForegroundColor yellow
 }


 pause	
 }
}

catch{}

return

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



do {
$Choice = "NONE"
Clear-Host
PrintLogo
Write-Host "Current script" -ForegroundColor green 
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
Write-Host "[8]-Undo last task" -ForegroundColor yellow
Write-Host "[9]-View obfuscation layers" -ForegroundColor yellow
Write-Host "[10]-Export report file" -ForegroundColor yellow

Write-Host "[0]-Go back " -ForegroundColor yellow


$Choice = Read-Host -Prompt 'Insert your choice'

switch ( $Choice )
 {
    1   { #Deobfuscating by regex
	     try{
			 $DeobfuscatedScript = DeobfuscateByRegex  $ObfuscatedScript 
		   }
	     catch{}

        if ( $DeobfuscatedScript -ne $ObfuscatedScript ) {
          $ObfuscationLayers.Add($DeobfuscatedScript)  
          $ObfuscatedScript = $DeobfuscatedScript  
            }
      
	
	
	}
    2   { #Deobfuscating by IEX overriding
	     try {
	          $DeobfuscatedScript = DeobfuscateByOverriding  $ObfuscatedScript
           }
         catch{}		   
	     if ( (GoodSyntax $DeobfuscatedScript) -and ($DeobfuscatedScript -ne "" ) -and($DeobfuscatedScript -ne $ObfuscatedScript) ) {
          $ObfuscationLayers.Add($DeobfuscatedScript)  
          $ObfuscatedScript = $DeobfuscatedScript  
            }
	
	
	}
	
    3   { #Decode base64 
	    
	   if(IsBase64 $ObfuscatedScript ) {
        if( !(IsStringBased $ObfuscatedScript) -and !(IsCompressed $ObfuscatedScript) -and !(IsEncoded $ObfuscatedScript)  ){
       
		   
		 try{
			 $DeobfuscatedScript = DecodeBase64 $ObfuscatedScript 
		   }
	     catch{}

        if ( $DeobfuscatedScript -ne $ObfuscatedScript ) {
          $ObfuscationLayers.Add($DeobfuscatedScript)  
          $ObfuscatedScript = $DeobfuscatedScript  
            }
		 
		 
		
	    
        
         }
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
		}
		catch{
			
		  Write-Host "Error,payload was not a valid format"  -ForegroundColor red
		  pause
		
		}
		
		if ( ( GoodSyntax $DeobfuscatedScript) -and ($DeobfuscatedScript -ne "") ) {
          $ObfuscationLayers.Add($DeobfuscatedScript)  
          $ObfuscatedScript = $DeobfuscatedScript  
          Write-Host "Payload decoded successfully"  -ForegroundColor green
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
		}
		catch{
			
		  Write-Host "Error,payload was not a valid format"  -ForegroundColor red
		  pause
		
		}
		
		if ( ( GoodSyntax $DeobfuscatedScript) -and ($DeobfuscatedScript -ne "") ) {
          $ObfuscationLayers.Add($DeobfuscatedScript)  
          $ObfuscatedScript = $DeobfuscatedScript  
          Write-Host "Payload decoded successfully"  -ForegroundColor green
		  pause
			}
        
		
	}
	
	
	6   { #Replace a string (raw)
	
	Clear-Host
    PrintLogo 
	Write-Host "Current script" -ForegroundColor green 
    Write-Output $ObfuscatedScript  
    Write-Host "`n`r"
	Write-Host "Insert string to replace" -ForegroundColor yellow
	$String = Read-Host
	Write-Host "Insert replace" -ForegroundColor yellow
	$Replace = Read-Host
	
	 try {
			
             
			    $NewScript = $ObfuscatedScript.replace( $String , $Replace)
               
		   }
         catch{}		   
	     if ( (GoodSyntax $NewScript) -and($NewScript -ne $ObfuscatedScript) ) {
          $ObfuscationLayers.Add($NewScript)  
          $ObfuscatedScript = $NewScript  
          Clear-Host
          PrintLogo 
	      Write-Host "Successfully replaced" -ForegroundColor green
          pause		  
			
			}
			
			else {
			Clear-Host
            PrintLogo 
	        Write-Host "Error: replace not valid" -ForegroundColor red
            pause
			
			
			}
	
	
	
	}
	
	7   { #Replace a string (evaluate) 
	
	Clear-Host
    PrintLogo 
	Write-Host "Current script" -ForegroundColor green 
    Write-Output $ObfuscatedScript  
    Write-Host "`n`r"
	Write-Host "Insert a string to evaluate" -ForegroundColor yellow
	$String = Read-Host
	
	$EvaluatedString = IEX $String 
	
	try {
			
                if (  $EvaluatedString -ne ""  ){
			    $NewScript = $ObfuscatedScript.replace( $String , $EvaluatedString)
                }
		   }
         catch{}		   
	     if ( (GoodSyntax $NewScript ) -and($NewScript -ne $ObfuscatedScript) ) {
          $ObfuscationLayers.Add($NewScript)  
          $ObfuscatedScript = $NewScript  
          Clear-Host
          PrintLogo
          Write-Host "String evaluation returned the following string and has been successfully replaced" -ForegroundColor green 
	      Write-Output $EvaluatedString		  
          pause		  
			
			}
			
			else {
			Clear-Host
            PrintLogo 
	        Write-Host "Error: replace not valid" -ForegroundColor red
            pause
			
			}
	
	
	
	
	
	}
	
	
	
	8   { #Undo last taks
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
	9   { #Printing Layers
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
	     pause 
	}

    10 { #Export report file
	
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
		 $result  | Out-File $OutputFilePath  
		 
	
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
pause

	  }#end case 

}#end switch   

}#end do 

until($Choice -eq "0")



return  
}









#POWERDECODE FUNCTIONS IMPORT 
Import-Module ./package\PowerDecode.psd1

#START GUI 
DisplayMainMenu