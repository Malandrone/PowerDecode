<#
Function name: GetVariablesContent
Description: Takes a script as input and returns a list containing the variables declared by the same (name-value) 
Function calls: EncodeBase64, Declarator
Input: $Script
Output: $Variables
#>
function GetVariablesContent()  {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [string]$Script , 
		
		[Parameter(
			Mandatory = $False)]
           $Timeout
        )

sv ErrorActionPreference SilentlyContinue

$Declarations = ""
foreach ($row in $Script.split(';')) {
 if (($row -match "$") -and  ($row -match '=')   ) {   #(\$)([a-zA-z\{\}\s_\-0-9]+)(\=)([^\;]+)(\;)
   $Declarations += $row + " ;"
 }
}

$GetUDVariables = get-content package\GetUDvariables.txt

$Arguments = "sv ErrorActionPreference 'silentlycontinue';"+"`n"+$Declarations+"`n"+$GetUDvariables+"`n"+"(GetUDVariables)>([System.IO.Path]::GetTempPath() +'DeclaredVariables.txt')"

$B64Arguments = EncodeBase64 $Arguments
$B64Arguments = "powershell -encodedcommand " + $B64Arguments

$Variables = Declarator $B64Arguments  $Timeout

sv ErrorActionPreference Continue

return $Variables
}

<#
Function name: Declarator
Description: Takes a declarating instruction string as input and locally executes them. Declaration output is returned
Function calls: -
Input:  $Declarating, $Timeout
Output: $DeclarationOutput
#>
function Declarator() {
     param(
        [Parameter(
			Mandatory = $True)]
        $Declarating , 
		
		[Parameter(
			Mandatory = $False)]
           $Timeout
    )
         
		$CommandFile = ([System.IO.Path]::GetTempPath() +"DeclarationCommand.ps1");
        $Declarating | Out-File $CommandFile 
            
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
		$t= [int] $Timeout;
		if(-not $Process.WaitForExit($t*1000)){
            Write-Host "Execution stopped after "$t" seconds due timeout" -ForegroundColor red
			Stop-Process $Process
			
        }
	
	$DeclarationOutput = ""
	if ( Test-Path ([System.IO.Path]::GetTempPath() +"DeclaredVariables.txt") ) {
		$DeclarationOutput =  (Get-Content ([System.IO.Path]::GetTempPath() +"DeclaredVariables.txt")) |Out-String
		Remove-Item ([System.IO.Path]::GetTempPath() +"DeclaredVariables.txt")
	}
	if(Test-Path $CommandFile){
		Remove-Item $CommandFile
	}
	
	return $DeclarationOutput
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