<#
Function name: DeobfuscateByOverriding
Description: Receives a script as input and performs de-obfuscation by cmdlet overriding.   
Function calls: IsCompressed, IsEncoded, BitmapFetch, Deobfuscator
Input: $ObfuscatedScript
Output: $DeobfuscationOutput
#>


function DeobfuscateByOverriding {
    param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript , 
		
		[Parameter(
			Mandatory = $False)]
           $Timeout
	)

  
#initialize
$IEX = ((gc "package\overrides\Invoke-Expression.txt") |Out-String);
$AddType =  ((gc "package\overrides\Add-Type.txt") |Out-String);
$NewObject =  ((gc "package\overrides\New-Object.txt") |Out-String);
$Other  = ((gc "package\overrides\Other.txt") |Out-String);

$IEX >  ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")
$AddType > ([System.IO.Path]::GetTempPath() +"Add-Type.txt")
$NewObject >  ([System.IO.Path]::GetTempPath() +"New-Object.txt")
$Other  >  ([System.IO.Path]::GetTempPath() +"Other.txt")

#Start deobfuscating
if ($ObfuscatedScript -match "VirtualAlloc") {
 
 Write-Host "VirtualAlloc found!" -ForegroundColor blue
 
$Deobfuscating = @"
sv IEX ((gc ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")) |Out-String);
sv AddType  ((gc ([System.IO.Path]::GetTempPath() +"Add-Type.txt")) |Out-String);
sv Other  ((gc ([System.IO.Path]::GetTempPath() +"Other.txt")) |Out-String);
if ( Test-Path ([System.IO.Path]::GetTempPath() +"Alias.txt")){ sv Alias  ((gc ([System.IO.Path]::GetTempPath() +"Alias.txt")) |Out-String);}
sv ObfuscatedScript ((gc ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt") |Out-String));
(sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv AddType).value)+((gv Other).value)+((gv Alias).value)+((gv ObfuscatedScript).value))));
(gv DeobfuscationOutput).value > ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")
Remove-Item ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")
"@


}

