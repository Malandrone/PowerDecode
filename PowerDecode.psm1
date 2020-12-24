<#
    
______                     ______                   _      
| ___ \                    |  _  \                 | |     
| |_/ /____      _____ _ __| | | |___  ___ ___   __| | ___ 
|  __/ _ \ \ /\ / / _ \ '__| | | / _ \/ __/ _ \ / _` |/ _ \
| | | (_) \ V  V /  __/ |  | |/ /  __/ (_| (_) | (_| |  __/
\_|  \___/ \_/\_/ \___|_|  |___/ \___|\___\___/ \__,_|\___| 
                                                           
              PowerShell Script Decoder
    
-Author     : Giuseppe Malandrone 
-Email      : giusemaland@gmail.com
-University : Università degli Studi di Cagliari 
-Department : Dipartimento di Ingegneria Elettrica ed Elettronica

 
PowerDecode is a PowerShell tool which allows to deobfuscate PowerShell obfuscated scripts across multiple layers. The tool also performs dynamic analysis, extracting malware hosting URLs and detecting malware IP traffic.         	

WARNING: Dynamic analysis requires script execution. Use the tool only in a isolated execution environment (sandbox). 


How to use the tool:

1-Save the PowerDecode.psm1 module in a generic directory (for example C:\worskpace )
2-Launch PowerShell.exe and select this directory:
  
    cd C:\workspace

2-Import the PowerDecode module on the PowerShell session:
    
	Import-Module  ./PowerDecode.psm1     

3-To deobfuscate a script:

   PowerDecode .\(parameter a)   (parameter b)  

  where:
   
  -(parameter a): [mandatory] .ps1 script path 
                  ( example:  script_folder\script.ps1)
 
  -(parameter b): [optional]  results file path 
                  ( example: C:\results_folder\result.txt ) 

 


#>



###########################
#   OVERRIDEN FUNCTIONS   #
###########################

$InvokeExpressionOverride = @'
function Invoke-Expression()
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
        Write-Output $Script
    }
'@



$AddTypeOverride = @'
function Add-Type {
        param(
            [Parameter(Mandatory=$True, Valuefrompipeline = $True)]
            [string]$Object
        )

     return 
    }
'@


$SleepOverride = @'
function Start-sleep( ) {
    param(

  [Parameter( Mandatory = $False) ] [switch]$Seconds,
		
    

        [Parameter(
			Mandatory = $False,
			ValueFromPipeline=$True)]
        [ int]$time
    )
	
    
    $data = "Script attempts to sleep for " + $time + " seconds" + "`r`n"
    UpdateReport($data)
    
	 
return
}
'@






$StartProcessOverride = @'
function Start-Process( ) {
    param(
        [Parameter(
			Mandatory = $False,
			ValueFromPipeline=$True)]
        [ string]$Process
    )
	
	$data = "Script attempts to execute the process " +$Process + "`r`n"
    UpdateReport($data) 
     
     
     
     
return
}
'@


$StopProcessOverride = @'
function Stop-Process( ) {
    param(
                       
        [Parameter(
			Mandatory = $False,
			ValueFromPipeline=$True)]
        [ string]$Process
    )
	
	$data = "Script attempts to kill the process " +$Process + "`r`n"
    UpdateReport($data)  
    
return
}
'@


$NewObjectOverride = @'
function New-Object( ) {
    param(
        [Parameter(
			Mandatory = $True,
			ValueFromPipeline=$True)]
        [ string ]$Object
    )
	
    
   

    return
}
'@


$InvokeItemOverride = @'
function Invoke-Item( ) {
    param(
        [Parameter(
			Mandatory = $False,
			ValueFromPipeline=$True)]
        [ string] $Item
    )
	
	 
    $data = "Script attempts to invoke " +$Item + "`r`n"
    UpdateReport($data)  
     
     
     
return
}
'@








###################################
# POWER DRIVE ORIGINAL FUNCTIONS  #
###################################

function GetScriptFromFile() {
	param(
        [Parameter(
			Mandatory = $True)]
        [PSObject[]]$InputFile
    )
	
    try {
		$FileEncoding = GetFileEncoding $InputFile
		if($FileEncoding -eq "ascii") {
			$FileContent = Get-Content $InputFile -ErrorAction Stop
		}
		else {
			$FileContent = Get-Content $InputFile -Encoding UTF8 -ErrorAction Stop
		}
		foreach($line in $FileContent) {
			$ObfuscatedScript += $line
		}
	}
    catch {
		throw "Error reading: '$($InputFile)'"
	}
	
	return $ObfuscatedScript
}

