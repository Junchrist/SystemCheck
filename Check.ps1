Write-Host @"
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
"@ -ForegroundColor Cyan
Write-Host ""
Write-Host "                    SYSTEM SERVICE & REGISTRY CHECKER" -ForegroundColor White
Write-Host "                    Created by @junchrist on Discord" -ForegroundColor Gray
Write-Host ""

Write-Host "SYSTEM SERVICE STATUS" -ForegroundColor Cyan
Write-Host ("=" * 40) -ForegroundColor Cyan
Write-Host ""

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
                Write-Host ("{0,-10} {1,-40} {2,-10} {3}" -f $svc.Name, $svc.Display, "RUNNING", (Get-Date).ToString('HH:mm:ss')) -ForegroundColor Green
            } else {
                Write-Host ("{0,-10} {1,-40} {2,-10} {3}" -f $svc.Name, $svc.Display, $service.Status.ToString().ToUpper(), (Get-Date).ToString('HH:mm:ss')) -ForegroundColor Red
            }
        } else {
            Write-Host ("{0,-10} {1,-40} {2,-10}" -f $svc.Name, $svc.Display, "NOT FOUND") -ForegroundColor Yellow
        }
    } catch {
        Write-Host ("{0,-10} {1,-40} ERROR: {2}" -f $svc.Name, $svc.Display, $_.Exception.Message) -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "REGISTRY SETTINGS" -ForegroundColor Cyan
Write-Host ("-" * 40) -ForegroundColor Cyan
Write-Host ""

try {
    $prefetch = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -ErrorAction SilentlyContinue
    if ($prefetch) {
        switch ($prefetch.EnablePrefetcher) {
            3 { $status = "Enabled (Application and Boot)"; $color = "Green" }
            2 { $status = "Enabled (Boot only)"; $color = "Green" }
            1 { $status = "Enabled (Application only)"; $color = "Green" }
            0 { $status = "Disabled"; $color = "Red" }
            default { $status = "Unknown Value: $($prefetch.EnablePrefetcher)"; $color = "Yellow" }
        }
        Write-Host ("{0,-25} {1}" -f "Prefetch Enabled:", $status) -ForegroundColor $color
    } else {
        Write-Host ("{0,-25} {1}" -f "Prefetch Enabled:", "Not Found") -ForegroundColor Yellow
    }
} catch {
    Write-Host ("{0,-25} {1}" -f "Prefetch Enabled:", "Error accessing registry") -ForegroundColor Red
}

try {
    $sysmainReg = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSysMain" -ErrorAction SilentlyContinue
    if ($sysmainReg) {
        if ($sysmainReg.EnableSysMain -eq 1) {
            Write-Host ("{0,-25} {1}" -f "SysMain Registry:", "Enabled") -ForegroundColor Green
        } else {
            Write-Host ("{0,-25} {1}" -f "SysMain Registry:", "Disabled") -ForegroundColor Red
        }
    } else {
        Write-Host ("{0,-25} {1}" -f "SysMain Registry:", "Not Found (Default: Enabled)") -ForegroundColor Yellow
    }
} catch {
    Write-Host ("{0,-25} {1}" -f "SysMain Registry:", "Error accessing registry") -ForegroundColor Red
}

try {
    $pcaReg = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ProgramCompatibilityAssistant" -Name "Enabled" -ErrorAction SilentlyContinue
    if ($pcaReg) {
        if ($pcaReg.Enabled -eq 1) {
            Write-Host ("{0,-25} {1}" -f "PcaSvc Registry:", "Enabled") -ForegroundColor Green
        } else {
            Write-Host ("{0,-25} {1}" -f "PcaSvc Registry:", "Disabled") -ForegroundColor Red
        }
    } else {
        Write-Host ("{0,-25} {1}" -f "PcaSvc Registry:", "Not Found (Default: Enabled)") -ForegroundColor Yellow
    }
} catch {
    Write-Host ("{0,-25} {1}" -f "PcaSvc Registry:", "Error accessing registry") -ForegroundColor Red
}

try {
    $powershellLogging = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -ErrorAction SilentlyContinue
    if ($powershellLogging) {
        if ($powershellLogging.EnableScriptBlockLogging -eq 1) {
            Write-Host ("{0,-25} {1}" -f "PowerShell Logging:", "Enabled") -ForegroundColor Green
        } else {
            Write-Host ("{0,-25} {1}" -f "PowerShell Logging:", "Disabled") -ForegroundColor Red
        }
    } else {
        Write-Host ("{0,-25} {1}" -f "PowerShell Logging:", "Not Found (Default: Disabled)") -ForegroundColor Yellow
    }
} catch {
    Write-Host ("{0,-25} {1}" -f "PowerShell Logging:", "Error accessing registry") -ForegroundColor Red
}

try {
    $cmd = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableCMD" -ErrorAction SilentlyContinue
    if ($cmd) {
        if ($cmd.DisableCMD -eq 0) {
            Write-Host ("{0,-25} {1}" -f "CMD Available:", "Yes") -ForegroundColor Green
        } else {
            Write-Host ("{0,-25} {1}" -f "CMD Available:", "No") -ForegroundColor Red
        }
    } else {
        Write-Host ("{0,-25} {1}" -f "CMD Available:", "Yes (Default)") -ForegroundColor Green
    }
} catch {
    Write-Host ("{0,-25} {1}" -f "CMD Available:", "Error accessing registry") -ForegroundColor Red
}

try {
    $activitiesCache = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -ErrorAction SilentlyContinue
    if ($activitiesCache) {
        if ($activitiesCache.EnableActivityFeed -eq 1) {
            Write-Host ("{0,-25} {1}" -f "Activities Cache:", "Enabled") -ForegroundColor Green
        } else {
            Write-Host ("{0,-25} {1}" -f "Activities Cache:", "Disabled") -ForegroundColor Red
        }
    } else {
        Write-Host ("{0,-25} {1}" -f "Activities Cache:", "Not Found (Default: Enabled)") -ForegroundColor Yellow
    }
} catch {
    Write-Host ("{0,-25} {1}" -f "Activities Cache:", "Error accessing registry") -ForegroundColor Red
}

Write-Host ""
Write-Host "=" * 40 -ForegroundColor Gray
Write-Host "Check Complete!" -ForegroundColor Green
Read-Host "`nPress Enter to exit"
