### Elliot ###
function Get-BitLockerKey {
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Name", "ComputerName")]
        [string[]]$Computer,

        [Parameter(Position = 1)]
        [string]$ComputerListFile
    )

    if ($ComputerListFile) {
        $computers = Get-Content $ComputerListFile
    } else {
        $computers = $Computer
    }

    foreach ($comp in $computers) {
        if (!$comp.EndsWith('$')) {
            $comp += '$'
        }

        $compsearcher = [adsisearcher]"samaccountname=$comp"
        $compsearcher.PageSize = 200
        $compsearcher.PropertiesToLoad.Add('name') | Out-Null
        $compobj = $compsearcher.FindOne().Properties

        if (!$compobj) {
            throw "$comp not found"
        }

        $keysearcher = [adsisearcher]'objectclass=msFVE-RecoveryInformation'
        $keysearcher.SearchRoot = [string]$compobj.adspath.Trim()
        $keysearcher.PageSize = 200
        $keysearcher.PropertiesToLoad.AddRange(('name', 'msFVE-RecoveryPassword'))

        $keys = $keysearcher.FindAll()

        if ($keys) {
            foreach ($key in $keys) {
                $keyProperties = $key.Properties

                $keyProperties | ForEach-Object {
                    try {
                        Remove-Variable -Name matches -ErrorAction Stop
                    } catch {
                    }
                    ('' + $_.name) -match '^([^\{]+)\{([^\}]+)' | Out-Null

                    $date = $Matches[1]
                    $pwid = $Matches[2]

                    New-Object psobject -Property @{
                        Name        = [string]$compobj.name
                        Date        = $date
                        PasswordID  = $pwid
                        BitLockerKey = [string]$_.Item('msfve-recoverypassword')
                    } | Select-Object name, date, passwordid, bitlockerkey
                }
            }
        } else {
            New-Object psobject -Property @{
                Name        = [string]$compobj.name
                Date        = ''
                PasswordID  = ''
                BitLockerKey = ''
            } | Select-Object name, date, passwordid, bitlockerkey
        }
    }
}
