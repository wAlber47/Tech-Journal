# Gotten from https://dev.to/onlyann/user-password-generation-in-powershell-core-1g91

$symbols = '!@#$%^&*'.ToCharArray()
$characterList = 'a'..'z' + 'A'..'Z' + '0'..'9' + $symbols

function GeneratePassword {
    param(
        [ValidateRange(12, 256)]
        [int] 
        $length = 14
    )

    do {
        $password = -join (0..$length | % { $characterList | Get-Random })
        [int]$hasLowerChar = $password -cmatch '[a-z]'
        [int]$hasUpperChar = $password -cmatch '[A-Z]'
        [int]$hasDigit = $password -match '[0-9]'
        [int]$hasSymbol = $password.IndexOfAny($symbols) -ne -1

    }
    until (($hasLowerChar + $hasUpperChar + $hasDigit + $hasSymbol) -ge 3)

    $password
}

$users = Import-CSV ./user-data.csv

$account_header = "name,account_name,group,password"

$account_file = "accounts.csv"
$group_file = "groups.csv"

$account_array = @()
$group_array = @()

$account_array += $account_header

# Adding Users
foreach ($user in $users)
{
    $account_name = $user.name.ToLower()
    $account_name = $account_name -replace '\s','.'
    $group_name = $user.club.ToLower()
    $group_name = $group_name -replace '\+','_'

    $pw = GeneratePassword(12)
    $row = "{0},{1},{2},{3}" -f $user.name, $account_name, $group_name, $pw
    $account_array += $row
}

# Adding Groups
$groups = $users | Select-Object -Property Club -Unique
foreach($group in $groups)
{
    $group_name = $group.club.ToLower()
    $group_name = $group_name -replace '\+','_'
    $group_array += $group_name
}

# Writing Files
$account_array | Out-File $account_file
$group_array | Out-File $group_file