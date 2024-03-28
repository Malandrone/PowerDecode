<#
Function name: ExtractShellcode
Description: Checks and exstract shellcode from input script   
Function calls: IsShellcodeHexEncoded, DisassembleHexString,IsShellcodeDecEncoded, DisassembleDecString, DisassembleBase64String
Input:  $Script , $BxorKey
Output: $data
#>
function ExtractShellcode()  {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [string]$Script ,
			
			[Parameter( 
                Mandatory=$False, 
                Valuefrompipeline = $True)]
            [int]$BxorKey
		)
      
sv ErrorActionPreference 'SilentlyContinue'  

$data = " "
if(IsShellcodeHexEncoded $Script){
$data += DisassembleHexString $Script $BxorKey
}

if(IsShellcodeHexEncoded2 $Script){
$data += DisassembleHexString2 $Script $BxorKey
}

if(IsShellcodeDecEncoded $Script){
$data += DisassembleDecString $Script $BxorKey
}

$data += DisassembleBase64String $Script $BxorKey

sv ErrorActionPreference 'Continue'

return  $data
}

<#
Function name: IsShellcodeHexEncoded
Description: Recognizes hexadecimal encoded shellcode
Function calls: -
Input:  $Script
Output: $true/false
#>
function IsShellcodeHexEncoded()  {
	 param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [string]$Script
		)

<# example:
0xfc,0x48,0x83,0xe4,0xf0,0xe8,0xcc,0x0
#>
$Script = $Script.toLower()
$Script =$Script.replace(" ","")

if(($Script -match "[byte[]]") -or ($Script -match "virtualalloc")  ){
$regex=@"
((0x)([a-f0-9]{1,2})(\,)){8,}
"@
	$pattern = [regex]  $regex
	$matches = $pattern.matches($Script)

	if($matches.count -gt 0){
		return $true
	}
}
return $false
}

function IsShellcodeHexEncoded2()  {
	 param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [string]$Script
		)

<# example:
fromHEXString('df6ba0c7d3cbeb232323627262737
#>

$Script = $Script.toLower()
$Script =$Script.replace(" ","")

if(($Script -match "[byte[]]") -or ($Script -match "virtualalloc")  ){
$regex=@"
fromhexstring\(['"]([a-f0-9]{16,})['"]\)
"@
	$pattern = [regex]  $regex
	$matches = $pattern.matches($Script)

	if($matches.count -gt 0){
		return $true
	}
}
return $false
}

<#
Function name: DisassembleHexString
Description: Analyzes hexadecimal encoded shellcode and returns the disassembled code
Function calls: ConvertHexStringToByteArray,BxorShellcode, GetAssemblyInstructions, GetSCDBGReport
Input:  $Script, $BxorKey
Output: $data
#>
function DisassembleHexString()  {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [string]$Script ,
			
			[Parameter( 
                Mandatory=$False, 
                Valuefrompipeline = $True)]
            [int]$BxorKey 
		)


$data = ""

$pattern = [regex]  "(0x[0-9a-z]\,){1,1}"
$matches = $pattern.matches($Script)

foreach ($match in $matches){
  $byte = $match.value.replace('0x', '' )
  $Script = $Script.replace(  $match.value ,"0x0"+$byte   )
}

$lowerstring = ($Script.toLower()) |Out-String
$lowerstring = $lowerstring.replace('0x','').replace(',',' ')

$pattern =  [regex] "(\=)([\s\@\(]*)([a-f0-9\s]{8,})([\)\;]*)"
$matches = $pattern.matches($lowerstring)

foreach ( $match in $matches ) {
 $shellcode = $match.value
 $shellcode= $shellcode.replace('=','').replace(';','').replace("@","").replace("(","").replace(")","")
 $HexString = $shellcode.replace(' ', '').replace("[byte[]]", "")
 if($HexString.length -ge 32){
	 [byte[]] $bytes = ConvertHexStringToByteArray $HexString 
	 
	 if ($BxorKey) { 
		   $bytes  =  BxorShellcode $bytes $BxorKey 
		   $HexString = $bytes | Foreach-Object {[System.Convert]::ToString($_,16)}
		   $i=0
		   foreach ($h in $HexString) { 
			 if ($h.length -lt 2) {    
				$HexString[$i] = "0"+$h
			 }   
			$i++;
			}
		   $HexString = [String]::Join('', $HexString)
		   
		}
	 
	 $assembly = Format-Hex -InputObject $bytes
	 $AssemblyInstructions =  (GetAssemblyInstructions -Architecture X86 -Mode Mode16 -Code $bytes -Offset 0x1000) | Out-String 
	 
	 $data += "Script attempts to inject shellcode into memory; Assembly instructions are encoded in hexadecimal (0x[a-f0-9]) " + "`n`n" + $assembly
	 $data += "`n`n" +"Assembly instructions:"+$AssemblyInstructions +"`n`n" 
	 $data += GetSCDBGReport $HexString

	}
}

return  $data 
}

function DisassembleHexString2()  {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [string]$Script ,
			
			[Parameter( 
                Mandatory=$False, 
                Valuefrompipeline = $True)]
            [int]$BxorKey 
		)

$data = ""

$Script=$Script.toLower()
$Script=$Script.replace(" ","")

$regex =@"
([a-f0-9]{16,})
"@

$pattern = [regex] $regex
$matches = $pattern.matches($Script)

foreach( $match in $matches) {

$HexString = $match.value
if($HexString.length -ge 32){
	$bytes = [byte[]]::new($HexString.Length / 2)

	for ($i = 0; $i -lt $HexString.Length; $i += 2) {
		$bytes[$i / 2] = [byte]::Parse($HexString.Substring($i, 2), [System.Globalization.NumberStyles]::HexNumber)
	}

	 if ($BxorKey) { 
		   $bytes  =  BxorShellcode $bytes $BxorKey 
		   $HexString = $bytes | Foreach-Object {[System.Convert]::ToString($_,16)}
		   $i=0
		   foreach ($h in $HexString) { 
			 if ($h.length -lt 2) {    
				$HexString[$i] = "0"+$h
			 }   
			$i++;
			}
		   $HexString = [String]::Join('', $HexString)
		   
		}
	 
	 $assembly = Format-Hex -InputObject $bytes
	 $AssemblyInstructions =  (GetAssemblyInstructions -Architecture X86 -Mode Mode16 -Code $bytes -Offset 0x1000) | Out-String 
	 
	 $data += "Script attempts to inject shellcode into memory; Assembly instructions are encoded in hexadecimal " + "`n`n" + $assembly
	 $data += "`n`n" +"Assembly instructions:"+$AssemblyInstructions +"`n`n" 
	 $data += GetSCDBGReport $HexString

	}
}

return  $data 
}

