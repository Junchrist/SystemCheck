Clear-Host

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$titles = @(
    "[ @sYs ] | PC-CHECK",
    "[ @sYs ] | CHECK",
    "[ @sYs ] | @junchrist",
    "[ @sYs ] | SYSTEM",
    "[ @sYs ] | REGISTRY"
)

$titleIndex = 0

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000

$timer.Add_Tick({
    $script:titleIndex = ($script:titleIndex + 1) % $titles.Count
    try {
        [Console]::Title = $titles[$script:titleIndex]
    }
    catch {}
})

$timer.Start()

function Stop-Checker {
    try {
        $timer.Stop()
        $timer.Dispose()
    }
    catch {}
}

function Write-Status {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [ValidateSet("YES","NO","N/A","UNKNOWN")]
        [string]$Status,
        [string]$Details = ""
    )

    switch ($Status) {
        "YES" { $color = "Green" }
        "NO" { $color = "Red" }
        "N/A" { $color = "DarkGray" }
        "UNKNOWN" { $color = "Yellow" }
    }

    $statusText = "[{0}]" -f $Status
    Write-Host ("  {0,-25} " -f $Name) -NoNewline -ForegroundColor White
    Write-Host ("{0,-10}" -f $statusText) -NoNewline -ForegroundColor $color
    if ($Details) {
        Write-Host $Details -ForegroundColor Gray
    }
    else {
        Write-Host ""
    }
}

function Get-RegistryValueSafe {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Name
    )

    try {
        $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop
        return @{
            Exists = $true
            Value  = $item.$Name
        }
    }
    catch {
        return @{
            Exists = $false
            Value  = $null
        }
    }
}

function Get-ServiceSafe {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    try {
        return Get-CimInstance Win32_Service -Filter "Name='$Name'" -ErrorAction Stop
    }
    catch {
        return $null
    }
}

function Get-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ""
}

function Fade-Print {
    param(
        [string]$Text,
        [int]$Delay = 20
    )

    foreach ($line in ($Text -split "`r?`n")) {
        Write-Host $line -ForegroundColor Cyan
        Start-Sleep -Milliseconds $Delay
    }
}

$asciiArt = @"
▓█████  █    ██  ▄████▄   ██░ ██  ▄▄▄       ██▀███   ██▓  ██████ ▄▄▄█████▓
▓█   ▀  ██  ▓██▒▒██▀ ▀█  ▓██░ ██▒▒████▄    ▓██ ▒ ██▒▓██▒▒██    ▒ ▓  ██▒ ▓▒
▒███   ▓██  ▒██░▒▓█    ▄ ▒██▀▀██░▒██  ▀█▄  ▓██ ░▄█ ▒▒██▒░ ▓██▄   ▒ ▓██░ ▒░
▒▓█  ▄ ▓▓█  ░██░▒▓▓▄ ▄██▒░▓█ ░██ ░██▄▄▄▄██ ▒██▀▀█▄  ░██░  ▒   ██▒░ ▓██▓ ░ 
░▒████▒▒▒█████▓ ▒ ▓███▀ ░░▓█▒░██▓ ▓█   ▓██▒░██▓ ▒██▒░██░▒██████▒▒  ▒██▒ ░ 
░░ ▒░ ░░▒▓▒ ▒ ▒ ░ ░▒ ▒  ░ ▒ ░░▒░▒ ▒▒   ▓▒█░░ ▒▓ ░▒▓░░▓  ▒ ▒▓▒ ▒ ░  ▒ ░░   
 ░ ░  ░░░▒░ ░ ░   ░  ▒    ▒ ░▒░ ░  ▒   ▒▒ ░  ░▒ ░ ▒░ ▒ ░░ ░▒  ░ ░    ░    
   ░    ░░░ ░ ░ ░         ░  ░░ ░  ░   ▒     ░░   ░  ▒ ░░  ░  ░    ░      
   ░  ░   ░     ░ ░       ░  ░  ░      ░  ░   ░      ░        ░           
                ░                                                         
