<#
Function name: PowerDecode
Description: Main function. Implements de-obfuscation algorithm and generates a report. 
Function calls: PrintLogo, GetScriptFromFile, IsBase64, DecodeBase64, UpdateReport,  GoodSyntax, DeobfuscateByOverriding, DeobfuscateByRegex, GetObfuscationType, ExtractShellcode, ExtractUrls, UrlHttpResponseCheck  
Input: $InputFile  
Output: -
#>

function PowerDecode {
    param(
        [Parameter(
			Mandatory = $True)]
        [PSObject[]]$InputFile ,
		
		
		[Parameter(Mandatory=$false)][ string ]$OutputFileName
	)


    
    Clear-Host
    PrintLogo
	Write-Host "Starting" -ForegroundColor green
    
    #Initialize variables		
    $ObfuscatedScript = GetScriptFromFile $InputFile  
		
	$ObfuscationLayers  = New-Object System.Collections.Generic.List[System.Object]
	$ObfuscationLayersOutput = ""
    $Report = ""
    
    $ReportFileName = "PowerDecode_2020_Malware_Analysis_Temp_Report"
    $ReportOutFile =  [System.IO.Path]::GetTempPath() + $ReportFileName +".txt" 
    $Report | Out-File $ReportOutFile 
    
    
    
    Clear-Host
	PrintLogo
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
	
	
	#checking syntax
    
	if ( !(GoodSyntax $ObfuscatedScript) ) {
		
		$ErrorOutput = powershell $ObfuscatedScript
		
		Write-Host "Syntax error:" -ForegroundColor red	
		
	      $data = "Script contains some syntax errors:" + "`r`n" + $ErrorOutput+ "`r`n" 
          
		  UpdateReport($data)
	
	}
	
	
    #Deobfuscating by cmdlet overriding  
	     
         Write-Host "Deobfuscating compressed\encoded\string-based layers" -ForegroundColor yellow
	   
try {
    while( GoodSyntax $ObfuscatedScript){		
     $ObfuscationLayers.Add($ObfuscatedScript)
     Write-Host "Syntax is good, layer stored succesfully" -ForegroundColor green         
     $ObfuscatedScript = CleanScript   $ObfuscatedScript     
          Write-Host "Deobfuscating current layer by overriding" -ForegroundColor yellow          
          $DeobfuscationOutput = DeobfuscateByOverriding $ObfuscatedScript |Out-String
		  	  
		  
		  if( GoodSyntax $DeobfuscationOutput ){
          	Write-Host "Layer deobfuscated succesfully, moving to next layer" -ForegroundColor green     	 
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
	         
			else{  
		    Write-Host "All detected obfuscation layers have been removed" -ForegroundColor yellow
			break;
		    }
		  
		  
		 }
        }
	 
	catch {	}
	
   
    
    #Selecting last layer        
    $LastLayer = $ObfuscatedScript       
	 
    #Solving obfuscation residuals by regex 
   Write-Host "Deobfuscating current layer by regex " -ForegroundColor yellow
   $CleanScript =  DeobfuscateByRegex $LastLayer 

  if ( (GoodSyntax $CleanScript) -and ($CleanScript -ne $LastLayer) ) {
     $ObfuscationLayers.Add($CleanScript)  
     $Plainscript = $CleanScript.toLower();  
  }
  else {
	  $Plainscript = $LastLayer.toLower() 
	  
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
   
   #layer recognize 
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
    if ($Plainscript -match "VirtualAlloc") {
    ExtractShellcode ($Plainscript)
    }

    #Fetching data from report
    $Report = Get-Content $ReportOutFile
    Remove-Item $ReportOutFile  

   #Url analysis
	Write-Host "Checking URLs Http Response " -ForegroundColor yellow			
    $Urls = ExtractUrls  $Plainscript
	if($Urls) {
        
		#Checking urls http response 
		$UrlsReport = @()
		foreach ( $url in $Urls ) {
        
		    $UrlsReport += UrlHttpResponseCheck $url 
		
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
	    Write-Host $ErrorMessage  -ForegroundColor yellow
	    $result += $ErrorMessage
		                
	     }



#Printing and saving execution output analysis
	if( GoodSyntax $Plainscript ) {
                
    	
        $heading = "`r`n`r`n" +"Execution Report:"+ "`r`n"
        Write-Host $heading -ForegroundColor yellow
        Write-Output $Report 
        $result += $heading  
        $result += $Report 
	
 
       
	
	}


    else {		

		$heading = "`r`n`r`n" +"Syntax Error:"+ "`r`n"
		Write-Host $heading -ForegroundColor red	
        $result += $heading
        
         $ErrorOutput = powershell $Plainscript
         Write-Host $ErrorOutput	
         $result += $ErrorOutput		 
		
		}

      
   $result  | Out-File $OutputFile   

    
   
    
    return 
    
}