<#
Function name: IsShellcodeDecEncoded
Description: Recognizes decimal encoded shellcode
Function calls: -
Input:  $Script
Output: $true/false
#>
function IsShellcodeDecEncoded()  {
	 param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [string]$Script
		)

<# example:
77,90,144,0,3,0,0,0,4
#>

$Script = $Script.toLower()
$Script =$Script.replace(" ","")

if(($Script -match "[byte[]]") -or ($Script -match "virtualalloc") ){
$regex=@"
(([0-9]{1,3})(\,)){8,}
"@
	$pattern = [regex]  $regex
	$matches = $pattern.matches($Script)

	if($matches.count -gt 0){
		return $true
	}
}

return $false
}

<#
Function name: DisassembleDecString
Description: Analyzes decimal encoded shellcode and returns the disassembled code
Function calls: ConvertDecStringToByteArray,BxorShellcode, GetAssemblyInstructions, GetSCDBGReport
Input:  $Script, $BxorKey
Output: $data
#>
function DisassembleDecString()  {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [string]$Script ,
			
			[Parameter( 
                Mandatory=$False, 
                Valuefrompipeline = $True)]
            [int]$BxorKey 
		)

$data = ""

$Script = $Script.toLower();
$Script = $Script.replace(" ","");

$regex =@"
(\[byte\[\]\]){0,1}(\$)([a-z0-9{}]{1,})(\=)((\[byte\[\]\]){0,1})([\(\@\'\"]{1,})([\d\,]*)
"@

$pattern = [regex] $regex
$matches = $pattern.matches($Script)

$DecString=""
foreach($match in $matches){
	
	$Decstring = ($match.value) -replace "(\[byte\[\]\]){0,1}(\$)([a-z0-9{}]{1,})(\=)((\[byte\[\]\]){0,1})" , "" #\[byte\[\]\](\$)([0-9a-z{}\s]{1,})\=
	$DecString = ($DecString.replace("(","")).replace(")","").replace("'","").replace('"','').replace("=","").replace("@","");

	$DecArray  = $DecString.split(",")
			
	[byte[]] $bytes = ConvertDecStringToByteArray $DecArray
		
	$HexString = ($bytes|ForEach-Object ToString X2) -join ' '
	$HexString = $HexString.replace(" ","")
	if($HexString.length -ge 32){
		if ($BxorKey) { 
			   $bytes  =  BxorShellcode $bytes $BxorKey 
			   $HexString = $bytes | Foreach-Object {[System.Convert]::ToString($_,16)}
			   $i=0
			   foreach ($h in $HexString) { 
				 if ($h.length -lt 2) {    
					$HexString[$i] = "0"+$h
				 }   
				$i++;
				}
			   $HexString = [String]::Join('', $HexString)
			   
			}
			
		$assembly = Format-Hex -InputObject $bytes
		$AssemblyInstructions =  (GetAssemblyInstructions -Architecture X86 -Mode Mode16 -Code $bytes -Offset 0x1000) | Out-String 

		$data += "Script attempts to inject shellcode into memory; Assembly instructions are encoded in decimal " + "`n`n" + $assembly
		$data += "`n`n" +"Assembly instructions:"+$AssemblyInstructions +"`n`n"
		$data += GetSCDBGReport $HexString

	}
}

return  $data 
}

<#
Function name: DisassembleBase64String
Description: Analyzes base64 encoded shellcode and returns the disassembled code
Function calls: ConvertDecStringToByteArray,BxorShellcode, GetAssemblyInstructions, GetSCDBGReport
Input:  $Script, $BxorKey
Output: $data
#>
function DisassembleBase64String()  {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [string]$Script ,
			
			[Parameter( 
                Mandatory=$False, 
                Valuefrompipeline = $True)]
            [int]$BxorKey 
		)

<# example:
32ugx9PL6yMjI2JyYnNxc
#>

$data = ""

$regex=@"
(\[\s*[Bb][Yy][Tt][Ee]\s*\[\s*\]\s*\]\s*){0,1}\$.+\s*\=\s*\[[Ss][Yy][Ss][Tt][Ee][Mm][.][Cc][Oo][Nn][Vv][Ee][Rr][Tt]\]\:\:[Ff][Rr][Oo][Mm][Bb][Aa][Ss][Ee]64[Ss][Tt][Rr][Ii][Nn][Gg][\s\(\'\"]+([A-Za-z0-9\+\/]{5,})[\=]{0,2}
"@

$pattern = [regex] $regex
$matches = $pattern.matches($Script)

foreach( $match in $matches) {

$shellcode = $match.value

$regex =@"
(\[\s*[Bb][Yy][Tt][Ee]\s*\[\s*\]\s*\]\s*){0,1}\$.+\s*\=\s*\[[Ss][Yy][Ss][Tt][Ee][Mm][.][Cc][Oo][Nn][Vv][Ee][Rr][Tt]\]\:\:[Ff][Rr][Oo][Mm][Bb][Aa][Ss][Ee]64[Ss][Tt][Rr][Ii][Nn][Gg][\s\(\'\"]+
"@

$pattern = [regex] $regex
$matches = $pattern.matches($shellcode)

$junkdata = $matches[0].value
$shellcode= $shellcode.replace($junkdata ,"")

[Byte[]] $bytes = [System.Convert]::FromBase64String($shellcode)
$HexString = ($bytes|ForEach-Object ToString X2) -join ' '
$HexString = $HexString.replace(" ","")
if($HexString.length -ge 32){
	if ($BxorKey) { 
		   $bytes  =  BxorShellcode $bytes $BxorKey 
		   $HexString = $bytes | Foreach-Object {[System.Convert]::ToString($_,16)}
		   $i=0
		   foreach ($h in $HexString) { 
			 if ($h.length -lt 2) {    
				$HexString[$i] = "0"+$h
			 }   
			$i++;
			}
		   $HexString = [String]::Join('', $HexString)
		   
		   }

	$assembly = Format-Hex -InputObject $bytes
	$AssemblyInstructions =  (GetAssemblyInstructions -Architecture X86 -Mode Mode16 -Code $bytes -Offset 0x1000) | Out-String 

	$data += "Script contains base64 encoded shellcode: " + "`n`n" + $assembly
	$data += "`n`n" +"Assembly instructions:"+$AssemblyInstructions +"`n`n"
	$data += GetSCDBGReport $HexString

	}
}

return  $data 
}

<#
Function name: GetSCDBGReport
Description: If scdbg.exe is on the PowerDecode folder, shellcode dynamic analysis is returned in results
Function calls: -
Input:  $HexString
Output: $data
#>
function GetSCDBGReport()  {
        param(
			[Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [string]$HexString
		)

$data = ""
		
if (!(Test-Path scdbg.exe)){
	$data += "`n`n" +"PowerDecode analysis ends here, please analyze this code on a debugger to get more information:"+ "`n`n"
	$data += "`n"+"Input for SCDBG (http://sandsprite.com/blogs/index.php?uid=7&pid=152):"+"`n"+$HexString+ "`n"
	$data += "`n" +"########## You can place the scdbg.exe file on the PowerDecode folder "+ "`n"
}

else {
 $HexString  | Out-File -Encoding ASCII sh.txt
 $scdbg = (.\scdbg -f sh.txt -nc) |Out-String

 $data += "`n"+"Following string has been analyzed by SCDBG (http://sandsprite.com/blogs/index.php?uid=7&pid=152):"+"`n"+$HexString+ "`n"
 $data += "`n`n" +"##########"+ "`n"
 $data += "`n`n" +"SCDBG Execution report:"+ "`n"
 $data += "`n"+$scdbg+ "`n"
 Remove-Item sh.txt
}
 
return  $data 
}

<#
Function name: BxorShellcode
Description: Takes an array of bytes as input and performs bxor with a key value. Result is returned 
Function calls: -
Input: $VarCode , $key
Output: $VarCode
#>
function BxorShellcode()  {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [Byte[]]$VarCode ,
			
			 [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [int]$key
        
		)
      

for ($i = 0; $i -lt $VarCode.Count; $i++) {        
 $VarCode[$i] = $VarCode[$i]  -bxor $key
 }
 
return $VarCode
}

<#
Function name: ConvertHexStringToByteArray
Description: Takes an array of hexadecimals as input and returns an array containing those values converted into bytes
Function calls: -
Input: $String
Output: $bytes
#>
function ConvertHexStringToByteArray
{

[CmdletBinding()]
Param ( [Parameter(Mandatory = $True, ValueFromPipeline = $True)] [String] $String )


if ($String.Length -eq 0) { 
return 
}
 
if ($String.Length -eq 1) { 
[byte[]] $bytes = ([System.Convert]::ToByte($String,16)) 
return $bytes 
}

if (($String.Length % 2 -eq 0) -and ($String.IndexOf(":") -eq -1)) { 
[byte[]] $bytes = $String -split '([a-f0-9]{2})' | foreach-object { if ($_) {[System.Convert]::ToByte($_,16)}} 
return $bytes 
}
else{
      if ($String.IndexOf(":") -ne -1){ 
      [byte[]] $bytes = $String -split ':+' | foreach-object {[System.Convert]::ToByte($_,16)} 
      return $bytes 
	  }
}

}

<#
Function name: ConvertDecStringToByteArray
Description: Takes an array of decimal strings as input and returns an array containing those values converted into bytes
Function calls: -
Input: $String
Output: $bytes
#>
function ConvertDecStringToByteArray
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String[]] $String
    )
	
	$Decimals = @()
	foreach ($number in $String) {
		$n = [int]$number
		$Decimals += $n
	}

   [byte[]] $bytes = $Decimals

    return $bytes
}

<#
Function name: GetAssemblyInstructions
Description: Takes an array of bytes as input and returns its assembly instructions
Function calls: -
Input: $bytes
Output: -
#>
function GetAssemblyInstructions () {

    [OutputType([Capstone.Instruction])]
    [CmdletBinding(DefaultParameterSetName = 'Disassemble')]
    Param (
        [Parameter(Mandatory, ParameterSetName = 'Disassemble')]
        [Capstone.Architecture]
        $Architecture,

        [Parameter(Mandatory, ParameterSetName = 'Disassemble')]
        [Capstone.Mode]
        $Mode,

        [Parameter(Mandatory, ParameterSetName = 'Disassemble')]
        [ValidateNotNullOrEmpty()]
        [Byte[]]
        $Code,

        [Parameter( ParameterSetName = 'Disassemble' )]
        [UInt64]
        $Offset = 0,

        [Parameter( ParameterSetName = 'Disassemble' )]
        [UInt32]
        $Count = 0,

        [Parameter( ParameterSetName = 'Disassemble' )]
        [ValidateSet('Intel', 'ATT')]
        [String]
        $Syntax,

        [Parameter( ParameterSetName = 'Disassemble' )]
        [Switch]
        $DetailOn,

        [Parameter( ParameterSetName = 'Version' )]
        [Switch]
        $Version
    )

    if ($PsCmdlet.ParameterSetName -eq 'Version')
    {
        $Disassembly = New-Object Capstone.Capstone([Capstone.Architecture]::X86, [Capstone.Mode]::Mode16)
        $Disassembly.Version

        return
    }

    $Disassembly = New-Object Capstone.Capstone($Architecture, $Mode)

    if ($Disassembly.Version -ne [Capstone.Capstone]::BindingVersion)
    {
        Write-Error "capstone.dll version ($([Capstone.Capstone]::BindingVersion.ToString())) should be the same as libcapstone.dll version. Otherwise, undefined behavior is likely."
    }

    if ($Syntax)
    {
        switch ($Syntax)
        {
            'Intel' { $SyntaxMode = [Capstone.OptionValue]::SyntaxIntel }
            'ATT'   { $SyntaxMode = [Capstone.OptionValue]::SyntaxATT }
        }

        $Disassembly.SetSyntax($SyntaxMode)
    }

    if ($DetailOn)
    {
        $Disassembly.SetDetail($True)
    }

   
	$Disassembly.Disassemble($Code, $Offset, $Count)
    
	return

}