else {

      if( IsCompressed $ObfuscatedScript){

         Write-Host "Compressed format recognized" -ForegroundColor magenta 

$Deobfuscating = @"
sv IEX ((gc ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")) |Out-String);
sv Other  ((gc ([System.IO.Path]::GetTempPath() +"Other.txt")) |Out-String);
if ( Test-Path ([System.IO.Path]::GetTempPath() +"Alias.txt")){ sv Alias  ((gc ([System.IO.Path]::GetTempPath() +"Alias.txt")) |Out-String);};
sv ObfuscatedScript ((gc ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt") |Out-String)) ;
(sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv Other).value)+((gv Alias).value)+((gv ObfuscatedScript).value))));
(gv DeobfuscationOutput).value > ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")
Remove-Item ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")
"@  

       }

       else {

               if( IsEncoded $ObfuscatedScript ){

                    Write-Host "Encoded format recognized" -ForegroundColor cyan
                   
$Deobfuscating = @"
sv IEX ((gc ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")) |Out-String);
sv Other  ((gc ([System.IO.Path]::GetTempPath() +"Other.txt")) |Out-String);
if ( Test-Path ([System.IO.Path]::GetTempPath() +"Alias.txt")){ sv Alias  ((gc ([System.IO.Path]::GetTempPath() +"Alias.txt")) |Out-String);};
sv ObfuscatedScript ((gc ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt") |Out-String)) ; 
(sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv Other).value)+((gv Alias).value)+((gv ObfuscatedScript).value))));
(gv DeobfuscationOutput).value > ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")
Remove-Item ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")
"@


                }
			
			    else {

                        if( BitmapFetch $ObfuscatedScript ){
							
							Write-Host "Code fetch from bitmap image detected" -ForegroundColor black -BackgroundColor green
$Deobfuscating = @"
sv IEX ((gc ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")) |Out-String);
sv Other  ((gc ([System.IO.Path]::GetTempPath() +"Other.txt")) |Out-String);
if ( Test-Path ([System.IO.Path]::GetTempPath() +"Alias.txt")){ sv Alias  ((gc ([System.IO.Path]::GetTempPath() +"Alias.txt")) |Out-String);};
sv ObfuscatedScript ((gc ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt") |Out-String)) ;
(sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv Other).value)+((gv Alias).value)+((gv ObfuscatedScript).value))));
(gv DeobfuscationOutput).value > ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")
Remove-Item ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")
"@

							
						} 
						
						else {

$Deobfuscating = @"
sv IEX ((gc ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")) |Out-String);
sv NewObject  ((gc ([System.IO.Path]::GetTempPath() +"New-Object.txt")) |Out-String);
sv Other  ((gc ([System.IO.Path]::GetTempPath() +"Other.txt")) |Out-String);
if ( Test-Path ([System.IO.Path]::GetTempPath() +"Alias.txt")){ sv Alias  ((gc ([System.IO.Path]::GetTempPath() +"Alias.txt")) |Out-String);};
sv ObfuscatedScript ((gc ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt") |Out-String)) ; 
(sv DeobfuscationOutput (IEX(((gv IEX).value)+((gv NewObject).value)+((gv Other).value)+((gv Alias).value)+((gv ObfuscatedScript).value))));
(gv DeobfuscationOutput).value > ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")
Remove-Item ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")
"@

                               
						}  
                }
        }

 	
}  


$ObfuscatedScript |Out-File ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")
Deobfuscator $Deobfuscating  $Timeout
$DeobfuscationOutput = ""
if ( Test-Path ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt") ) {
 $DeobfuscationOutput =  (Get-Content ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")) |Out-String
 Remove-Item ([System.IO.Path]::GetTempPath() +"DeobfuscationOutput.txt")
}

Remove-Item  ([System.IO.Path]::GetTempPath() +"Invoke-Expression.txt")
Remove-Item  ([System.IO.Path]::GetTempPath() +"Add-Type.txt")
Remove-Item  ([System.IO.Path]::GetTempPath() +"New-Object.txt")
Remove-Item  ([System.IO.Path]::GetTempPath() +"Other.txt")


 return $DeobfuscationOutput
 
}


<#
Function name: Deobfuscator
Description: Takes a instruction string as input and locally executes them
Function calls: -
Input:  $Deobfuscating
Output: -
#>

function Deobfuscator {
     param(
        [Parameter(
			Mandatory = $True)]
        $Deobfuscating,
		
		[Parameter(
			Mandatory = $False)]
        $Timeout
	)
         
		    $CommandFile = ([System.IO.Path]::GetTempPath() +"DeobfuscationCommand.ps1");
           
            $Deobfuscating | Out-File $CommandFile 
            
  
	    $ProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessStartInfo.FileName = "powershell"
        $ProcessStartInfo.CreateNoWindow = $true
        $ProcessStartInfo.RedirectStandardError = $false
        $ProcessStartInfo.RedirectStandardOutput = $true
        $ProcessStartInfo.UseShellExecute = $false
		$ProcessStartInfo.Arguments = "-File $($CommandFile)"
     
        $Process = New-Object System.Diagnostics.Process
        $Process.StartInfo = $ProcessStartInfo
        
        $Process.Start() | Out-Null
		
		#timeout
		$t= [int] $Timeout
		if(-not $Process.WaitForExit($t*1000)){
            Write-Host "Execution stopped after "$t" seconds due timeout" -ForegroundColor yellow 
			Stop-Process $Process
			
			$TmpFile = ([System.IO.Path]::GetTempPath() +"ObfuscatedScript.txt")
            if (Test-Path $TmpFile ){
           
                Remove-Item $TmpFile 
            }
            
        }
	
    return
}

<#
Function name: GoodSyntax
Description: Receives a script as input and returns true if it doesn't contains syntax errors    
Function calls: -
Input: $ObfuscatedScript
Output: $true/$false
#>



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



<#
Function name: GetSyntaxErrors
Description: Receives a script as input and returns its syntax errors    
Function calls: -
Input: $ObfuscatedScript
Output: $Errors
#>



function GetSyntaxErrors() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )
		
	$Errors = @()
	[void][System.Management.Automation.Language.Parser]::ParseInput($ObfuscatedScript, [ref]$Null, [ref]$Errors)
	
	return $Errors
}

<#
Function name: CleanScript
Description: Receives a script as input and removes spurious characters
Function calls: ThereAreNonCompatibleAsciiCharacters, RemoveNonAsciiCharacters, EscapeCharactersWithBadFormat, RemoveEscapeCharactersWithBadFormat
Input: $ObfuscatedScript
Output: $ObfuscatedScript
#>

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


<#
Function name: ThereAreNonCompatibleAsciiCharacters
Description: Receives a script as input and returns true if it contains some non compatible ASCII characters 
Function calls: -
Input: $ObfuscatedScript
Output: $true/$false 
#>
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

<#
Function name: RemoveNonAsciiCharacters
Description: Receives a script as input and removes all not ASCII characters 
Function calls: -
Input: $ObfuscatedScript
Output: $ObfuscatedScript
#>

function RemoveNonAsciiCharacters() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )
	
	$ObfuscatedScript = $ObfuscatedScript -replace "[^\x00-\x7e]+", ""
	
	return $ObfuscatedScript
}


