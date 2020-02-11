Write-Host "Add DNS server!"
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "10.225.220.206"
Write-Host "Check DNS server!"
Get-DnsClientServerAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4
