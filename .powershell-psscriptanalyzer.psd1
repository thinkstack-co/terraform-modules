# File:    .powershell-psscriptanalyzer.psd1
# Purpose: Project-level PSScriptAnalyzer configuration consumed by super-linter
#          (POWERSHELL linter). Tunes which rules apply to PowerShell files
#          in this repo.
# Why:     The PowerShell scripts here are interactive setup/install helpers
#          (AppGate seeding, Intune deployment). Write-Host is the correct
#          choice for that context — it gives the operator visible progress
#          feedback. PSAvoidUsingWriteHost would force a switch to
#          Write-Information, which only renders when $InformationPreference
#          is 'Continue', changing the operator UX.
@{
    # Severity = Information rules excluded; these are stylistic notices, not
    # correctness issues. Trailing whitespace is also flagged by other tools
    # (editor configs, prettier on adjacent files); leaving it to those.
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',
        'PSAvoidTrailingWhitespace',
        'PSUseDeclaredVarsMoreThanAssignments'
    )
}