function GetFileEncoding() {
	param(
        [Parameter(
			Mandatory = $True)]
        [PSObject[]]$InputObject
    )
	
	[byte[]]$Bytes = Get-Content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $InputObject
	
	if($Bytes[0] -eq 0xef -and $Bytes[1] -eq 0xbb -and $Bytes[2] -eq 0xbf) {
		return "utf8"
	}
	else {
		return "ascii"
	}
}

function IsBase64() {
	param(
        [Parameter(
			Mandatory = $True)]
        [ string ] $InputString
    )
	
	if($InputString -Match "^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$") {
		return $True
	}
	else {
		return $False
	}
}

function DecodeBase64() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$StringBase64
    )
	
	
	$DecodedString = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($StringBase64))
	
	return $DecodedString
}



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

function RemoveNonAsciiCharacters() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )
	
	$ObfuscatedScript = $ObfuscatedScript -replace "[^\x00-\x7e]+", ""
	
	return $ObfuscatedScript
}

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

function RemoveEscapeCharactersWithBadFormat() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )
		
	$ObfuscatedScript = $ObfuscatedScript -replace '\\"', "'"
	
	return $ObfuscatedScript
}




##########################
# SolveString Functions  #
##########################






function ReplaceQuotesFunctionName
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
       $pattern = [regex]"[\.&](\`"|')[a-zA-Z0-9]+(\`"|')\("
       $matches = $pattern.Matches($Script) 

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                
                $Script = $Script.Replace($match, $match.ToString().replace('"','').replace("'",""))
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script

    }

function ReplaceFunctionParensWrappers
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
       $pattern = [regex]"[\.&]\(('|`")[a-zA-Z-]+('|`")\)"
       $matches = $pattern.Matches($Script) 

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                
                $Script = $Script.Replace($match, $match.ToString().replace('.','').replace('&','').replace("('",'').replace("')",'').replace('("','').replace('")',''))
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script

    }

function CleanFunctionCalls
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

       $pattern = [regex]"\.['`"][a-zA-Z0-9``]+['`"]"
       $matches = $pattern.Matches($Script) 

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                $ReplacedValue = $match.ToString().replace('"','').replace("'",'')
                
                $Script = $Script.Replace($match, $ReplacedValue )
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script

    }

function ReplaceParens
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
       $pattern = [regex]"[^a-zA-Z0-9.&(]\(\s*'[^']*'\)"
       $matches = $pattern.Matches($Script) 

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                
                $Script = $Script.Replace($match, $match.ToString().replace('(','').replace(')',''))
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script

    }

function ReplaceNonEscapes
    {
        param(
            [Parameter(Mandatory=$True)]
            [char[]]$Script
        )

        $PrevChar = ''        
        $InScript = $false
        $CurrQuote = ''
        $ScriptQuotes = '"', "'"
        $CharIdxArray = @()

        for ($char=0; $char -lt $Script.Length; $char++){
            if($Script[$char] -in $ScriptQuotes -and -not $InScript){
                $CurrQuote = $Script[$char]
                $InScript = $true
            }
            elseif($Script[$char] -in $ScriptQuotes -and $InScript -and $Script[$char] -eq $CurrQuote  -and $PrevChar -ne '`'){
                $CurrQuote =''
                $InScript = $false
            }
            elseif($Script[$char] -eq '`' -and -not $InScript){
                $CharIdxArray += ,$char
            }

            $PrevChar = $Script[$char]
        }

        [System.Collections.ArrayList]$NewScript = $Script
        $IdxOffset = 0
        
        

        ForEach($idx in $CharIdxArray){
            $NewScript.RemoveAt($idx-$IdxOffset)
            $IdxOffset++
        }

    return $NewScript -join ''
}

function ReplaceMultiLineEscapes
    {
        param(
            [Parameter(Mandatory=$True)]
            [string]$Script
        )

        $pattern = [regex]'`\s*\r\n\s*'
        $matches = $pattern.Matches($Script)


        While ($matches.Count -gt 0){
            
            ForEach($match in $matches){
                
                $Script = $Script.Replace($match, ' ')
                }
            $matches = $pattern.Matches($Script) 
        }
    return $Script
}