"@

Fade-Print $asciiArt

Write-Host ""
Write-Host "                    SYSTEM SERVICE & REGISTRY CHECKER" -ForegroundColor White
Write-Host "                    Created by @junchrist on Discord" -ForegroundColor Gray
Write-Host ""

Get-Section "SERVICE STATUS"

$serviceList = @(
    @{ Name = "SysMain";  Display = "SysMain" },
    @{ Name = "PcaSvc";   Display = "Program Compatibility Assistant" },
    @{ Name = "EventLog"; Display = "Windows Event Log" },
    @{ Name = "Appinfo";  Display = "Application Information" },
    @{ Name = "CDPSvc";   Display = "Connected Devices Platform" }
)

foreach ($entry in $serviceList) {
    $service = Get-ServiceSafe -Name $entry.Name
    if ($null -eq $service) {
        Write-Status $entry.Display "N/A" "Service not present"
        continue
    }
    if ($service.State -eq "Running") {
        Write-Status $entry.Display "YES" "Running"
    }
    elseif ($service.StartMode -eq "Disabled") {
        Write-Status $entry.Display "NO" "Disabled"
    }
    else {
        Write-Status $entry.Display "NO" "Installed but not running"
    }
}

Get-Section "REGISTRY SETTINGS"

$prefetchPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
$prefetch = Get-RegistryValueSafe -Path $prefetchPath -Name "EnablePrefetcher"

if (-not $prefetch.Exists) {
    Write-Status "Prefetch" "UNKNOWN" "Registry value not configured"
}
else {
    $value = [int]$prefetch.Value
    switch ($value) {
        0 { Write-Status "Prefetch" "NO" "Disabled" }
        1 { Write-Status "Prefetch" "YES" "Application prefetching" }
        2 { Write-Status "Prefetch" "YES" "Boot prefetching" }
        3 { Write-Status "Prefetch" "YES" "Application + boot prefetching" }
        default { Write-Status "Prefetch" "UNKNOWN" "Unexpected value: $value" }
    }
}

$sysMain = Get-ServiceSafe -Name "SysMain"
if ($null -eq $sysMain) {
    Write-Status "SysMain" "N/A" "Service not installed"
}
elseif ($sysMain.StartMode -eq "Disabled") {
    Write-Status "SysMain" "NO" "Service disabled"
}
elseif ($sysMain.State -eq "Running") {
    Write-Status "SysMain" "YES" "Running"
}
else {
    Write-Status "SysMain" "NO" "Installed but stopped"
}

$bamService = Get-ServiceSafe -Name "bam"
if ($null -eq $bamService) {
    $bamPath = "HKLM:\SYSTEM\CurrentControlSet\Services\bam"
    try {
        $bamKey = Get-ItemProperty -Path $bamPath -ErrorAction Stop
        if ($null -ne $bamKey) {
            Write-Status "BAM" "YES" "Registry component present"
        }
        else {
            Write-Status "BAM" "UNKNOWN" "Unable to determine"
        }
    }
    catch {
        Write-Status "BAM" "UNKNOWN" "Component not accessible"
    }
}
else {
    if ($bamService.State -eq "Running") {
        Write-Status "BAM" "YES" "Running"
    }
    else {
        Write-Status "BAM" "UNKNOWN" "Present but state is $($bamService.State)"
    }
}

$pcaService = Get-ServiceSafe -Name "PcaSvc"
if ($null -eq $pcaService) {
    Write-Status "PCA" "N/A" "PcaSvc not installed"
}
elseif ($pcaService.StartMode -eq "Disabled") {
    Write-Status "PCA" "NO" "PcaSvc disabled"
}
elseif ($pcaService.State -eq "Running") {
    Write-Status "PCA" "YES" "PcaSvc running"
}
else {
    Write-Status "PCA" "NO" "PcaSvc installed but stopped"
}

