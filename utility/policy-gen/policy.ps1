. ./utility/lib/csm-sh.ps1

function Gen-Policy ( $policy ) {

    $t = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }

    $poid = $policy.id
    $whitespace     = ""

    $policyEntityID = parseEntity -e $poid -s ":"
    $clean_poid = $policyEntityID[2] | ForEach-Object { $_ -replace "/", "."}

    $poid_anno = $policy.annotations
    $poid_name = $policyEntityID[2]

    ####

    $thisResourceFile = "tmp/policies/$clean_poid/00_$t.$clean_poid.declare.yml"
    $thisPolicyHistoryFile = "tmp/policies/$clean_poid/policy_versions.json"

    $resourceFileTemp = New-Item -ItemType "File" -Force $thisResourceFile
    $historyFileTemp = New-Item -ItemType "File" -Force $thisPolicyHistoryFile
    
    Add-Content $resourceFileTemp -Value "- !host"
    Add-Content $resourceFileTemp -Value "  id: $poid_name"
    Add-Content $resourceFileTemp -Value "  annotations:"
    Add-Content $resourceFileTemp -Value "    Generated: $t"
    $poid_anno.ForEach({
        $annotationKey = $_.name
        $annotationValue = $_.value
        Add-Content $resourceFileTemp -Value "    ${annotationKey}: $annotationValue"
    })

    $clean_history = $policy.policy_versions | ConvertTo-Json
    Add-Content $historyFileTemp -Value $clean_history
    
}