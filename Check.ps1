Clear-Host

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Set-ConsoleTitle {
    param($Title)
    $null = [System.Console]::Title = $Title
}

$titles = @(
    "[ @sYs ] | PC-CHECK",
    "[ @sYs ] | CHECK",
    "[ @sYs ] | @junchrist",
    "[ @sYs ] | SYSTEM",
    "[ @sYs ] | REGISTRY"
)

$titleIndex = 0
$timer = [System.Windows.Forms.Timer]::new()
$timer.Interval = 1000
$timer.Add_Tick({
    $global:titleIndex = ($global:titleIndex + 1) % $titles.Length
    Set-ConsoleTitle -Title $titles[$global:titleIndex]
})
$timer.Start()

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
    param($Text, $Delay = 50)
    $lines = $Text -split "`n"
    foreach ($line in $lines) {
        if ($line.Trim() -ne "") {
            Write-Host $line -ForegroundColor Cyan
        } else {
            Write-Host ""
        }
        Start-Sleep -Milliseconds $Delay
    }
}

Fade-Print -Text $asciiArt -Delay 30

Write-Host ""
Write-Host "                    SYSTEM SERVICE & REGISTRY CHECKER" -ForegroundColor White
Write-Host "                    Created by @junchrist on Discord" -ForegroundColor Gray
Write-Host ""

Write-Host "SERVICE STATUS" -ForegroundColor Cyan
Write-Host ("═" * 50) -ForegroundColor Cyan

$services = @(
    @{Name="SysMain"; Display="SysMain"},
    @{Name="PcaSvc"; Display="Program Compatibility Assistant Service"},
    @{Name="EventLog"; Display="Windows Event Log"},
    @{Name="Bam"; Display="Background Activity Moderator Driver"},
    @{Name="Appinfo"; Display="Application Information"},
    @{Name="CDPSvc"; Display="Connected Devices Platform Service"}
)