function ResolveStringFormats
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

       $pattern = [regex]"\(`"({\d+})+`"\s*-[fF]\s*('[^']*',?)+\)"
       $matches = $pattern.Matches($Script) 

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                $SolvedString = IEX($match)
               
                $Script = $Script.Replace($match, "'$($SolvedString)'")
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script
    }

function ResolveReplaces
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

       $pattern = [regex]"\(?['`"][^'`"]+['`"]\)?\.(?i)replace\([^,]+,[^\)]+\)"
       $matches = $pattern.Matches($Script)

       While ($matches.Count -gt 0){
            ForEach($match in $matches){
                $SolvedString = IEX($match)
                $SolvedString = $SolvedString.replace("'","''")
                
                $Script = $Script.Replace($match, "'$($SolvedString)'")
                }
            $matches = $pattern.Matches($Script) 
        }
       
       return $Script
    }

function ConcatenateCleanup
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
       return $Script.Replace("'+'", "").Replace('"+"','')
    }

function CodeCleanup
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

       $OldScript = ''
       $NewScript = $Script

       While($OldScript -ne $NewScript)
       {
            $OldScript = $NewScript

            $NewScript  = ReplaceMultiLineEscapes($NewScript )
            $NewScript  = ReplaceNonEscapes($NewScript )
            $NewScript  = ReplaceQuotesFunctionName($NewScript )
            $NewScript  = CleanFunctionCalls($NewScript )
            $NewScript  = ReplaceParens($NewScript )
            $NewScript  = ReplaceFunctionParensWrappers($NewScript )
            $NewScript  = ConcatenateCleanup($NewScript )
            $NewScript  = ResolveStringFormats($NewScript )
            $NewScript  = ResolveReplaces($NewScript )
        }
        
        return $NewScript

    }


###################################
# DEOBFUSCATE ONE LAYER FUNCTION  #
###################################


function DeobfuscateOneLayer {
    param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
	)

	#Initialize variables
    $OverriddenFunctions = @()
	
	$OverriddenFunctions += $InvokeExpressionOverride
	$OverriddenFunctions += $SleepOverride    
	$OverriddenFunctions += $StartProcessOverride
    $OverriddenFunctions += $StopProcessOverride
    $OverriddenFunctions += $InvokeItemOverride

#Start deobfuscating

$Deobfuscator = ($OverriddenFunctions -join "`r`n`r`n") + "`r`n`r`n" + $ObfuscatedScript






if ($ObfuscatedScript -match "VirtualAlloc") {
 
 Write-Host "VirtualAlloc found!" -ForegroundColor blue 
 
 $OverriddenFunctions += $AddTypeOverride
$Deobfuscator = ($OverriddenFunctions -join "`r`n`r`n") + "`r`n`r`n" + $ObfuscatedScript
 $DeobfuscationOutput = iex($Deobfuscator) 	

}

else {



if( IsCompressed $ObfuscatedScript ){

  Write-Host "Compressed format recognized" -ForegroundColor magenta 

  $DeobfuscationOutput = iex( $Deobfuscator ) 

}

else {

$OverriddenFunctions += $NewObjectOverride 
$DeobfuscationOutput = iex( $Deobfuscator ) 

}

 	
      }  

 return $DeobfuscationOutput
 
 
     
}






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




##################################
#       CHECKING COMPRESSED      #
##################################

function IsCompressed() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string[ ] ]$InputString
    )
	
#to lower conversion 

$lowerstring = ""
ForEach ($char in $InputString ) {

$lowerstring += $char.toLower() 


}

$pattern = "io\.compression\.deflatestream"
$regex = [regex]::Match($lowerstring , $pattern)
$result = $regex.Success 


return $result


}




#######################################
#   PLAINSCRIPT ANALYSIS FUNCTIONS    #
#######################################


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




function ExtractUrls() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$Script
    )
	
	
	
	
	$Urls = @()
	$Url = ""
	
	 
	
	$Pattern = [regex]  "(http[s]?|[s]?ftp[s]?)(:\/\/)(.*?)(\""|\'|\}|\@|\,|\s|\?)"
	
	$Matches = $Pattern.matches($Script)
	
	Foreach($Group in $Matches.Groups) {
		if($Group.Name -eq 0) {
			$Url = $Group.Value
			$Url = $Url.SubString(0, $Url.Length - 1)
			$Urls += $Url
		}
	}
		
	
	return $Urls
}



