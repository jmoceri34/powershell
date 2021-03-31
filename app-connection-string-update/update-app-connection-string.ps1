# Use this to update an app.config connection string
function UpdateAppConfigConnectionString($filePath, $dataSource, $initialCatalog, $user, $password, $applicationName)
{	
	# file not found, nothing to do
	if (-Not (Test-Path $filePath))
	{
		Write-Output "File not found: $filePath"
		return
	}

	# read the config in xml
	[System.Xml.XmlDocument]$doc = new-object System.Xml.XmlDocument
	$doc.Load($filePath)

	# create the new connection string
	$newConnectionString = "Data Source=$dataSource;Initial Catalog=$initialCatalog;UID=$user;PWD=$password;Application Name=$applicationName"

	# find the connection string 
	foreach($item in $doc.get_DocumentElement().connectionStrings.add)
	{
		# use your name here
		if($item.name -eq 'TestConnectionString')
		{
			$item.connectionString = $newConnectionString
		}           
	}

	# save the new file
	$doc.Save($filePath)
}

# use this to update an appsettings.json connection string
function UpdateAppSettingsConnectionString($filePath, $dataSource, $initialCatalog, $user, $password, $applicationName)
{	
	# file not found, nothing to do
	if (-Not (Test-Path $filePath))
	{
		Write-Output "File not found: $filePath"
		return
	}

	# read the config in json
	$appSettingsJson = Get-Content -Raw $filePath | ConvertFrom-Json

	# create the new connection string
	$newConnectionString = "Data Source=$dataSource;Initial Catalog=$initialCatalog;UID=$user;PWD=$password;Application Name=$applicationName"

	# update the json connection string name. If you know the path hard-code it
	$appSettingsJson.Settings.ConnectionStrings.Database = $newConnectionString

	# save the new file, use as much depth as you want and need
	$appSettingsJson | ConvertTo-Json -depth 16 | Set-Content $filePath
}

# using this to validate parameters before updating configuration files
function ValidateParameter($name, $envName)
{
	if ([string]::IsNullOrWhiteSpace($envName))
	{
		Write-Output "$name cannot be empty."
		exit
	}
}

# Use environment variables in production and test credentials locally only for ease, use env variables locally too, and validate
$dataSource = if ($Env:AppConfigDataSource) { $Env:AppConfigDataSource } else { "localhost" }
ValidateParameter "Data Source" $dataSource

$initialCatalog = if ($Env:AppConfigInitialCatalog) { $Env:AppConfigInitialCatalog } else { "Database" }
ValidateParameter "Initial Catalog" $initialCatalog

$user = if ($Env:AppConfigUser) { $Env:AppConfigUser } else { "TestUser" }
ValidateParameter "User" $user

$password = if ($Env:AppConfigPassword) { $Env:AppConfigPassword } else {  "TestPassword" }
ValidateParameter "Password" $password

$applicationName = if ($Env:AppConfigApplicationName) { $Env:AppConfigApplicationName } else { "TestApplicationName" }
ValidateParameter "Application Name" $applicationName

# Resolve-path will look locally for the file. Good for testing.

# for updating app.config
$filePath = if (-Not $Env:AppConfigFilePath) { $Env:AppConfigFilePath } else { Resolve-Path "./app.config" } 
UpdateAppConfigConnectionString $filePath $dataSource $initialCatalog $user $password $applicationName

# or updating appsettings.json
$filePath = if ($Env:AppSettingsFilePath) { $Env:AppSettingsFilePath } else { Resolve-Path "./appsettings.json" }
UpdateAppSettingsConnectionString $filePath $dataSource $initialCatalog $user $password $applicationName