foreach ($svc in $services) {
    try {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            if ($service.Status -eq "Running") {
                Write-Host ("  {0,-10} {1,-40} {2,-10}" -f $svc.Name, $svc.Display, "RUNNING") -ForegroundColor Green
            } else {
                Write-Host ("  {0,-10} {1,-40} {2,-10}" -f $svc.Name, $svc.Display, $service.Status.ToString().ToUpper()) -ForegroundColor Red
            }
        } else {
            Write-Host ("  {0,-10} {1,-40} {2,-10}" -f $svc.Name, $svc.Display, "NOT FOUND") -ForegroundColor Yellow
        }
    } catch {
        Write-Host ("  {0,-10} {1,-40} ERROR" -f $svc.Name, $svc.Display) -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "REGISTRY SETTINGS" -ForegroundColor Cyan
Write-Host ("═" * 50) -ForegroundColor Cyan

try {
    $prefetch = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -ErrorAction SilentlyContinue
    if ($prefetch) {
        switch ($prefetch.EnablePrefetcher) {
            3 { $status = "Enabled (App and Boot)"; $color = "Green" }
            2 { $status = "Enabled (Boot only)"; $color = "Green" }
            1 { $status = "Enabled (App only)"; $color = "Green" }
            0 { $status = "Disabled"; $color = "Red" }
            default { $status = "Unknown: $($prefetch.EnablePrefetcher)"; $color = "Yellow" }
        }
        Write-Host ("  {0,-25} {1}" -f "Prefetch:", $status) -ForegroundColor $color
    } else {
        Write-Host ("  {0,-25} {1}" -f "Prefetch:", "Not Found") -ForegroundColor Yellow
    }
} catch {
    Write-Host ("  {0,-25} {1}" -f "Prefetch:", "Error") -ForegroundColor Red
}

try {
    $sysmainReg = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSysMain" -ErrorAction SilentlyContinue
    if ($sysmainReg) {
        if ($sysmainReg.EnableSysMain -eq 1) {
            Write-Host ("  {0,-25} {1}" -f "SysMain:", "Enabled") -ForegroundColor Green
        } else {
            Write-Host ("  {0,-25} {1}" -f "SysMain:", "Disabled") -ForegroundColor Red
        }
    } else {
        Write-Host ("  {0,-25} {1}" -f "SysMain:", "Not Found (Default: Enabled)") -ForegroundColor Yellow
    }
} catch {
    Write-Host ("  {0,-25} {1}" -f "SysMain:", "Error") -ForegroundColor Red
}

try {
    $pcaReg = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ProgramCompatibilityAssistant" -Name "Enabled" -ErrorAction SilentlyContinue
    if ($pcaReg) {
        if ($pcaReg.Enabled -eq 1) {
            Write-Host ("  {0,-25} {1}" -f "PcaSvc:", "Enabled") -ForegroundColor Green
        } else {
            Write-Host ("  {0,-25} {1}" -f "PcaSvc:", "Disabled") -ForegroundColor Red
        }
    } else {
        Write-Host ("  {0,-25} {1}" -f "PcaSvc:", "Not Found (Default: Enabled)") -ForegroundColor Yellow
    }
} catch {
    Write-Host ("  {0,-25} {1}" -f "PcaSvc:", "Error") -ForegroundColor Red
}

try {
    $powershellLogging = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -ErrorAction SilentlyContinue
    if ($powershellLogging) {
        if ($powershellLogging.EnableScriptBlockLogging -eq 1) {
            Write-Host ("  {0,-25} {1}" -f "PowerShell Logging:", "Enabled") -ForegroundColor Green
        } else {
            Write-Host ("  {0,-25} {1}" -f "PowerShell Logging:", "Disabled") -ForegroundColor Red
        }
    } else {
        Write-Host ("  {0,-25} {1}" -f "PowerShell Logging:", "Not Found (Default: Disabled)") -ForegroundColor Yellow
    }
} catch {
    Write-Host ("  {0,-25} {1}" -f "PowerShell Logging:", "Error") -ForegroundColor Red
}

try {
    $cmd = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableCMD" -ErrorAction SilentlyContinue
    if ($cmd) {
        if ($cmd.DisableCMD -eq 0) {
            Write-Host ("  {0,-25} {1}" -f "CMD Available:", "Yes") -ForegroundColor Green
        } else {
            Write-Host ("  {0,-25} {1}" -f "CMD Available:", "No") -ForegroundColor Red
        }
    } else {
        Write-Host ("  {0,-25} {1}" -f "CMD Available:", "Yes (Default)") -ForegroundColor Green
    }
} catch {
    Write-Host ("  {0,-25} {1}" -f "CMD Available:", "Error") -ForegroundColor Red
}

try {
    $activitiesCache = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -ErrorAction SilentlyContinue
    if ($activitiesCache) {
        if ($activitiesCache.EnableActivityFeed -eq 1) {
            Write-Host ("  {0,-25} {1}" -f "Activities Cache:", "Enabled") -ForegroundColor Green
        } else {
            Write-Host ("  {0,-25} {1}" -f "Activities Cache:", "Disabled") -ForegroundColor Red
        }
    } else {
        Write-Host ("  {0,-25} {1}" -f "Activities Cache:", "Not Found (Default: Enabled)") -ForegroundColor Yellow
    }
} catch {
    Write-Host ("  {0,-25} {1}" -f "Activities Cache:", "Error") -ForegroundColor Red
}

Write-Host ""
Write-Host ("═" * 50) -ForegroundColor Gray
Write-Host "Check Complete!" -ForegroundColor Green

Write-Host ""
Write-Host "Options:" -ForegroundColor Yellow
Write-Host "  [1] Run again" -ForegroundColor White
Write-Host "  [2] Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1 or 2)"

if ($choice -eq "1") {
    Clear-Host
    & $MyInvocation.MyCommand.Path
} else {
    Write-Host "Exiting..." -ForegroundColor Gray
    $timer.Stop()
    $timer.Dispose()
    exit
}