function IsUrlActive() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$Url
    )
	
	$HTTP_Request = [System.Net.WebRequest]::Create($Url)
	try {
		$HTTP_Response = $HTTP_Request.GetResponse()
	}
	catch [Net.WebException] {
		return $False
	}
	$HTTP_Status = [int]$HTTP_Response.StatusCode
	
	if($HTTP_Status -eq 200) {
		return $True
	}
	else {
		return $False
	}
}



function UpdateReport( ) {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$data 
    )


    $ReportFileName = "PowerDecode_2020_Malware_Analysis_Temp_Report"
    $ReportOutFile =  [System.IO.Path]::GetTempPath() + $ReportFileName +".txt" 
    
    
    $Report = Get-Content $ReportOutFile  
    $Report += $data 
    $Report | Out-File $ReportOutFile 


return 

}


function ExtractShellcode()  {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [string]$String
        )
      
      

#to lower conversion 

$lowerstring = ""
ForEach ($char in $String ) {

$lowerstring += $char.toLower() 

}  



$lowerstring = $lowerstring.replace(' ','').replace('0x','').replace(',',' ')


$pattern =  [regex] "\=[a-f|0-9|\s]{8,};"
$matches = $pattern.matches($lowerstring)
$shellcode = $matches.value
$shellcode= $shellcode.replace('=','').replace(';','')


$data = "Script attempts to inject shellcode into memory: " + "`r`n`r`n" + $shellcode
UpdateReport($data)  
    



return  
    }




##########################
# Obfuscation Recognizer #
##########################

function GetObfuscationType() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )
	
  if( IsCompressed $ObfuscatedScript ) {
      return "Compressed"
   }
    
  if( IsBase64 $ObfuscatedScript ) {   
      return "Base64"   
  }
  
  if( IsEncoded $ObfuscatedScript ) { 
      return "Encoded"  
  }
        
  if( IsStringBased $ObfuscatedScript ) {    
      return "String-Based"
  }

  else {  
      return "Unknown" 
  }

   
}


function IsEncoded() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )

 $lowerstring = ""
      ForEach ($char in $ObfuscatedScript ) {

      $lowerstring += $char.toLower()  


       }



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







function IsStringBased() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )



 $pattern = [regex] "(\{\d\}\'\s*-f)|(\'(.*?)\'\s*\+\s*\'(.*?)\')"
 $matches = $pattern.Matches($ObfuscatedScript) 

    if ($matches.Count -gt 0){
     return $true 
     }
     else {
      $lowerstring = ""
      ForEach ($char in $ObfuscatedScript ) {
       $lowerstring += $char.toLower()  
       }
        
    $pattern = [regex] "\[char\]\d" 
    $matches = $pattern.Matches($lowerstring) 


     if ($matches.Count -gt 0){
     return $true 
     }
     
     
     
     
    $pattern = [regex] "\'righttoleft\'" 
    $matches = $pattern.Matches($lowerstring) 


     if ($matches.Count -gt 0){
     return $true 
     }
     
     
     
     
     return $false
     }
}

###############################
#           GRAPHICS          #
###############################

function PrintLogo( ) {
    param(  )
	
    $logo = @'
______                     ______                   _      
| ___ \                    |  _  \                 | |     
| |_/ /____      _____ _ __| | | |___  ___ ___   __| | ___ 
|  __/ _ \ \ /\ / / _ \ '__| | | / _ \/ __/ _ \ / _` |/ _ \
| | | (_) \ V  V /  __/ |  | |/ /  __/ (_| (_) | (_| |  __/
\_|  \___/ \_/\_/ \___|_|  |___/ \___|\___\___/ \__,_|\___| 

'@                                                           
          


$slogan ="                   PowerShell Script Decoder"

$about = @'


-Author     : Giuseppe Malandrone 
-Email      : giusemaland@gmail.com
-University : Università degli Studi di Cagliari 
-Department : Dipartimento di Ingegneria Elettrica ed Elettronica

'@



Write-Host $logo -Foregroundcolor yellow
Write-Host $slogan -Foregroundcolor yellow
Write-Host $about
   

    return
}




###########################
#           MAIN          #
###########################

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
        
        Write-Host "Base64 encoding recognized" -ForegroundColor blue
		$ObfuscationLayers.Add($ObfuscatedScript)  
		$ObfuscatedScript = DecodeBase64 $ObfuscatedScript
	    
        Write-Host "Base64 layer solved" -ForegroundColor green
    }
	
	
	
	
    #Deobfuscating by cmdlet overriding  
	     
         Write-Host "Deobfuscating compressed\encoded\string-based layers" -ForegroundColor yellow
	   
