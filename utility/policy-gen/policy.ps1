. ./utility/lib/csm-sh.ps1

function Gen-Policy ( $policy ) {

    $t = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }

    $poid = $policy.id
    $whitespace     = ""

    $policyEntityID = parseEntity -e $poid -s ":"
    $clean_poid = $policyEntityID[2] | ForEach-Object { $_ -replace "/", "."}

    $poid_anno = $policy.annotations
    $poid_name = $policyEntityID[2]

    # Capture owning policy member
    $poid_base = $policy.policy

    # Create clean base to trim resource loaded into a specific path
    # this is used in authenticators, i.e. github:
    # conjur_account:host:github-branch/repository_claim
    if ( $poid_name -eq "root" ) 
    {
        log -message "Root Parent Policy Found, skipping."
        break
    }
    else 
    {
        
        $poid_base_clean = parseEntity -e $poid_base -s ":"
        $poid_base_id = $poid_base_clean[2]

        log -message "$poid_base_clean"

        # Clean resource name up for use
        # remove the path it was loaded into
        # trim `/` from prefix if loaded
        # if loaded into root without, throw these values away
        $poid_name_clean = $poid_name.TrimStart($poid_base_id)
        $poid_name_clean = $poid_name_clean.TrimStart('/')
        $po_path   = parseEntity -e $poid_name -s "/"

        $poid_id   = $po_path[-1]
        $po_api    = $poid_name -Replace "(\/([a-zA-Z0-9_-]+))$"
        
    }

    ####

    $thisResourceFile = "tmp/policies/$clean_poid/00_$t.$clean_poid.declare.yml"
    $thisPolicyHistoryFile = "tmp/policies/$clean_poid/policy_versions.json"

    $resourceFileTemp = New-Item -ItemType "File" -Force $thisResourceFile
    $historyFileTemp = New-Item -ItemType "File" -Force $thisPolicyHistoryFile

    log -message "Retaining history for [$poid_name]"
    $clean_history = $policy.policy_versions | ConvertTo-Json
    Add-Content $historyFileTemp -Value $clean_history
    
    log -message "Generating policy for [$poid_name] type [policy]"

    Add-Content $resourceFileTemp -Value "# Loaded into $po_api via REST"
    Add-Content $resourceFileTemp -Value "# CLI Example load - conjur policy load -b $po_api -f $thisResourceFile"
    
    Add-Content $resourceFileTemp -Value "- !policy"
    Add-Content $resourceFileTemp -Value "  id: $poid_id"
    Add-Content $resourceFileTemp -Value "  annotations:"
    Add-Content $resourceFileTemp -Value "    Generated: $t"
    $poid_anno.ForEach({
        $annotationKey = $_.name
        $annotationValue = $_.value
        Add-Content $resourceFileTemp -Value "    ${annotationKey}: $annotationValue"
    }) 
    
}