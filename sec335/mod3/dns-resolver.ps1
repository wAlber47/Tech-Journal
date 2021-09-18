param ($subnet, $dns_server)

for ($i=1, $i -le 255; $i++)
{
	Resolve-DNSName -DNSOnly "$subnet.$i" -Server $dns_server -ErrorAction Ignore | Select-Object Name,NameHost
}