try {
    while( GoodSyntax $ObfuscatedScript){ 
     $ObfuscationLayers.Add($ObfuscatedScript)
     Write-Host "Syntax is good, layer stored succesfully" -ForegroundColor green         
     $ObfuscatedScript = CleanScript   $ObfuscatedScript     
          Write-Host "Deobfuscating current layer" -ForegroundColor yellow          
          $DeobfuscationOutput = DeobfuscateOneLayer    $ObfuscatedScript
		  
          if( GoodSyntax $DeobfuscationOutput ){
          	Write-Host "Layer deobfuscated succesfully, moving to next layer" -ForegroundColor green     	 
		      $ObfuscatedScript = $DeobfuscationOutput
           }      
	      else {
		    Write-Host "All detected obfuscation layers have been removed" -ForegroundColor yellow
			break;
		  }
		 }
        }
	 
	catch {	}
	
   
    
    #Selecting last layer     
    $NumberOfLayers = $ObfuscationLayers.Count  
    $LastLayerIndex = $NumberOfLayers - 1     
    $LastLayer = $ObfuscationLayers | Select-Object -Index $LastLayerIndex    
      
   #Solving String  
   
   Write-Host "Cleaning code " -ForegroundColor yellow
   $CleanScript =  CodeCleanup $LastLayer

  if ($CleanScript -ne $LastLayer ) {
     $ObfuscationLayers.Add($CleanScript)  
  }

 
    
   	#Selecting last layer     
    $NumberOfLayers = $ObfuscationLayers.Count  
    $LastLayerIndex = $NumberOfLayers - 1     
    $Plainscript = $ObfuscationLayers | Select-Object -Index $LastLayerIndex 
	
    #Checking Shellcode 
    if ($Plainscript -match "VirtualAlloc") {
    ExtractShellcode ($Plainscript)
    }

    #Fetching data from report
    $Report = Get-Content $ReportOutFile
    Remove-Item $ReportOutFile  
	
	
    #Printing layers 
        
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
   
                     

   $NumberOfLayers = $ObfuscationLayers.Count
   $PlainscriptIndex = $NumberOfLayers - 1     
   $Plainscript = $ObfuscationLayers | Select-Object -Index $PlainscriptIndex 



  #Saving plainscript on a temp file  
   $TmpFile = [System.IO.Path]::GetTempPath() + [GUID]::NewGuid().ToString() + ".ps1"; 

    
    #Initializing overrides for dynamical analysis
    $OverriddenFunctions = @()	
	$OverriddenFunctions += $SleepOverride
	
    $ScriptToExecute = ($OverriddenFunctions -join "`r`n`r`n") + "`r`n`r`n" + $Plainscript

    $EncodedScript = EncodeBase64 $ScriptToExecute
    $EncodedScript = "powershell -e  " + $EncodedScript
	$EncodedScript  | Out-File $TmpFile
             
   

    
	Start-Job -filepath $TmpFile| Out-Null 
	
	Remove-Item $TmpFile  
    
	Sleep 10 ; 
   
	

   #Url analysis
				
        $Urls = ExtractUrls  $Plainscript
				if($Urls) {
						$UrlsDown = @()
						$UrlsUp = @()
						ForEach($Url in $Urls) {
							if(IsUrlActive $Url) {
                                                        
								$UrlsUp += $Url
							}
							else {
								$UrlsDown += $Url
							}
						}
						
                #Printing and saving active urls
                $heading = "`r`n`r`n" + "Active Malware Hosting URLs:" + "`r`n"
                Write-Host $heading -ForegroundColor yellow
                $result += $heading 
                
                foreach ( $url in $UrlsUp ) {
                Write-Output $url 
                $result += $url + "`r`n"                
                }
                
                
                
               #Printing and saving down urls 
                $heading = "`r`n`r`n" + "Down Malware Hosting URLs:" + "`r`n"
                Write-Host $heading -ForegroundColor yellow
                $result += $heading                
                foreach ( $url in $UrlsDown ) {
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
	

        $heading = "`r`n`r`n" +"TCP Connections info:"+ "`r`n"
		Write-Host $heading -ForegroundColor yellow
        $ActiveTCPConnections = ([System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpConnections())
		Write-Output $ActiveTCPConnections
	
        $result += $heading
        $result += $ActiveTCPConnections	 
	    
       
	
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
   Remove-Job -State Running 
   Remove-Job -State Completed 
   Remove-Job -State Stopped 
    
   
    
    return 
    
}