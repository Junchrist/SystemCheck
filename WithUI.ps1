if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $showGUI = $true
}

try {
    $executionPolicy = Get-ExecutionPolicy -Scope Process -ErrorAction SilentlyContinue
    if ($executionPolicy -eq "Bypass" -or $executionPolicy -eq "Unrestricted") {
        $showGUI = $true
    }
} catch {
    $showGUI = $true
}

if ($showGUI) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "[ @sYs ] | SYSTEM CHECKER"
    $form.Size = New-Object System.Drawing.Size(1000, 750)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedSingle"
    $form.MaximizeBox = $false
    $form.BackColor = [System.Drawing.Color]::Black
    
    $headerLabel = New-Object System.Windows.Forms.Label
    $headerLabel.Text = "SYSTEM SERVICE & REGISTRY CHECKER"
    $headerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $headerLabel.ForeColor = [System.Drawing.Color]::White
    $headerLabel.Size = New-Object System.Drawing.Size(950, 40)
    $headerLabel.Location = New-Object System.Drawing.Point(25, 20)
    $headerLabel.TextAlign = "MiddleCenter"
    $form.Controls.Add($headerLabel)
    
    $subLabel = New-Object System.Windows.Forms.Label
    $subLabel.Text = "Created by @junchrist on Discord | Read-only diagnostic mode"
    $subLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $subLabel.ForeColor = [System.Drawing.Color]::Gray
    $subLabel.Size = New-Object System.Drawing.Size(950, 25)
    $subLabel.Location = New-Object System.Drawing.Point(25, 65)
    $subLabel.TextAlign = "MiddleCenter"
    $form.Controls.Add($subLabel)
    
    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Size = New-Object System.Drawing.Size(950, 550)
    $tabControl.Location = New-Object System.Drawing.Point(25, 100)
    $tabControl.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    
    $servicesTab = New-Object System.Windows.Forms.TabPage
    $servicesTab.Text = "Services"
    $servicesTab.BackColor = [System.Drawing.Color]::Black
    $servicesTab.ForeColor = [System.Drawing.Color]::White
    
    $servicesList = New-Object System.Windows.Forms.ListView
    $servicesList.Size = New-Object System.Drawing.Size(920, 480)
    $servicesList.Location = New-Object System.Drawing.Point(10, 10)
    $servicesList.View = "Details"
    $servicesList.FullRowSelect = $true
    $servicesList.GridLines = $true
    $servicesList.Font = New-Object System.Drawing.Font("Consolas", 10)
    $servicesList.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
    $servicesList.ForeColor = [System.Drawing.Color]::White
    $servicesList.OwnerDraw = $true
    
    $servicesList.Add_DrawItem({
        param($sender, $e)
        
        $item = $sender.Items[$e.Index]
        
        if ($e.ItemIndex -eq -1) { return }
        
        if (($e.State -band [System.Windows.Forms.ListViewItemStates]::Selected) -ne 0) {
            $e.Graphics.FillRectangle([System.Drawing.Brushes]::FromArgb(60, 60, 60), $e.Bounds)
        } else {
            $e.Graphics.FillRectangle([System.Drawing.Brushes]::Black, $e.Bounds)
        }
        
        $x = $e.Bounds.Left
        $y = $e.Bounds.Top + 2
        
        $font = $sender.Font
        
        for ($i = 0; $i -lt $item.SubItems.Count; $i++) {
            $subItem = $item.SubItems[$i]
            $width = $sender.Columns[$i].Width
            $rect = New-Object System.Drawing.Rectangle($x, $y, $width, $e.Bounds.Height - 4)
            
            if ($i -eq 0) {
                $brush = [System.Drawing.Brushes]::White
            } else {
                $statusText = $item.SubItems[2].Text
                $brush = [System.Drawing.Brushes]::White
                
                if ($statusText -eq "Running") {
                    $brush = [System.Drawing.Brushes]::White
                } elseif ($statusText -eq "Stopped") {
                    $brush = [System.Drawing.Brushes]::Gray
                } elseif ($statusText -eq "Not Found") {
                    $brush = [System.Drawing.Brushes]::DarkGray
                } else {
                    $brush = [System.Drawing.Brushes]::LightGray
                }
            }
            
            $format = New-Object System.Drawing.StringFormat
            $format.Alignment = "Near"
            $format.LineAlignment = "Center"
            
            $e.Graphics.DrawString($subItem.Text, $font, $brush, $rect, $format)
            
            $x += $width
        }
        
        $e.DrawDefault = $false
    })
    
    $servicesList.Columns.Add("Service Name", 200)
    $servicesList.Columns.Add("Display Name", 350)
    $servicesList.Columns.Add("Status", 150)
    $servicesList.Columns.Add("Details", 200)
    
    $servicesTab.Controls.Add($servicesList)
    $tabControl.Controls.Add($servicesTab)
    
    $registryTab = New-Object System.Windows.Forms.TabPage
    $registryTab.Text = "Registry"
    $registryTab.BackColor = [System.Drawing.Color]::Black
    $registryTab.ForeColor = [System.Drawing.Color]::White
    
    $registryList = New-Object System.Windows.Forms.ListView
    $registryList.Size = New-Object System.Drawing.Size(920, 480)
    $registryList.Location = New-Object System.Drawing.Point(10, 10)
    $registryList.View = "Details"
    $registryList.FullRowSelect = $true
    $registryList.GridLines = $true
    $registryList.Font = New-Object System.Drawing.Font("Consolas", 10)
    $registryList.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
    $registryList.ForeColor = [System.Drawing.Color]::White
    $registryList.OwnerDraw = $true
    
    $registryList.Add_DrawItem({
        param($sender, $e)
        
        $item = $sender.Items[$e.Index]
        
        if ($e.ItemIndex -eq -1) { return }
        
        if (($e.State -band [System.Windows.Forms.ListViewItemStates]::Selected) -ne 0) {
            $e.Graphics.FillRectangle([System.Drawing.Brushes]::FromArgb(60, 60, 60), $e.Bounds)
        } else {
            $e.Graphics.FillRectangle([System.Drawing.Brushes]::Black, $e.Bounds)
        }
        
        $x = $e.Bounds.Left
        $y = $e.Bounds.Top + 2
        
        $font = $sender.Font
        
        for ($i = 0; $i -lt $item.SubItems.Count; $i++) {
            $subItem = $item.SubItems[$i]
            $width = $sender.Columns[$i].Width
            $rect = New-Object System.Drawing.Rectangle($x, $y, $width, $e.Bounds.Height - 4)
            
            if ($i -eq 0) {
                $brush = [System.Drawing.Brushes]::White
            } else {
                $statusText = $item.SubItems[1].Text
                $brush = [System.Drawing.Brushes]::White
                
                if ($statusText -eq "YES") {
                    $brush = [System.Drawing.Brushes]::White
                } elseif ($statusText -eq "NO") {
                    $brush = [System.Drawing.Brushes]::Gray
                } elseif ($statusText -eq "N/A") {
                    $brush = [System.Drawing.Brushes]::DarkGray
                } else {
                    $brush = [System.Drawing.Brushes]::LightGray
                }
            }
            
            $format = New-Object System.Drawing.StringFormat
            $format.Alignment = "Near"
            $format.LineAlignment = "Center"
            
            $e.Graphics.DrawString($subItem.Text, $font, $brush, $rect, $format)
            
            $x += $width
        }
        
        $e.DrawDefault = $false
    })
    
    $registryList.Columns.Add("Setting", 250)
    $registryList.Columns.Add("Status", 150)
    $registryList.Columns.Add("Details", 500)
    
    $registryTab.Controls.Add($registryList)
    $tabControl.Controls.Add($registryTab)
    
    $form.Controls.Add($tabControl)
    
    $statusBar = New-Object System.Windows.Forms.StatusStrip
    $statusBar.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
    $statusBar.ForeColor = [System.Drawing.Color]::White
    
    $statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
    $statusLabel.Text = "Ready"
    $statusLabel.ForeColor = [System.Drawing.Color]::White
    $statusBar.Items.Add($statusLabel)
    
    $form.Controls.Add($statusBar)
    
    function Add-ServiceItem {
        param($name, $display, $status, $details)
        
        $item = New-Object System.Windows.Forms.ListViewItem($name)
        $item.SubItems.Add($display)
        $item.SubItems.Add($status)
        $item.SubItems.Add($details)
        
        switch ($status) {
            "Running" { $item.ForeColor = [System.Drawing.Color]::White }
            "Stopped" { $item.ForeColor = [System.Drawing.Color]::Gray }
            "Not Found" { $item.ForeColor = [System.Drawing.Color]::DarkGray }
            default { $item.ForeColor = [System.Drawing.Color]::LightGray }
        }
        
        $servicesList.Items.Add($item)
    }
    
    function Add-RegistryItem {
        param($setting, $status, $details)
        
        $item = New-Object System.Windows.Forms.ListViewItem($setting)
        $item.SubItems.Add($status)
        $item.SubItems.Add($details)
        
        switch ($status) {
            "YES" { $item.ForeColor = [System.Drawing.Color]::White }
            "NO" { $item.ForeColor = [System.Drawing.Color]::Gray }
            "N/A" { $item.ForeColor = [System.Drawing.Color]::DarkGray }
            default { $item.ForeColor = [System.Drawing.Color]::LightGray }
        }
        
        $registryList.Items.Add($item)
    }
    
    $statusLabel.Text = "Checking services..."
    $form.Refresh()
    
    $serviceList = @(
        @{Name="SysMain"; Display="SysMain"},
        @{Name="PcaSvc"; Display="Program Compatibility Assistant"},
        @{Name="EventLog"; Display="Windows Event Log"},
        @{Name="Appinfo"; Display="Application Information"},
        @{Name="CDPSvc"; Display="Connected Devices Platform"}
    )
    
    foreach ($svc in $serviceList) {
        try {
            $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
            if ($service) {
                if ($service.Status -eq "Running") {
                    Add-ServiceItem $svc.Name $svc.Display "Running" "Active"
                } else {
                    Add-ServiceItem $svc.Name $svc.Display $service.Status.ToString() "Installed but not running"
                }
            } else {
                Add-ServiceItem $svc.Name $svc.Display "Not Found" "Service not installed"
            }
        } catch {
            Add-ServiceItem $svc.Name $svc.Display "Error" "Unable to check"
        }
    }
    
    $statusLabel.Text = "Checking registry..."
    $form.Refresh()
    
    try {
        $prefetchPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
        $prefetch = Get-ItemProperty -Path $prefetchPath -Name "EnablePrefetcher" -ErrorAction SilentlyContinue
        if ($prefetch) {
            switch ($prefetch.EnablePrefetcher) {
                0 { Add-RegistryItem "Prefetch" "NO" "Disabled" }
                1 { Add-RegistryItem "Prefetch" "YES" "Application prefetching" }
                2 { Add-RegistryItem "Prefetch" "YES" "Boot prefetching" }
                3 { Add-RegistryItem "Prefetch" "YES" "Application + boot prefetching" }
                default { Add-RegistryItem "Prefetch" "UNKNOWN" "Unexpected value" }
            }
        } else {
            Add-RegistryItem "Prefetch" "UNKNOWN" "Registry value not configured"
        }
    } catch {
        Add-RegistryItem "Prefetch" "UNKNOWN" "Error accessing registry"
    }
    
    try {
        $sysmain = Get-Service -Name "SysMain" -ErrorAction SilentlyContinue
        if ($sysmain) {
            if ($sysmain.Status -eq "Running") {
                Add-RegistryItem "SysMain" "YES" "Running"
            } elseif ($sysmain.StartType -eq "Disabled") {
                Add-RegistryItem "SysMain" "NO" "Service disabled"
            } else {
                Add-RegistryItem "SysMain" "NO" "Installed but stopped"
            }
        } else {
            Add-RegistryItem "SysMain" "N/A" "Service not installed"
        }
    } catch {
        Add-RegistryItem "SysMain" "UNKNOWN" "Error checking service"
    }
    
    try {
        $loggingPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
        $logging = Get-ItemProperty -Path $loggingPath -Name "EnableScriptBlockLogging" -ErrorAction SilentlyContinue
        if ($logging) {
            if ($logging.EnableScriptBlockLogging -eq 1) {
                Add-RegistryItem "PowerShell Logging" "YES" "Script Block Logging enabled"
            } else {
                Add-RegistryItem "PowerShell Logging" "NO" "Script Block Logging disabled"
            }
        } else {
            Add-RegistryItem "PowerShell Logging" "UNKNOWN" "Policy not configured"
        }
    } catch {
        Add-RegistryItem "PowerShell Logging" "UNKNOWN" "Error accessing registry"
    }
    
    try {
        $cmdPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
        $cmd = Get-ItemProperty -Path $cmdPath -Name "DisableCMD" -ErrorAction SilentlyContinue
        if ($cmd) {
            switch ($cmd.DisableCMD) {
                0 { Add-RegistryItem "CMD Policy" "YES" "CMD is allowed" }
                1 { Add-RegistryItem "CMD Policy" "NO" "CMD disabled by policy" }
                2 { Add-RegistryItem "CMD Policy" "NO" "CMD disabled; batch files restricted" }
                default { Add-RegistryItem "CMD Policy" "UNKNOWN" "Unexpected value" }
            }
        } else {
            Add-RegistryItem "CMD Policy" "UNKNOWN" "No explicit policy configured"
        }
    } catch {
        Add-RegistryItem "CMD Policy" "UNKNOWN" "Error accessing registry"
    }
    
    try {
        $activity = Get-ItemProperty -Path $cmdPath -Name "EnableActivityFeed" -ErrorAction SilentlyContinue
        $publish = Get-ItemProperty -Path $cmdPath -Name "PublishUserActivities" -ErrorAction SilentlyContinue
        $upload = Get-ItemProperty -Path $cmdPath -Name "UploadUserActivities" -ErrorAction SilentlyContinue
        
        if ($activity -and $activity.EnableActivityFeed -eq 0) {
            Add-RegistryItem "Activity History" "NO" "Activity Feed disabled by policy"
        } elseif ($publish -and $publish.PublishUserActivities -eq 0) {
            Add-RegistryItem "Activity History" "NO" "Publishing user activities disabled"
        } elseif ($upload -and $upload.UploadUserActivities -eq 0) {
            Add-RegistryItem "Activity History" "NO" "Uploading user activities disabled"
        } elseif (($activity -and $activity.EnableActivityFeed -eq 1) -or
                  ($publish -and $publish.PublishUserActivities -eq 1) -or
                  ($upload -and $upload.UploadUserActivities -eq 1)) {
            Add-RegistryItem "Activity History" "YES" "Activity policy allows feature"
        } else {
            Add-RegistryItem "Activity History" "UNKNOWN" "No explicit policy configured"
        }
    } catch {
        Add-RegistryItem "Activity History" "UNKNOWN" "Error accessing registry"
    }
    
    $statusLabel.Text = "Check Complete!"
    $form.Refresh()
    
    $form.ShowDialog() | Out-Null
    exit
}

