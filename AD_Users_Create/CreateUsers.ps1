Function CreateUser {

    <#
        .SYNOPSIS
            Creates a user in an active directory environment based on random data
        
        .DESCRIPTION
            Starting with the root container this tool randomly places users in the domain.
        
        .PARAMETER Domain
            The stored value of get-addomain is used for this.  It is used to call the PDC and other items in the domain
        
        .PARAMETER OUList
            The stored value of get-adorganizationalunit -filter *.  This is used to place users in random locations.
        
        .PARAMETER ScriptDir
            The location of the script.  Pulling this into a parameter to attempt to speed up processing.
        
        .EXAMPLE
            
     
        
        .NOTES
            
            
            Unless required by applicable law or agreed to in writing, software
            distributed under the License is distributed on an "AS IS" BASIS,
            WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
            See the License for the specific language governing permissions and
            limitations under the License.
            
            Author's blog: https://www.secframe.com
    
        
    #>
    [CmdletBinding()]
    
    param
    (
        [Parameter(Mandatory = $false,
            Position = 1,
            HelpMessage = 'Supply a result from get-addomain')]
            [Object[]]$Domain,
        [Parameter(Mandatory = $false,
            Position = 2,
            HelpMessage = 'Supply a result from get-adorganizationalunit -filter *')]
            [Object[]]$OUList,
        [Parameter(Mandatory = $false,
            Position = 3,
            HelpMessage = 'Supply the script directory for where this script is stored')]
        [string]$ScriptDir
    )
    
        if(!$PSBoundParameters.ContainsKey('Domain')){
            if($args[0]){
                $setDC = $args[0].pdcemulator
                $dnsroot = $args[0].dnsroot
            }
            else{
                $setDC = (Get-ADDomain).pdcemulator
                $dnsroot = (get-addomain).dnsroot
            }
        }
            else {
                $setDC = $Domain.pdcemulator
                $dnsroot = $Domain.dnsroot
            }
        if (!$PSBoundParameters.ContainsKey('OUList')){
            if($args[1]){
                $OUsAll = $args[1]
            }
            else{
                $OUsAll = get-adobject -Filter {objectclass -eq 'organizationalunit'} -ResultSetSize 300
            }
        }else {
            $OUsAll = $OUList
        }
        if (!$PSBoundParameters.ContainsKey('ScriptDir')){
            
            if($args[2]){

                # write-host "line 70"
                $scriptPath = $args[2]}
            else{
                    # write-host "did i get here"
                    $scriptPath = "$((Get-Location).path)\AD_Users_Create\"
            }
            
        }else{
            $scriptpath = $ScriptDir
        }


        Function Get-RockYouPasswords {
            param (
                [string]$FilePath = "rockyou-AD.txt"
            )
        
            if (Test-Path $FilePath) {
                $passwords = Get-Content -Path $FilePath
                return $passwords
            } else {
                Write-Error "Password file not found: $FilePath"
                return @()
            }
        }

    # Get the rockyou passwords
    $passwords = Get-RockYouPasswords
    if ($passwords.Count -eq 0) {
        Write-Error "No passwords available from rockyou.txt"
        return
    }

    # Your existing code to create a user, using $randomPassword for the password
    # For example:
    # New-ADUser -Name "John Doe" -AccountPassword (ConvertTo-SecureString $randomPassword -AsPlainText -Force) -OtherParameters ...
    
    
        
    #get owner all parameters and store as variable to call upon later
           
        
    
    #=======================================================================
    
    #will work on adding things to containers later $ousall += get-adobject -Filter {objectclass -eq 'container'} -ResultSetSize 300|where-object -Property objectclass -eq 'container'|where-object -Property distinguishedname -notlike "*}*"|where-object -Property distinguishedname -notlike  "*DomainUpdates*"
    
    $ouLocation = (Get-Random $OUsAll).distinguishedname
    
    
    
    $accountType = 1..100|get-random 
    if($accountType -le 3){ # X percent chance of being a service account
    #service
    $nameSuffix = "SA"
    $description = 'Created with secframe.com/badblood.'
    #removing do while loop and making random number range longer, sorry if the account is there already
    # this is so that I can attempt to import multithreading on user creation
    
        $name = ""+ (Get-Random -Minimum 100 -Maximum 9999999999) + "$nameSuffix"
        
        
    }else{
        $surname = get-content("$($scriptpath)\..\AD_Users_Create\Names\familynames-usa-top1000.txt")|get-random
        # Write-Host $surname
    $genderpreference = 0,1|get-random
    if ($genderpreference -eq 0){$givenname = get-content("$($scriptpath)\..\AD_Users_Create\Names\femalenames-usa-top1000.txt")|get-random}else{$givenname = get-content($scriptpath + '\..\AD_Users_Create\Names\malenames-usa-top1000.txt')|get-random}
    $name = $givenname+"_"+$surname
    }
    
        $departmentnumber = [convert]::ToInt32('9999999') 
        
        
    #Need to figure out how to do the L attribute
    $description = 'Created with secframe.com/badblood.'
    $pwd = $passwords | Get-Random
    #======================================================================
    # 
    
    $passwordinDesc = 1..1000|get-random
        
        $pwd = $passwords | Get-Random
            if ($passwordinDesc -lt 10) { 
                $description = 'Just so I dont forget my password is ' + $pwd 
            }else{}
    if($name.length -gt 20){
        $name = $name.substring(0,20)
    }

    $exists = $null
    try {
        $exists = Get-ADUSer $name -ErrorAction Stop
    } catch{}

    if($exists){
        return $true
    }

    new-aduser -server $setdc  -Description $Description -DisplayName $name -name $name -SamAccountName $name -Surname $name -Enabled $true -Path $ouLocation -AccountPassword (ConvertTo-SecureString ($pwd) -AsPlainText -force)
    
    
    
        
    
    $pwd = ''

    #==============================
    # Set Does Not Require Pre-Auth for ASREP
    #==============================
    
    $setASREP = 1..1000|get-random
    if($setASREP -lt 20){
	Get-ADuser $name | Set-ADAccountControl -DoesNotRequirePreAuth:$true
    }
    
    #===============================
    #SET ATTRIBUTES - no additional attributes set at this time besides UPN
    #Todo: Set SPN for kerberoasting.  Example attribute edit is in createcomputers.ps1
    #===============================
    
    $upn = $name + '@' + $dnsroot
    try{Set-ADUser -Identity $name -UserPrincipalName "$upn" }
    catch{}
    
    # return $false
    ################################
    #End Create User Objects
    ################################
    
    }
    
