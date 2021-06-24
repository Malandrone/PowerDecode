<#
Function name: DeobfuscateByOverriding
Description: Receives a script as input and performs de-obfuscation by cmdlet overriding.   
Function calls: IsCompressed 
Input: $ObfuscatedScript
Output: $DeobfuscationOutput
#>


function DeobfuscateByOverriding {
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

$Deobfuscating = ($OverriddenFunctions -join "`r`n`r`n") + "`r`n`r`n" + $ObfuscatedScript






if ($ObfuscatedScript -match "VirtualAlloc") {
 
 Write-Host "VirtualAlloc found!" -ForegroundColor blue 
 
 $OverriddenFunctions += $AddTypeOverride
 $Deobfuscating = ($OverriddenFunctions -join "`r`n`r`n") + "`r`n`r`n" + $ObfuscatedScript
 $DeobfuscationOutput = iex($Deobfuscating) 	

}

else {



if( IsCompressed $ObfuscatedScript ){

  Write-Host "Compressed format recognized" -ForegroundColor magenta 

  $DeobfuscationOutput = iex( $Deobfuscating ) 

}

else {

$OverriddenFunctions += $NewObjectOverride
$Deobfuscating = ($OverriddenFunctions -join "`r`n`r`n") + "`r`n`r`n" + $ObfuscatedScript
$DeobfuscationOutput = iex( $Deobfuscating ) 

}

 	
      }  






 return $DeobfuscationOutput
 
 
     
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
Overriden function: Invoke-Expression 
Description: Original cmdlet is redefined in order to pass the input script to the Write-Output cmdlet  
Function calls: - 
Input:  $ObfuscatedScript
Output: -
#>

$InvokeExpressionOverride = @'
function Invoke-Expression()
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$ObfuscatedScript
        )
        Write-Output $ObfuscatedScript
    }
'@


<#
Overriden function: Add-Type 
Description: Original cmdlet is redefined in order to avoid its execution
Function calls: - 
Input:  $Object 
Output: -
#>

$AddTypeOverride = @'
function Add-Type {
        param(
            [Parameter(Mandatory=$True, Valuefrompipeline = $True)]
            [string]$Object
        )

     return 
    }
'@


<#
Overriden function: Start-Sleep 
Description: Original cmdlet is redefined in order to avoid its execution. Action attempted is stored in a report file  
Function calls: UpdateReport
Input:  $time  
Output: -
#>

$SleepOverride = @'
function Start-Sleep( ) {
    param(

  [Parameter( Mandatory = $False) ] [switch]$Seconds,
		
    

        [Parameter(
			Mandatory = $False,
			ValueFromPipeline=$True)]
        [ int]$time
    )
	
    
    $data = "Script attempted to sleep for " + $time + " seconds" + "`r`n"
    UpdateReport($data)
    
	 
return
}
'@


<#
Overriden function: Start-Process 
Description: Original cmdlet is redefined in order to avoid its execution. Action attempted is stored in a report file 
Function calls: UpdateReport
Input:  $Process
Output: -
#>



$StartProcessOverride = @'
function Start-Process( ) {
    param(
        [Parameter(
			Mandatory = $False,
			ValueFromPipeline=$True)]
        [ string]$Process
    )
	
	$data = "Script attempted to execute the process " +$Process + "`r`n"
    UpdateReport($data) 
     
     
     
     
return
}
'@

<#
Overriden function: Stop-Process 
Description: Original cmdlet is redefined in order to avoid its execution. Action attempted is stored in a report file 
Function calls: UpdateReport
Input:  $Process
Output: -
#>

$StopProcessOverride = @'
function Stop-Process( ) {
    param(
                       
        [Parameter(
			Mandatory = $False,
			ValueFromPipeline=$True)]
        [ string]$Process
    )
	
	$data = "Script attempted to kill the process " +$Process + "`r`n"
    UpdateReport($data)  
    
return
}
'@


<#
Overriden function: New-Object
Description: Original cmdlet is redefined in order to avoid its execution. Action attempted is stored in a report file 
Function calls: UpdateReport
Input:  $Object 
Output: -
#>

$NewObjectOverride = @'
function New-Object {
        param(
            [Parameter(Mandatory=$True, Valuefrompipeline = $True)]
            [string]$Object 
        )

           if($Object -ieq 'System.Net.WebClient' -or $Object -ieq 'Net.WebClient'){
            $WebClientObject = microsoft.powershell.utility\new-object Net.WebClient
            Add-Member -memberType ScriptMethod -InputObject $WebClientObject -Force -Name "DownloadFile" -Value {
                param([string]$url,[string]$destination)
                $data = "Script attempted to download from $($url) and save to: $($destination)" + "`r`n"
                UpdateReport($data)
				}
            Add-Member -memberType ScriptMethod -InputObject $WebClientObject -Force -Name "DownloadString" -Value {
                param([string]$url)
                $data= "Script attempted to download from: $($url)"+ "`r`n"
                UpdateReport($data)
				}
            return $WebClientObject
        }
        elseif($Object -ieq 'random'){
            $RandomObject = microsoft.powershell.utility\new-object Random
            Add-Member -memberType ScriptMethod -InputObject $RandomObject -Force -Name "next" -Value {
                param([int]$min,[int]$max)
                $RandomInt = Get-Random -Minimum $min -Maximum $max
                $data = "Script attempted to generate a random integer between $($min) and $($max). Value returned: $($RandomInt)" + "`r`n"
                UpdateReport($data)
				return $RandomInt
                }
            return $RandomObject
        }
        else{
            $UnknownObject = microsoft.powershell.utility\new-object $Object
            return $UnknownObject
        }


    }
'@

<#
Overriden function: Invoke-Item  
Description: Original cmdlet is redefined in order to avoid its execution. Action attempted is stored in a report file 
Function calls: UpdateReport
Input:  $Item 
Output: -
#>

$InvokeItemOverride = @'
function Invoke-Item( ) {
    param(
        [Parameter(
			Mandatory = $False,
			ValueFromPipeline=$True)]
        [ string] $Item
    )
	
	 
    $data = "Script attempted to invoke " +$Item + "`r`n"
    UpdateReport($data)  
     
     
     
return
}
'@




