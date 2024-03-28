<#
Function name: DeobfuscateByRegex
Description: Receives as input a script and performs de-obfuscation applying a set of regular expressions
Function calls: GoodSyntax, ReplaceMultiLineEscapes, ReplaceNonEscapes, ReplaceQuotesFunctionName, CleanFunctionCalls, ReplaceParens, ReplaceFunctionParensWrappers, ConcatenateCleanup, ResolveStringFormats, ResolveReplaces, RemoveTicks, ReplaceDoublequotes,RemovePowerShellCall,ReplaceChars
Input:  $Script 
Output: $NewScript
#>
function DeobfuscateByRegex 
	{
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

	   sv ErrorActionPreference 'SilentlyContinue'
 
	   $TempScript = ''
       $OldScript = ''
       $NewScript = $Script

       While( $NewScript -ne $OldScript )
       {
        
			$OldScript = $NewScript
					
			$TempScript  = ResolveStringFormats($NewScript )
			if (GoodSyntax $TempScript ) { $NewScript = $TempScript  }
			 
			$TempScript  = ResolveStringFormats2($NewScript )
			if (GoodSyntax $TempScript ) { $NewScript = $TempScript  }
			 
			$TempScript  = ResolveStringFormats3($NewScript )
			if (GoodSyntax $TempScript ) { $NewScript = $TempScript  }
			 
            $TempScript  = ReplaceMultiLineEscapes($NewScript)
            if ((GoodSyntax $TempScript)) { $NewScript = $TempScript  }
			
			$TempScript  = ReplaceNonEscapes($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript }
			  
            $TempScript = ReplaceQuotesFunctionName($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			 
			 $TempScript = ReplaceQuotesFunctionName2($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
            $TempScript = CleanFunctionCalls($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
            $TempScript = ReplaceParens($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
            $TempScript = ReplaceFunctionParensWrappers($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			 
            $TempScript = ConcatenateCleanup($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
			$TempScript = ConcatenateCleanup2($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			 
            $TempScript = ResolveReplaces($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
			$TempScript = ResolveReplaces2($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
			$TempScript = ResolveReverse($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
        
		    $TempScript = RemoveTicks($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
			$TempScript = ReplaceDoublequotes($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
			$TempScript = RemovePowerShellCall($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			 
			$TempScript = RemovePowerShellCall2($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
			$TempScript = RemovePowerShellCall3($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
			$TempScript = RemovePowerShellCall4($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
			$TempScript = ReplaceChars($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
			
			$TempScript = ReplaceChars2($NewScript )
			if (GoodSyntax $TempScript) { $NewScript = $TempScript  }
		 
		}
        
		sv ErrorActionPreference 'Continue'  
        
		return $NewScript

	}

<#
Function name: ReplaceQuotesFunctionName
Description: Removes <"> and <'> obfuscation characters from function names 
Function calls: -
Input:  $Script 
Output: $Script
#>
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
			UpdateLog ("[ReplaceQuotesFunctionName]: matches:  "+$matches);
	        $OldScript = $Script
            ForEach($match in $matches){
                
                $TempScript = $Script.Replace($match.value, $match.ToString().replace('"','').replace("'",""))
			    if (GoodSyntax $TempScript ) { $Script = $TempScript  }
				
				
                }
            $matches = $pattern.Matches($Script)
			if ($Script -eq $OldScript) { break; }
        }
       
       return $Script

    }

function ReplaceQuotesFunctionName2
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

 
$regex = @"
[\&\.][\'\"](\s){0,}([A-Za-z0-9\-]){0,}(\s){0,}[\'\"]
"@

$pattern = [regex] $regex
     $matches = $pattern.Matches($Script) 

       
       While ($matches.Count -gt 0){
	   UpdateLog ("[ReplaceQuotesFunctionName2]: matches:  "+$matches);
	   $OldScript = $Script
            ForEach($match in $matches){
                $TempScript = $Script.Replace($match.value, $match.ToString().replace('"','').replace("'","").replace(".","").replace("&",""))
				if (GoodSyntax $TempScript ) { $Script = $TempScript  }
                }
            $matches = $pattern.Matches($Script) 
        
		if ($Script -eq $OldScript) { break; }
		
		}
       
       return $Script

    }

<#
Function name: ReplaceFunctionParensWrappers
Description: Removes <.&('...')> and <.&("...")> obfuscation characters from function names 
Function calls: -
Input:  $Script 
Output: $Script
#>
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
		UpdateLog ("[ReplaceFunctionParensWrappers]: matches:  "+$matches);
	    $OldScript = $Script
            ForEach($match in $matches){
                
                $TempScript = $Script.Replace($match.value, $match.ToString().replace('.','').replace('&','').replace("('",'').replace("')",'').replace('("','').replace('")',''))
				if (GoodSyntax $TempScript ) { $Script = $TempScript  }
                }
            $matches = $pattern.Matches($Script) 
        if ($Script -eq $OldScript) { break; }
		}
       
       return $Script

    }

<#
Function name: CleanFunctionCalls
Description: Removes <"> , <'> and <`> obfuscation characters from function names 
Function calls: -
Input:  $Script 
Output: $Script
#>
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
		UpdateLog ("[CleanFunctionCalls]: matches:  "+$matches);
	    $OldScript = $Script
            ForEach($match in $matches){
                $ReplacedValue = ($match.value).ToString().replace('"','').replace("'",'')
                
                $TempScript = $Script.Replace($match.value, $ReplacedValue )
				if (GoodSyntax $TempScript ) { $Script = $TempScript  }
                }
            $matches = $pattern.Matches($Script) 
			if ($Script -eq $OldScript) { break; }
        }
       
       return $Script

    }

<#
Function name: ReplaceParens
Description: Removes <(> and <)> obfuscation characters from function names 
Function calls: -
Input:  $Script 
Output: $Script
#>
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
		UpdateLog ("[ReplaceParens]: matches:  "+$matches);
	    $OldScript = $Script
            ForEach($match in $matches){
                
                $TempScript = $Script.Replace(($match.value), ($match.value).ToString().replace('(','').replace(')',''))
				if (GoodSyntax $TempScript ) { $Script = $TempScript  }
                }
            $matches = $pattern.Matches($Script) 
        if ($Script -eq $OldScript) { break; }
		}
       
       return $Script

    }

<#
Function name: ReplaceNonEscapes
Description: Removes obfuscation residuals 
Function calls: -
Input:  $Script 
Output: $NewScript
#>
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

<#
Function name: ReplaceMultiLineEscapes
Description: Removes multi line escape characters
Function calls: -
Input:  $Script 
Output: $Script
#>
function ReplaceMultiLineEscapes
    {
        param(
            [Parameter(Mandatory=$True)]
            [string]$Script
        )

        $pattern = [regex]'`\s*\r\n\s*'
        $matches = $pattern.Matches($Script)


        While ($matches.Count -gt 0){
		 $OldScript = $Script
            
            ForEach($match in $matches){
                
                $TempScript = $Script.Replace(($match.value), ' ')
				if (GoodSyntax $TempScript ) { $Script = $TempScript  }
                }
            $matches = $pattern.Matches($Script)
			if ($Script -eq $OldScript) { break; }
        }
    return $Script
}

<#
Function name: ResolveStringFormats
Description: Removes string-based reorder obfuscation not dependent on IEX  
Function calls: -
Input:  $Script 
Output: $Script
#>
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
		
	    $OldScript = $Script
            ForEach($match in $matches){
				
                $SolvedString = IEX($match)
				UpdateLog ("[ResolveStringFormats]: match: "+($match.value)+" Solved string: "+$SolvedString);
               
                $TempScript = $Script.Replace(($match.value), "'$($SolvedString)'")
				if (GoodSyntax $TempScript ) { $Script = $TempScript  }
                }
            $matches = $pattern.Matches($Script)
			if ($Script -eq $OldScript) { break; }
        }
       
       return $Script
    }

function ResolveStringFormats2
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )


$regex= @"
(\()(\s*)[\'\"](\s*)(((\s*)(\{)(\s*)(\d)(\s*)(\})(\s*)){1,})(\s*)[\'\"](\s*)(\-)[Ff](\s*)((['"](\s*)(([\s0-9A-Z_a-z\!\#\$\%\&\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\\\]\^\{\|\}\~]){1,})(\s*)['"](\s*)(\,*)(\s*)){1,})(\s*)(\))
"@

       $pattern = [regex] $regex
       $matches = $pattern.Matches($Script) 

    While ($matches.Count -gt 0){
	  
	  $OldScript = $Script
            ForEach($match in $matches){
				
                $SolvedString = IEX($match)
				UpdateLog ("[ResolveStringFormats2]: match: "+($match.value)+" Solved string: "+$SolvedString);
               
                $TempScript = $Script.Replace($match.value , "'$($SolvedString)'")
				if (GoodSyntax $TempScript ) { $Script = $TempScript  }
                }
            $matches = $pattern.Matches($Script)
			if ($Script -eq $OldScript) { break; }
        }
       
       return $Script
    }

function ResolveStringFormats3
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )


$regex= @"
(\(){0,}(\s){0,}[\"\'](\s){0,}(\{\d+\}){1,}(\s){0,}[\"\'](\s){0,}\-(\s){0,}[fF](.){0,}(\s){0,}(\)){0,}
"@

       $pattern = [regex] $regex
       $matches = $pattern.Matches($Script) 

     While ($matches.Count -gt 0){
	  
	  $OldScript = $Script
            ForEach($match in $matches){
				
                $SolvedString = IEX($match)
				UpdateLog ("[ResolveStringFormats3]: match: "+($match.value)+" Solved string: "+$SolvedString);
               
                $TempScript = $Script.Replace($match.value , "'$($SolvedString)'")
				if (GoodSyntax $TempScript ) { $Script = $TempScript  }
                }
            $matches = $pattern.Matches($Script)
			if ($Script -eq $OldScript) { break; }
        }
       
       return $Script
    }

<#
Function name: ResolveReplaces 
Description: Removes string-based replace obfuscation not dependent on IEX  
Function calls: -
Input:  $Script 
Output: $Script
#>
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
		
	    $OldScript = $Script
            ForEach($match in $matches){
                try{
				
				$SolvedString = IEX($match)
                $SolvedString = $SolvedString.replace("'","''")
				UpdateLog ("[ResolveReplaces]: match: "+($match.value)+" Solved string: "+$SolvedString   );
                
                $TempScript = $Script.Replace($match.value, "'$($SolvedString)'")
				if (GoodSyntax $TempScript ) { $Script = $TempScript  }
                }
				catch { }
			}
				
            $matches = $pattern.Matches($Script) 
			if ($Script -eq $OldScript) { break; }
        }
       
       return $Script
    }

function ResolveReplaces2
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

$regex = @"
["'](.*?)["'](\s{0,})\-([CcIi]{0,1})[Rr][Ee][Pp][Ll][Aa][Cc][Ee](\s{0,})\((.*?)\)
"@

       $pattern = [regex]  $regex
       $matches = $pattern.Matches($Script)

       While ($matches.Count -gt 0){
		
	    $OldScript = $Script
            ForEach($match in $matches){
				try { 
                $SolvedString = IEX($match)
                UpdateLog ("[ResolveReplaces2]: match: "+($match.value)+" Solved string: "+$SolvedString   );
                
                $TempScript = $Script.Replace($match.value, "'$($SolvedString)'")
				if (GoodSyntax $TempScript ) { $Script = $TempScript  }
				}
				catch { }
				}
            $matches = $pattern.Matches($Script) 
			if ($Script -eq $OldScript) { break; }
        
		}
       
       return $Script
    }
<#
Function name: ResolveReverse
Description: Removes string-based reverse obfuscation not dependent on IEX  
Function calls: -
Input:  $Script 
Output: $Script
#>
function ResolveReverse
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

$regex = @"
\-[Jj][Oo][Ii][Nn]([\(\s]+)(\[)(\s*)[Rr][Ee][Gg][Ee][Xx](\s*)(\])(\s*)\:\:[Mm][Aa][Tt][Cc][Hh][Ee][Ss][\s\'\"\(]*(.*)[Tt][Oo][Ll][Ee][Ff][Tt]([\s\'\"\)]+)([\s\|]*)([FfOoRrEeAaCcHhBbJjTt\%\-]{1,14})(\s*)([_\s\$\.VvAaLlUuEe\{\}\)]*)\-[Jj][Oo][Ii][Nn]([\s\']*)(\){2,2})
"@

       $pattern = [regex] $regex
       $matches = $pattern.Matches($Script)

       While ($matches.Count -gt 0){
		
	    $OldScript = $Script
            ForEach($match in $matches){
                
				
				$SolvedString = IEX($match)
                $SolvedString = " ('"+$SolvedString+"') "
				UpdateLog ("[ResolveReverse]: match: "+($match.value)+" Solved string: "+$SolvedString   );
                
                $TempScript = $Script.Replace($match.value, "$($SolvedString)")
				if (GoodSyntax $TempScript ) { $Script = $TempScript  }
                
				
			}
				
            $matches = $pattern.Matches($Script) 
			if ($Script -eq $OldScript) { break; }
        }
       
       return $Script
    }

<#
Function name: ConcatenateCleanup 
Description: Removes string-based concatenating obfuscation not dependent on IEX  
Function calls: -
Input:  $Script 
Output: $Script
#>
function ConcatenateCleanup
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
     

$TempScript = $Script.Replace("'+'", "").Replace('"+"','')
if (GoodSyntax $TempScript ) { $Script = $TempScript  }

      return $Script
    }


function ConcatenateCleanup2
   {
         param(
             [Parameter(
                Mandatory=$True,
                Valuefrompipeline = $True)]
            [String]$Script
         )
 $pattern1 = [regex] "'(\s){0,}\+(\s){0,}'"
 $matches = $pattern1.matches($Script)
 foreach ($match in $matches){
 
 $TempScript = $Script.replace( $match ,""  )
 if (GoodSyntax $TempScript ) { $Script = $TempScript  }

 }
 
 
 
$pattern2 = [regex] '"(\s){0,}\+(\s){0,}"'
$matches = $pattern2.matches($Script)
 foreach ($match in $matches){
 $TempScript = $Script.replace( $match ,""  )
  if (GoodSyntax $TempScript ) { $Script = $TempScript  }
 }
 
 return $Script
 }
  
<#
Function name: RemoveTicks 
Description: Removes "`"
Function calls: -
Input:  $Script 
Output: $Script
#>
function RemoveTicks
   {
         param(
             [Parameter(
                Mandatory=$True,
                Valuefrompipeline = $True)]
            [String]$Script
         )
 
 $tick = Get-Content package\symbols\tick.txt
 $TempScript = $Script.replace($tick,"")
 if (GoodSyntax $TempScript ) { $Script = $TempScript  }
  
 return $Script
 }
 
<#
Function name: ReplaceDoublequotes 
Description: Replaces ” doublequotes with " or ' 
Function calls: -
Input:  $Script 
Output: $Script
#>
function ReplaceDoublequotes
   {
         param(
             [Parameter(
                Mandatory=$True,
                Valuefrompipeline = $True)]
            [String]$Script
         )
 
 $doublequotes = Get-Content package\symbols\doublequotes.txt
 $TempScript = $Script.replace($doublequotes,"'")
 if (GoodSyntax $TempScript ) { $Script = $TempScript }
 else{
	 $TempScript = $Script
	 $TempScript = $Script.replace($doublequotes,'"')
	 if (GoodSyntax $TempScript ) { $Script = $TempScript }
 } 
 
 return $Script
 }

<#
Function name: RemovePowerShellCall
Description: Removes the Powershell call header 
Function calls: -
Input:  $Script 
Output: $Script
#>
function RemovePowerShellCall
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
	
<# examples: 
powershell.exe -executionpolicy bypass  -c " <command> " 
PowerShell   -command '<command>'
#>

$regex1 = @"
[Pp][Oo][Ww][Ee][Rr][Ss][Hh][Ee]([Ll]{2,2})((\.[Ee][Xx][Ee]){0,})(\s*)(([\/\-]([\s0-9a-zA-Z]){1,}){1,})[\'\"](.*)[\'\"]
"@

$regex2=@"
[Pp][Oo][Ww][Ee][Rr][Ss][Hh][Ee]([Ll]{2,2})((\.[Ee][Xx][Ee]){0,})(\s*)(([\/\-]([\s0-9a-zA-Z]){1,}){1,})
"@

$regex3=@"
^[\'"]+|[\'"]+$
"@	

	$pattern1 = [regex] $regex1 
	$matches1 = $pattern1.matches($Script)
	
	
	foreach ($m1 in $matches1){
		$Script = ($m1.value).toString() 	
	
	}
		
	$pattern2 = [regex] $regex2 
	$matches2 = $pattern2.matches($Script)
	
	foreach ($m2 in $matches2){
		$Script=$Script.replace($m2.value,"") 	
	
	}

	$pattern3 = [regex] $regex3 
	$matches3 = $pattern3.matches($Script)
	
	$Script = $Script -replace $regex3 , ""
	
       return $Script
	}

function RemovePowerShellCall2
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
	
<# examples: 
powershell.exe " <command> " 
PowerShell    'command'
#>

$regex1 = @"
[Pp][Oo][Ww][Ee][Rr][Ss][Hh][Ee]([Ll]{2,2})((\.[Ee][Xx][Ee]){0,})(\s*)[\'\"](.*)[\'\"]
"@

$regex2=@"
[Pp][Oo][Ww][Ee][Rr][Ss][Hh][Ee]([Ll]{2,2})((\.[Ee][Xx][Ee]){0,})(\s*)
"@

$regex3=@"
^[\'"]+|[\'"]+$
"@	

	$pattern1 = [regex] $regex1 
	$matches1 = $pattern1.matches($Script)
	
	
	foreach ($m1 in $matches1){
		$Script = ($m1.value).toString() 	
	
	}
		
	$pattern2 = [regex] $regex2 
	$matches2 = $pattern2.matches($Script)
	
	foreach ($m2 in $matches2){
		$Script=$Script.replace($m2.value,"") 	
	
	}

	$pattern3 = [regex] $regex3 
	$matches3 = $pattern3.matches($Script)
	
	$Script = $Script -replace $regex3 , ""
	
       return $Script
	}

function RemovePowerShellCall3
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

<# examples: 
powershell  <command>  
POWERSHELL.EXE  -NOP -EXEC BYPASS -NONI get-help  command
#>

$regex = @"
[Pp][Oo][Ww][Ee][Rr][Ss][Hh][Ee]([Ll]{2,2})((\.[Ee][Xx][Ee])){0,}(\s{1,})(\-[A-Za-z\s]{1,})
"@
	$pattern = [regex] $regex 
	$matches = $pattern.matches($Script)
	
	foreach($match in $matches){
	$Script = $Script.replace($match,"")	
		
	}
	
	
	return $Script
	}
	
function RemovePowerShellCall4
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )

$regex1 = @"
[\]{0,1}[Pp][Oo][Ww][Ee][Rr][Ss][Hh][Ee]([Ll]{2,2})((\.[Ee][Xx][Ee]['"])){0,}(\s*)(.*)
"@
	$pattern = [regex] $regex1 
	$matches = $pattern.matches($Script)

$regex2 = @"
[Pp][Oo][Ww][Ee][Rr][Ss][Hh][Ee]([Ll]{2,2})((\.[Ee][Xx][Ee]['"])){0,}(\s*)
"@
	
	$Script = ($matches[0].value) -replace $regex2 , ''
	$Script = $Script -replace "\\[Vv]\d\.\d\\",""	
	$Script = $Script -replace "[\/\-][Ww][Ii][Nn][Dd]{0,1}[Oo]{0,1}[Ww]{0,1}[Ss]{0,1}[Tt]{0,1}[Yy]{0,1}[Ll]{0,1}[Ee]{0,1}\s*[Hh][Ii]{0,1}[Dd]{0,2}[Ee]{0,1}[Nn]{0,1}\s*" , ""
	
	return $Script
	}
	
<#
Function name: ReplaceChars
Description: Replaces "[Char]n" values with their correspondent ASCII characters 
Function calls: -
Input:  $Script 
Output: $Script
#>
function ReplaceChars
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
	
$regex=@"
\[(\s*)[Cc][Hh][Aa][Rr](\s*)\](\s*)([0-9]+)
"@

$pattern = [regex] $regex
$matches = $pattern.matches($Script)

foreach($match in $matches){
	$TempScript=""
	$resolved = IEX($match.value)
	$resolved = "'"+$resolved+"'"
	$TempScript = $Script.replace($match.value , $resolved)
	if (GoodSyntax $TempScript ) { $Script = $TempScript }
	else{
	 $TempScript = $Script
	}
	
}

	return $Script
	}

function ReplaceChars2
    {
        param(
            [Parameter( 
                Mandatory=$True, 
                Valuefrompipeline = $True)]
            [String]$Script
        )
	
$regex=@"
\[(\s*)[Cc][Hh][Aa][Rr](\s*)\](\s*)((\(){1,1}(\s*)([0-9\+\*\-\/\[\]A-Za-z]+)(\s*)((\){1,1})))
"@

$pattern = [regex] $regex
$matches = $pattern.matches($Script)

foreach($match in $matches){
	$TempScript=""
	$resolved = IEX($match.value)
	$resolved = "'"+$resolved+"'"
	$TempScript = $Script.replace($match.value , $resolved)
	if (GoodSyntax $TempScript ) { $Script = $TempScript }
	else{
	 $TempScript = $Script
	}
	
}

	return $Script
	}