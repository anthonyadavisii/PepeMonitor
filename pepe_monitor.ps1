<#

__________████████_____██████
_________█░░░░░░░░██_██░░░░░░█
________█░░░░░░░░░░░█░░░░░░░░░█
_______█░░░░░░░███░░░█░░░░░░░░░█
_______█░░░░███░░░███░█░░░████░█
______█░░░██░░░░░░░░███░██░░░░██
_____█░░░░░░░░░░░░░░░░░█░░░░░░░░███
____█░░░░░░░░░░░░░██████░░░░░████░░█
____█░░░░░░░░░█████░░░████░░██░░██░░█
___██░░░░░░░███░░░░░░░░░░█░░░░░░░░███
__█░░░░░░░░░░░░░░█████████░░█████████
_█░░░░░░░░░░█████_████___████_█████___█
_█░░░░░░░░░░█______█_███__█_____███_█___█
█░░░░░░░░░░░░█___████_████____██_██████
░░░░░░░░░░░░░█████████░░░████████░░░█
░░░░░░░░░░░░░░░░█░░░░░█░░░░░░░░░░░░█
░░░░░░░░░░░░░░░░░░░░██░░░░█░░░░░░██
░░░░░░░░░░░░░░░░░░██░░░░░░░███████
░░░░░░░░░░░░░░░░██░░░░░░░░░░█░░░░░█
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
░░░░░░░░░░░█████████░░░░░░░░░░░░░░██
░░░░░░░░░░█▒▒▒▒▒▒▒▒███████████████▒▒█
░░░░░░░░░█▒▒███████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█
░░░░░░░░░█▒▒▒▒▒▒▒▒▒█████████████████
░░░░░░░░░░████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒█
░░░░░░░░░░░░░░░░░░██████████████████
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
██░░░░░░░░░░░░░░░░░░░░░░░░░░░██
▓██░░░░░░░░░░░░░░░░░░░░░░░░██
▓▓▓███░░░░░░░░░░░░░░░░░░░░█
▓▓▓▓▓▓███░░░░░░░░░░░░░░░██
▓▓▓▓▓▓▓▓▓███████████████▓▓█
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█

Name: PepeCoin Monitor
Author:  Anthony "Alex" Davis II
Email:   v7davisa@gmail.com
Website: https://github.com/anthonyadavisii
Purpose: To monitor PepeCoin / Memetic wallet debug.log and send smtp alerts for ERROR entries allowing 3 hours remediation period before additional alerts.
Date: 15th Feb 2019
Version: 1.0
#>

<#
.Synopsis
   Script to send email using Powershell via SendGrid account    
.DESCRIPTION
   Script to send email using Powershell via SendGrid account 
 
.NOTES
    Author:  Deepak Vishwakarma (deep)
    Email:   Deepitpro@outlook.com
    Purpose: To send email using PowerShell via SendGrid account (https://sendgrid.com/blog/sendgrid-in-the-cloud-with-microsoft/)
    Date: 26th Aug 2017
    Version: 1.0
    
#>

$Env:SENDGRID = Read-Host "Enter SendGrid API key?"
$recipient = Read-Host "Recipient email?"

function Send-TestEmail{
    [cmdletbinding()]
    Param (
    $To,
    $Cc,
    $body
  
   )

   Process{

        #Provide SendGrid user name, if you are using Microsoft azure you will find the same from the portal   
        $sendgridusername = "apikey"
        #Enter the send grid password Note: this is not recommended for production. In production, the password should be encrypted
        $SecurePassword=ConvertTo-SecureString $Env:SENDGRID –asplaintext –force 
        $cred = New-Object System.Management.Automation.PsCredential($sendgridusername,$SecurePassword)
        $sub="PepeCoin Error"
        $From = "donotreply@donotreply.com"
        Send-MailMessage -From $From -To $To -Subject $sub -Body $body -Priority High -SmtpServer "smtp.sendgrid.net" -Credential $cred -UseSsl -Port 587 -BodyAsHtml
   }
}

$VerbosePreference = "continue"
while($true)
{
# Gets latest debug log entry
$entry = Get-Content  $env:USERPROFILE\AppData\Roaming\PepeCoin\debug.log | select -Last 1
# Checks for ERROR entry which may be indicative of wallet problems
if($entry|Select-String -Pattern 'ERROR')
    {
    Write-Verbose -Message "Error Detected in Log!"
    #Send SMTP alert
    Send-TestEmail -To $recipient -body $entry
    #Sleeps for 3 hours to allow remediation of issue to not exceed Sendgrid free email quota
    Start-Sleep -s 10800
    }

}
