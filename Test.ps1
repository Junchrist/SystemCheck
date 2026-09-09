```powershell
# ============================================================
# Windows PC CHECKER
# Read-only diagnostic checker
# Windows 10 / Windows 11
# ============================================================

Clear-Host

# ------------------------------------------------------------
# Requirements
# ------------------------------------------------------------
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "PowerShell 5.0 or newer is required." -ForegroundColor Red
    exit 1
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ------------------------------------------------------------
# Console title animation
# ------------------------------------------------------------
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

# ------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------
function Stop-Checker {
    try {
        $timer.Stop()
        $timer.Dispose()
    }
    catch {}
}

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
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
        "YES" {
            $color = "Green"
        }

        "NO" {
            $color = "Red"
        }

        "N/A" {
            $color = "DarkGray"
        }

        "UNKNOWN" {
            $color = "Yellow"
        }
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
        return Get-CimInstance Win32_Service `
            -Filter "Name='$Name'" `
            -ErrorAction Stop
    }
    catch {
        return $null
    }
}

function Get-Section {
    param(
        [string]$Title
    )

    Write-Host ""
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ("=" * 62) -ForegroundColor DarkCyan
}

# ------------------------------------------------------------
# ASCII
# ------------------------------------------------------------
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

Fade-Print $asciiArt

Write-Host ""
Write-Host "                    SYSTEM SERVICE & REGISTRY CHECKER" -ForegroundColor White
Write-Host "                    Read-only diagnostic mode" -ForegroundColor Gray
Write-Host ""

# ============================================================
# SERVICES
# ============================================================
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

# ============================================================
# WINDOWS FEATURES / REGISTRY
# ============================================================
Get-Section "WINDOWS FEATURES & REGISTRY"

# ------------------------------------------------------------
# PREFETCH
# ------------------------------------------------------------
$prefetchPath =
    "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"

$prefetch = Get-RegistryValueSafe `
    -Path $prefetchPath `
    -Name "EnablePrefetcher"

if (-not $prefetch.Exists) {
    Write-Status "Prefetch" "UNKNOWN" "Registry value not explicitly configured"
}
else {
    $value = [int]$prefetch.Value

    switch ($value) {
        0 {
            Write-Status "Prefetch" "NO" "Disabled"
        }

        1 {
            Write-Status "Prefetch" "YES" "Application prefetching"
        }

        2 {
            Write-Status "Prefetch" "YES" "Boot prefetching"
        }

        3 {
            Write-Status "Prefetch" "YES" "Application + boot prefetching"
        }

        default {
            Write-Status "Prefetch" "UNKNOWN" "Unexpected value: $value"
        }
    }
}

# ------------------------------------------------------------
# SYSMAIN
# ------------------------------------------------------------
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

# ------------------------------------------------------------
# BAM
# ------------------------------------------------------------
$bamService = Get-ServiceSafe -Name "bam"

if ($null -eq $bamService) {
    # BAM is normally a driver/service component rather than
    # something users should enable/disable manually.
    $bamPath =
        "HKLM:\SYSTEM\CurrentControlSet\Services\bam"

    try {
        $bamKey = Get-ItemProperty `
            -Path $bamPath `
            -ErrorAction Stop

        if ($null -ne $bamKey) {
            Write-Status "BAM" "YES" "BAM service/registry component present"
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

# ------------------------------------------------------------
# PCA
# ------------------------------------------------------------
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

# ------------------------------------------------------------
# EVENT LOG
# ------------------------------------------------------------
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

# ------------------------------------------------------------
# POWERSHELL SCRIPT BLOCK LOGGING
# ------------------------------------------------------------
$loggingPath =
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"

$logging = Get-RegistryValueSafe `
    -Path $loggingPath `
    -Name "EnableScriptBlockLogging"

if (-not $logging.Exists) {
    Write-Status "PowerShell Logging" "UNKNOWN" "Policy not explicitly configured"
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

# ------------------------------------------------------------
# CMD POLICY
# ------------------------------------------------------------
$cmdPath =
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"

$cmd = Get-RegistryValueSafe `
    -Path $cmdPath `
    -Name "DisableCMD"

if (-not $cmd.Exists) {
    Write-Status "CMD Policy" "UNKNOWN" "No explicit DisableCMD policy"
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

# ------------------------------------------------------------
# ACTIVITY HISTORY / ACTIVITY FEED
# ------------------------------------------------------------
$activity = Get-RegistryValueSafe `
    -Path $cmdPath `
    -Name "EnableActivityFeed"

$publish = Get-RegistryValueSafe `
    -Path $cmdPath `
    -Name "PublishUserActivities"

$upload = Get-RegistryValueSafe `
    -Path $cmdPath `
    -Name "UploadUserActivities"

if (
    $activity.Exists -and
    [int]$activity.Value -eq 0
) {
    Write-Status "Activity History" "NO" "Activity Feed disabled by policy"
}
elseif (
    $publish.Exists -and
    [int]$publish.Value -eq 0
) {
    Write-Status "Activity History" "NO" "Publishing user activities disabled"
}
elseif (
    $upload.Exists -and
    [int]$upload.Value -eq 0
) {
    Write-Status "Activity History" "NO" "Uploading user activities disabled"
}
elseif (
    ($activity.Exists -and [int]$activity.Value -eq 1) -or
    ($publish.Exists -and [int]$publish.Value -eq 1) -or
    ($upload.Exists -and [int]$upload.Value -eq 1)
) {
    Write-Status "Activity History" "YES" "Activity policy allows feature"
}
else {
    Write-Status "Activity History" "UNKNOWN" "No explicit policy configured"
}

# ============================================================
# SECURITY
# ============================================================
Get-Section "SECURITY STATUS"

# ------------------------------------------------------------
# WINDOWS DEFENDER
# ------------------------------------------------------------
try {
    $defender = Get-MpComputerStatus -ErrorAction Stop

    if ($defender.AMServiceEnabled -and
        $defender.AntivirusEnabled) {

        if ($defender.RealTimeProtectionEnabled) {
            Write-Status "Defender" "YES" "Antivirus + real-time protection enabled"
        }
        else {
            Write-Status "Defender" "NO" "Real-time protection disabled"
        }
    }
    elseif ($defender.AMServiceEnabled) {
        Write-Status "Defender" "NO" "Antimalware service enabled but AV disabled"
    }
    else {
        Write-Status "Defender" "NO" "Defender antimalware service disabled"
    }
}
catch {
    Write-Status "Defender" "N/A" "Defender status unavailable"
}

# ------------------------------------------------------------
# WINDOWS UPDATE
# ------------------------------------------------------------
$wuauserv = Get-ServiceSafe -Name "wuauserv"

if ($null -eq $wuauserv) {
    Write-Status "Windows Update" "N/A" "Windows Update service unavailable"
}
elseif ($wuauserv.StartMode -eq "Disabled") {
    Write-Status "Windows Update" "NO" "Service disabled"
}
elseif ($wuauserv.State -eq "Running") {
    Write-Status "Windows Update" "YES" "Service running"
}
else {
    Write-Status "Windows Update" "NO" "Service installed but stopped"
}

# ------------------------------------------------------------
# SECURE BOOT
# ------------------------------------------------------------
try {
    $secureBoot = Confirm-SecureBootUEFI -ErrorAction Stop

    if ($secureBoot) {
        Write-Status "Secure Boot" "YES" "Enabled"
    }
    else {
        Write-Status "Secure Boot" "NO" "Disabled"
    }
}
catch {
    if ($_.Exception.Message -match "UEFI") {
        Write-Status "Secure Boot" "N/A" "System is not using supported UEFI mode"
    }
    else {
        Write-Status "Secure Boot" "UNKNOWN" "Unable to determine"
    }
}

# ------------------------------------------------------------
# TPM
# ------------------------------------------------------------
try {
    $tpm = Get-Tpm -ErrorAction Stop

    if (-not $tpm.TpmPresent) {
        Write-Status "TPM" "NO" "TPM not detected"
    }
    elseif ($tpm.TpmReady) {
        Write-Status "TPM" "YES" "TPM present and ready"
    }
    else {
        Write-Status "TPM" "UNKNOWN" "TPM present but not ready"
    }
}
catch {
    Write-Status "TPM" "UNKNOWN" "Unable to query TPM"
}

# ------------------------------------------------------------
# VIRTUALIZATION
# ------------------------------------------------------------
try {
    $computerSystem = Get-CimInstance `
        Win32_ComputerSystem `
        -ErrorAction Stop

    if ($computerSystem.HypervisorPresent) {
        Write-Status "Virtualization" "YES" "Hypervisor detected"
    }
    else {
        # Win32_Processor.VirtualizationFirmwareEnabled tells us
        # whether firmware virtualization is enabled.
        $processors = Get-CimInstance `
            Win32_Processor `
            -ErrorAction Stop

        $virtualizationEnabled = @(
            $processors | Where-Object {
                $_.VirtualizationFirmwareEnabled -eq $true
            }
        ).Count -gt 0

        if ($virtualizationEnabled) {
            Write-Status "Virtualization" "YES" "Firmware virtualization enabled"
        }
        else {
            Write-Status "Virtualization" "NO" "Firmware virtualization not enabled"
        }
    }
}
catch {
    Write-Status "Virtualization" "UNKNOWN" "Unable to determine"
}

# ============================================================
# SYSTEM INFORMATION
# ============================================================
Get-Section "SYSTEM INFORMATION"

try {
    $os = Get-CimInstance Win32_OperatingSystem

    Write-Host ("  OS              : {0}" -f $os.Caption) -ForegroundColor White
    Write-Host ("  Version         : {0}" -f $os.Version) -ForegroundColor White
    Write-Host ("  Architecture    : {0}" -f $os.OSArchitecture) -ForegroundColor White
}
catch {
    Write-Host "  OS information unavailable" -ForegroundColor Yellow
}

try {
    $computer = Get-CimInstance Win32_ComputerSystem

    Write-Host ("  Computer        : {0}" -f $computer.Name) -ForegroundColor White
    Write-Host ("  Manufacturer    : {0}" -f $computer.Manufacturer) -ForegroundColor White
    Write-Host ("  Model           : {0}" -f $computer.Model) -ForegroundColor White
}
catch {
    Write-Host "  Computer information unavailable" -ForegroundColor Yellow
}

# ============================================================
# COMPLETE
# ============================================================
Write-Host ""
Write-Host ("=" * 62) -ForegroundColor DarkCyan
Write-Host "Check Complete!" -ForegroundColor Green
Write-Host ("=" * 62) -ForegroundColor DarkCyan

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
        # Re-run the current script without creating a new
        # PowerShell process or recursively invoking itself.
        Clear-Host
        & $PSCommandPath
    }
}
finally {
    Stop-Checker
}
```
