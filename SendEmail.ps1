###############################
### DEPLOYMENT EMAIL SYSTEM ###
### By: Nathan Ziehnert     ###
### Version: 1.0            ###
###############################
param(
    [Parameter(Mandatory = $true)]
    [string]$type,
    [string]$to = "", #you can specify a fallback email address here if one isn't specified in the script parameters
    [string]$image
)

### Default Settings ###
$smtpServer = "" #specify your SMTP Server
$smtpFrom = "" #specify your from address

### Local Stuff ###
$dateTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss tt"
$computerName = $env:COMPUTERNAME

function Send-Mail {
    param(
        [string]$body,
        [string]$subject
    )
    
    #create smtp connection
    $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
    
    $message = New-Object Net.Mail.MailMessage
    $message.To.Add($to)
    $message.From = $smtpFrom
    $message.Subject = $subject
    $message.Body = $body
    
    $smtp.Send($message)
}

# USE SPLATTING/HERE-STRING FOR EASY FORMATTING
# NOTE: The "@ to close the here-string must be on the first character of a new line
# SECOND NOTE: Tab prettiness is not your friend - look at the others for examples.
switch($type){
    USMTBackupFail {
        $pbody = @"
USMT failed to backup: $computerName. The Task Sequence is in a failed state waiting for manual intervention.

Please review the log located at c:\Windows\CCM\Logs\scanstate.log for further information.
"@
        $psubject = "SCCM TS ALERT: USMT Backup Failure"
    }
    
    USMTRestoreFail {
        $pbody = @"
USMT failed to restore: $computerName. The Task Sequence will continue, but you will need to manually restore user data.

Please review the procedures for manually restoring user data.
"@
        $psubject = "SCCM TS ALERT: USMT Restore Failure"
    }
    
    DeploymentComplete {
        $pbody = @"
The image deployment process for $computerName completed at $dateTime

This computer was imaged with TS version: $image
"@
        $psubject = "Image Deployment Complete Notification"
    }
}

Send-Mail -body $pbody -subject $psubject
