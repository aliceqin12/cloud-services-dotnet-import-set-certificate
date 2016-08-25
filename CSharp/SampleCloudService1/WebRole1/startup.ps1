param
(
    [Parameter(Position=1, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$account,
 
    [Parameter(Position=2, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$path,
 
    [Parameter(Position=3, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$password
)

try 
{
    # Create the certificate
    $flags = "Exportable,MachineKeySet,PersistKeySet"
    $pfxcert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($path, $password, $flags) -ErrorAction Stop
 
    # Create the X509 store and import the certificate
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "LocalMachine") -ErrorAction Stop
    $store.Open("MaxAllowed")
    $store.Add($pfxcert)
    $store.Close()
 
    # Full path of the certificate
    $thumbprint = $pfxcert.Thumbprint
    $keyName = (((Get-ChildItem -Path cert:\LocalMachine\My | Where-Object { $_.thumbprint -eq $thumbprint }).PrivateKey).CspKeyContainerInfo).UniqueKeyContainerName
    $keyPath = $env:ProgramData + "\Microsoft\Crypto\RSA\MachineKeys\"
    $fullPath = $keyPath + $keyName
 
    # Get the current acl of the private key
    $acl = Get-Acl -Path $fullPath

    # Create the rule
    $permission = "$account","Read,FullControl","Allow"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($permission) -ErrorAction Stop

    # Add the rule to the acl of the private key
    $acl.AddAccessRule($accessRule);
 
    # Write back the new acl
    Set-Acl -Path $fullPath -AclObject $acl
    Get-Acl -Path $fullPath | Format-list
}
catch
{
    throw $_
}
