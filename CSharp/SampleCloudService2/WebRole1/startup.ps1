param
(
   [Parameter(Position=1, Mandatory=$true)]
   [ValidateNotNullOrEmpty()]
   [string]$account,
 
   [Parameter(Position=2, Mandatory=$true)]
   [ValidateNotNullOrEmpty()]
   [string]$subject
)
 
try 
{
   # Full path of the certificate
   $keyName = (((Get-ChildItem -Path cert:\LocalMachine\My | Where-Object { $_.Subject -like "*$subject*" }).PrivateKey).CspKeyContainerInfo).UniqueKeyContainerName
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
