[CmdletBinding()]
PARAM (
    [Parameter(Mandatory=$True)]
    [string]$URL,

    [Parameter()]
    [string]$FQDN,

    [Parameter()]
    [switch]$NoLogging
)

If ($FQDN) {
    $DNSResolved = (Resolve-DnsName -Name $FQDN).IPAddress
    $CurrentIP = (Invoke-WebRequest -Uri "http://myexternalip.com/raw").Content.Trim()
    
    If ($DNSResolved -ne $CurrentIP) {
        $Update = Invoke-WebRequest -Uri $URL
        $Output = "Webrequest Output: $($Update.Content.Trim())"
    }
    Else {
        $Output = "The IP Address $CurrentIP has not changed."
    }
}
Else {
    $Update = Invoke-WebRequest -Uri $URL
    $Output = "Webrequest Output: $($Update.Content.Trim())"
}

If (!($NoLogging)) {
    New-EventLog -LogName Application -Source "Dynamic DNS Updater" -ErrorAction SilentlyContinue
    Write-EventLog -LogName Application -Source "Dynamic DNS Updater" -EntryType Information -EventId 0 -Category 0 -Message $Output
}