$eventLog = Get-ServiceSafe -Name "EventLog"
if ($null -eq $eventLog) {
    Write-Status "Event Log" "N/A" "Service not installed"
}
elseif ($eventLog.StartMode -eq "Disabled") {
    Write-Status "Event Log" "NO" "Service disabled"
}
elseif ($eventLog.State -eq "Running") {
    Write-Status "Event Log" "YES" "Running"
}
else {
    Write-Status "Event Log" "NO" "Installed but stopped"
}

$loggingPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
$logging = Get-RegistryValueSafe -Path $loggingPath -Name "EnableScriptBlockLogging"

if (-not $logging.Exists) {
    Write-Status "PowerShell Logging" "UNKNOWN" "Policy not configured"
}
elseif ([int]$logging.Value -eq 1) {
    Write-Status "PowerShell Logging" "YES" "Script Block Logging enabled"
}
elseif ([int]$logging.Value -eq 0) {
    Write-Status "PowerShell Logging" "NO" "Script Block Logging disabled"
}
else {
    Write-Status "PowerShell Logging" "UNKNOWN" "Unexpected value"
}

$cmdPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$cmd = Get-RegistryValueSafe -Path $cmdPath -Name "DisableCMD"

if (-not $cmd.Exists) {
    Write-Status "CMD Policy" "UNKNOWN" "No explicit policy configured"
}
elseif ([int]$cmd.Value -eq 0) {
    Write-Status "CMD Policy" "YES" "CMD is allowed"
}
elseif ([int]$cmd.Value -eq 1) {
    Write-Status "CMD Policy" "NO" "CMD disabled by policy"
}
elseif ([int]$cmd.Value -eq 2) {
    Write-Status "CMD Policy" "NO" "CMD disabled; batch files restricted"
}
else {
    Write-Status "CMD Policy" "UNKNOWN" "Unexpected value"
}

$activity = Get-RegistryValueSafe -Path $cmdPath -Name "EnableActivityFeed"
$publish = Get-RegistryValueSafe -Path $cmdPath -Name "PublishUserActivities"
$upload = Get-RegistryValueSafe -Path $cmdPath -Name "UploadUserActivities"

if ($activity.Exists -and [int]$activity.Value -eq 0) {
    Write-Status "Activity History" "NO" "Activity Feed disabled by policy"
}
elseif ($publish.Exists -and [int]$publish.Value -eq 0) {
    Write-Status "Activity History" "NO" "Publishing user activities disabled"
}
elseif ($upload.Exists -and [int]$upload.Value -eq 0) {
    Write-Status "Activity History" "NO" "Uploading user activities disabled"
}
elseif (($activity.Exists -and [int]$activity.Value -eq 1) -or
        ($publish.Exists -and [int]$publish.Value -eq 1) -or
        ($upload.Exists -and [int]$upload.Value -eq 1)) {
    Write-Status "Activity History" "YES" "Activity policy allows feature"
}
else {
    Write-Status "Activity History" "UNKNOWN" "No explicit policy configured"
}

Write-Host ""
Write-Host "Check Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Legend:" -ForegroundColor Yellow
Write-Host "  YES     = Detected / enabled / running" -ForegroundColor Green
Write-Host "  NO      = Disabled / stopped / not detected" -ForegroundColor Red
Write-Host "  N/A     = Not applicable / unavailable on this system" -ForegroundColor DarkGray
Write-Host "  UNKNOWN = Could not safely determine the state" -ForegroundColor Yellow

Write-Host ""
Write-Host "[1] Run again" -ForegroundColor White
Write-Host "[2] Exit" -ForegroundColor White
Write-Host ""

try {
    $choice = Read-Host "Enter your choice (1 or 2)"
    if ($choice -eq "1") {
        Clear-Host
        & $PSCommandPath
    }
}
finally {
    Stop-Checker
}