<#
Function name: EscapeCharactersWithBadFormat
Description: Receives a script as input and returns true if it contains <"> characters   
Function calls: -
Input: $ObfuscatedScript
Output: $true/$false
#>
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


<#
Function name: RemoveEscapeCharactersWithBadFormat
Description: Receives a script as input and returns the same script with <"> character replaced with <'> 
Function calls: -
Input: $ObfuscatedScript
Output: $ObfuscatedScript
#>

function RemoveEscapeCharactersWithBadFormat() {
	param(
        [Parameter(
			Mandatory = $True)]
        [string]$ObfuscatedScript
    )
		
	$ObfuscatedScript = $ObfuscatedScript -replace '\\"', "'"
	
	return $ObfuscatedScript
}


<#
Function name: ExecString
Description: Takes a string as input and returns its execution output
Function calls: EncodeBase64 , DecodeBase64 
Input:  $String
Output: $ExecutionOutput
#>

function ExecString {
     param(
        [Parameter(
			Mandatory = $True)]
        $String
	)
         
    
	$StringBase64 =  EncodeBase64 $String
	
	
	    $ProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessStartInfo.FileName = "powershell"
        $ProcessStartInfo.CreateNoWindow = $true
        $ProcessStartInfo.RedirectStandardError = $false
        $ProcessStartInfo.RedirectStandardOutput = $true
        $ProcessStartInfo.UseShellExecute = $false
		
		
		if($StringBase64.length -le 8000){
            $ProcessStartInfo.Arguments = "-EncodedCommand $($StringBase64)"
        }
        else{
            
            $TmpFile = [System.IO.Path]::GetTempPath() + [GUID]::NewGuid().ToString() + ".ps1"; 
           
            DecodeBase64($StringBase64 ) | Out-File $TmpFile 
            $ProcessStartInfo.Arguments = "-File $($TmpFile)"
        }
        $Process = New-Object System.Diagnostics.Process
        $Process.StartInfo = $ProcessStartInfo
        
        $Process.Start() | Out-Null
		
		
		if(-not $Process.WaitForExit(1000)){
           
            Stop-Process $Process
            if ($TmpFile -and (Test-Path $TmpFile )){
           
                Remove-Item $TmpFile 
            }
            
        }
        
        $ExecutionOutput = $Process.StandardOutput.ReadToEnd()
        
		
		$ExecutionOutput  = ($ExecutionOutput.replace("`n","")).substring(0, $ExecutionOutput.length-2 )
		
	
	
    return $ExecutionOutput
}
