$UPN = Read-Host "Enter the UPN"
Connect-ExchangeOnline -UserPrincipalName $UPN

$orgAudit = (Get-OrganizationConfig).AuditDisabled
if (!$orgAudit) {
    Write-Host "Audit is enabled for the organization, setting audit status for mailboxes..."
    Get-Mailbox | Set-Mailbox -AuditEnabled $true
}
else {
    Write-Host "Audit is disabled for the organization, enabling..."
    Set-OrganizationConfig -AuditDisabled $false
    Get-Mailbox | Set-Mailbox -AuditEnabled $true
}

$mailboxes = Get-Mailbox
$auditNotEnabled = $false
foreach ($mailbox in $mailboxes) {
    if (-not $mailbox.AuditEnabled) {
        $auditNotEnabled = $true
        break
    }
}

if ($auditNotEnabled) {
    Write-Host "Audit isn't enabled for all mailboxes, enabling..."
    $mailboxes | Set-Mailbox -AuditEnabled $true
} else {
    Write-Host "Audit is enabled for all mailboxes, exiting..."
    Disconnect-ExchangeOnline -Confirm:$false
}