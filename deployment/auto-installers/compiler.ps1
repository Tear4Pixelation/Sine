[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Runtime,

    [Parameter(Mandatory=$false)]
    [switch]$Help
)


$Green = "Green"
$Red = "Red"
$Cyan = "Cyan"
$Yellow = "Yellow"
$NoColor = "White" # PowerShell's default foreground color is often white or light gray

$all_runtimes = @(
    "win-x64",
    "win-arm64",
    "osx-x64",
    "osx-arm64",
    "linux-x64",
    "linux-arm64",
    "linux-musl-x64",
    "linux-musl-arm64"
)

# Function to display help message
function Show-Help {
    Write-Host "Usage: ." -ForegroundColor $Cyan
    Write-Host ""
    Write-Host "Options:" -ForegroundColor $Cyan
    Write-Host "  -Runtime <RUNTIME>  Specify a single runtime to publish for (e.g., win-x64, osx-arm64)." -ForegroundColor $Yellow
    Write-Host "                      If not specified, the script will publish for all predefined runtimes."
    Write-Host "  -Help               Display this help message." -ForegroundColor $Yellow
    Write-Host ""
    Write-Host "Available Runtimes:" -ForegroundColor $Cyan
    foreach ($rt in $all_runtimes) {
        Write-Host "  - $rt" -ForegroundColor $NoColor # Using $NoColor for the list items
    }
    Write-Host ""
    Write-Host "Example:" -ForegroundColor $Cyan
    Write-Host "  .compile.ps1"
    Write-Host "  .compile.ps1 -Runtime linux-x64"
    Write-Host ""
}

# Check for -Help switch
if ($Help) {
    Show-Help
    exit 0
}

# Determine which runtimes to process
$runtimes_to_process = @()
if (-not [string]::IsNullOrEmpty($Runtime)) {
    # Validate if the specific runtime is in our list of known runtimes
    $found = $false
    foreach ($rt in $all_runtimes) {
        if ($rt -eq $Runtime) {
            $found = $true
            break
        }
    }

    if ($found) {
        $runtimes_to_process += $Runtime
    } else {
        Write-Host "Error: Invalid runtime specified: '$Runtime'" -ForegroundColor $Red
        Write-Host "Available runtimes:" -ForegroundColor $Yellow
        foreach ($rt in $all_runtimes) {
            Write-Host "  - $rt"
        }
        exit 1
    }
} else {
    # If no specific runtime, process all
    $runtimes_to_process = $all_runtimes
}

# Loop through the runtimes and publish
foreach ($runtime in $runtimes_to_process) {
    Write-Host "Publishing for $runtime..." -ForegroundColor $Green

    # Execute the dotnet publish command
    dotnet publish -c Release -r $runtime --self-contained -p:PublishSingleFile=true -p:PublishTrimmed=true -p:TrimMode=partial -o "publish/$runtime"

    # Check the exit code of the last executed command
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Successfully published for $runtime" -ForegroundColor $Green
    } else {
        Write-Host "✗ Failed to publish for $runtime" -ForegroundColor $Red
    }
    Write-Host ""
}

Write-Host "Build process completed!" -ForegroundColor $Cyan
