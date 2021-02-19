#########################################
# Deobfuscation by Overriding Functions #
#########################################


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





###########################
#   Overriden Functions   #
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
	
    
    $data = "Script attempted to sleep for " + $time + " seconds" + "`r`n"
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
	
	$data = "Script attempted to execute the process " +$Process + "`r`n"
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
	
	$data = "Script attempted to kill the process " +$Process + "`r`n"
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
	
   
   $data = Write-Output "Object: " +$Object+ "`r`n"
   UpdateReport($data) 
   
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
	
	 
    $data = "Script attempted to invoke " +$Item + "`r`n"
    UpdateReport($data)  
     
     
     
return
}
'@