Clear-Host

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
"@ -ForegroundColor White

Write-Host ""
Write-Host "                    SYSTEM SERVICE & REGISTRY CHECKER" -ForegroundColor White
Write-Host "                    Created by @junchrist on Discord" -ForegroundColor Gray
Write-Host ""

Write-Host "SERVICE STATUS" -ForegroundColor White
Write-Host ("-" * 50) -ForegroundColor Gray

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
                Write-Host ("  {0,-10} {1,-40} {2,-10}" -f $svc.Name, $svc.Display, "RUNNING") -ForegroundColor White
            } else {
                Write-Host ("  {0,-10} {1,-40} {2,-10}" -f $svc.Name, $svc.Display, $service.Status.ToString().ToUpper()) -ForegroundColor Gray
            }
        } else {
            Write-Host ("  {0,-10} {1,-40} {2,-10}" -f $svc.Name, $svc.Display, "NOT FOUND") -ForegroundColor DarkGray
        }
    } catch {
        Write-Host ("  {0,-10} {1,-40} ERROR" -f $svc.Name, $svc.Display) -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "REGISTRY SETTINGS" -ForegroundColor White
Write-Host ("-" * 50) -ForegroundColor Gray

try {
    $prefetch = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -ErrorAction SilentlyContinue
    if ($prefetch) {
        switch ($prefetch.EnablePrefetcher) {
            3 { $status = "Enabled (App and Boot)"; $color = "White" }
            2 { $status = "Enabled (Boot only)"; $color = "White" }
            1 { $status = "Enabled (App only)"; $color = "White" }
            0 { $status = "Disabled"; $color = "Gray" }
            default { $status = "Unknown: $($prefetch.EnablePrefetcher)"; $color = "DarkGray" }
        }
        Write-Host ("  {0,-25} {1}" -f "Prefetch:", $status) -ForegroundColor $color
    } else {
        Write-Host ("  {0,-25} {1}" -f "Prefetch:", "Not Found") -ForegroundColor DarkGray
    }
} catch {
    Write-Host ("  {0,-25} {1}" -f "Prefetch:", "Error") -ForegroundColor Gray
}

try {
    $sysmainReg = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSysMain" -ErrorAction SilentlyContinue
    if ($sysmainReg) {
        if ($sysmainReg.EnableSysMain -eq 1) {
            Write-Host ("  {0,-25} {1}" -f "SysMain:", "Enabled") -ForegroundColor White
        } else {
            Write-Host ("  {0,-25} {1}" -f "SysMain:", "Disabled") -ForegroundColor Gray
        }
    } else {
        Write-Host ("  {0,-25} {1}" -f "SysMain:", "Not Found (Default: Enabled)") -ForegroundColor DarkGray
    }
} catch {
    Write-Host ("  {0,-25} {1}" -f "SysMain:", "Error") -ForegroundColor Gray
}

try {
    $pcaReg = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ProgramCompatibilityAssistant" -Name "Enabled" -ErrorAction SilentlyContinue
    if ($pcaReg) {
        if ($pcaReg.Enabled -eq 1) {
            Write-Host ("  {0,-25} {1}" -f "PcaSvc:", "Enabled") -ForegroundColor White
        } else {
            Write-Host ("  {0,-25} {1}" -f "PcaSvc:", "Disabled") -ForegroundColor Gray
        }
    } else {
        Write-Host ("  {0,-25} {1}" -f "PcaSvc:", "Not Found (Default: Enabled)") -ForegroundColor DarkGray
    }
} catch {
    Write-Host ("  {0,-25} {1}" -f "PcaSvc:", "Error") -ForegroundColor Gray
}

try {
    $powershellLogging = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -ErrorAction SilentlyContinue
    if ($powershellLogging) {
        if ($powershellLogging.EnableScriptBlockLogging -eq 1) {
            Write-Host ("  {0,-25} {1}" -f "PowerShell Logging:", "Enabled") -ForegroundColor White
        } else {
            Write-Host ("  {0,-25} {1}" -f "PowerShell Logging:", "Disabled") -ForegroundColor Gray
        }
    } else {
        Write-Host ("  {0,-25} {1}" -f "PowerShell Logging:", "Not Found (Default: Disabled)") -ForegroundColor DarkGray
    }
} catch {
    Write-Host ("  {0,-25} {1}" -f "PowerShell Logging:", "Error") -ForegroundColor Gray
}

try {
    $cmd = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableCMD" -ErrorAction SilentlyContinue
    if ($cmd) {
        if ($cmd.DisableCMD -eq 0) {
            Write-Host ("  {0,-25} {1}" -f "CMD Available:", "Yes") -ForegroundColor White
        } else {
            Write-Host ("  {0,-25} {1}" -f "CMD Available:", "No") -ForegroundColor Gray
        }
    } else {
        Write-Host ("  {0,-25} {1}" -f "CMD Available:", "Yes (Default)") -ForegroundColor White
    }
} catch {
    Write-Host ("  {0,-25} {1}" -f "CMD Available:", "Error") -ForegroundColor Gray
}

try {
    $activitiesCache = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -ErrorAction SilentlyContinue
    if ($activitiesCache) {
        if ($activitiesCache.EnableActivityFeed -eq 1) {
            Write-Host ("  {0,-25} {1}" -f "Activities Cache:", "Enabled") -ForegroundColor White
        } else {
            Write-Host ("  {0,-25} {1}" -f "Activities Cache:", "Disabled") -ForegroundColor Gray
        }
    } else {
        Write-Host ("  {0,-25} {1}" -f "Activities Cache:", "Not Found (Default: Enabled)") -ForegroundColor DarkGray
    }
} catch {
    Write-Host ("  {0,-25} {1}" -f "Activities Cache:", "Error") -ForegroundColor Gray
}

Write-Host ""
Write-Host ("-" * 50) -ForegroundColor Gray
Write-Host "Check Complete!" -ForegroundColor White

Write-Host ""
Write-Host "Options:" -ForegroundColor White
Write-Host "  [1] Run again" -ForegroundColor White
Write-Host "  [2] Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1 or 2)"

if ($choice -eq "1") {
    Clear-Host
    & $MyInvocation.MyCommand.Path
} else {
    Write-Host "Exiting..." -ForegroundColor Gray
    exit
}
