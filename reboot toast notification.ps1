# Register the AppID in the registry for use with the Action Center, if required
$global:ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Creating registry entries if they don't exists
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null 
$RegPath = "HKCR:\rebootnow\"
New-Item -Path "$RegPath" -Force
New-ItemProperty -Path "$RegPath" -Name "(Default)" -Value "URL:Reboot Protocol" -PropertyType "String"
New-ItemProperty -Path "$RegPath" -Name "URL Protocol" -Value "" -PropertyType "String"
New-Item -Path "$RegPath\shell\open\command" -Force
New-ItemProperty -Path "$RegPath\shell\open\command" -Name "(Default)" -Value $global:ScriptPath\rebootnow.bat -PropertyType "String"

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null 
$RegPath = "HKCR:\rebootin15mins\"
New-Item -Path "$RegPath" -Force
New-ItemProperty -Path "$RegPath" -Name "(Default)" -Value "URL:Reboot Protocol" -PropertyType "String"
New-ItemProperty -Path "$RegPath" -Name "URL Protocol" -Value "" -PropertyType "String"
New-Item -Path "$RegPath\shell\open\command" -Force
New-ItemProperty -Path "$RegPath\shell\open\command" -Name "(Default)" -Value $global:ScriptPath\rebootin15.bat -PropertyType "String"

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null 
$RegPath = "HKCR:\rebootin4hours\"
New-Item -Path "$RegPath" -Force
New-ItemProperty -Path "$RegPath" -Name "(Default)" -Value "URL:Reboot Protocol" -PropertyType "String"
New-ItemProperty -Path "$RegPath" -Name "URL Protocol" -Value "" -PropertyType "String"
New-Item -Path "$RegPath\shell\open\command" -Force
New-ItemProperty -Path "$RegPath\shell\open\command" -Name "(Default)" -Value $global:ScriptPath\rebootin4.bat -PropertyType "String"

# Check for required entries in registry for when using Powershell as application for the toast
# Register the AppID in the registry for use with the Action Center, if required
$RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings"
$App =  "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"
    
# Creating registry entries if they don't exists
if (-NOT(Test-Path -Path "$RegPath\$App")) {
    New-Item -Path "$RegPath\$App" -Force
    New-ItemProperty -Path "$RegPath\$App" -Name "ShowInActionCenter" -Value 1 -PropertyType "DWORD"
}
    
# Make sure the app used with the action center is enabled
if ((Get-ItemProperty -Path "$RegPath\$App" -Name "ShowInActionCenter").ShowInActionCenter -ne "1")  {
    New-ItemProperty -Path "$RegPath\$App" -Name "ShowInActionCenter" -Value 1 -PropertyType "DWORD" -Force
}

#Toast Notification (Visual)
[xml]$Toast = @"
<toast scenario="$Scenario">

<visual>
    <binding template="ToastGeneric">
      <text>Windows Updates</text>
      <text>Your computer is out of date. Please reboot to apply security patches</text>
<text placement="attribution">TOFS IT Team </text>

    </binding>
  </visual>

  <actions>

        <action arguments = "rebootnow:"
                content = 'Reboot Now'
                activationType="protocol"
                 />
                
        <action arguments = 'rebootin15mins:'
                content = 'In 15 Mins'
                activationType="protocol"
                 />

        <action arguments = 'rebootin4hours:'
                content = 'In 4 Hours'
                activationType="protocol"
                 />
    </actions>
</toast>
"@

$Load = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
$Load = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]

# Load the notification into the required format
$ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
$ToastXml.LoadXml($Toast.OuterXml)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($App).Show($ToastXml)
break