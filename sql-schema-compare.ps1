param(
	[string]$msbuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
	[string]$projectPath,
	[string]$visualStudioVersion = "16.0",
	[Parameter(Mandatory=$true)][string]$source,
	[Parameter(Mandatory=$true)][string]$target,
	[Parameter(Mandatory=$true)][string]$xmlOutputPath
)

if ([string]::IsNullOrWhiteSpace($projectPath))
{
	$projectPath = Resolve-Path *.sqlproj | select -ExpandProperty Path
}

$args = @("$projectPath", "/t:SqlSchemaCompare", "/p:VisualStudioVersion=$visualStudioVersion", "/p:source=`"$source`"", "/p:target=`"$target`"", "/p:XmlOutput=`"$xmlOutputPath`"");

& $msbuildPath $args