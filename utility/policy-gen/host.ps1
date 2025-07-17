. ./utility/lib/csm-sh.ps1

function Gen-Workload ( $workload ) {

    $t = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }

    $wid = $workload.id
    $whitespace     = ""

    # create array of object, parsing out colon separated objects, convert to array
    $workloadEntityID = parseEntity -e $wid -s ":"


    $clean_wid = $workloadEntityID[2] | ForEach-Object { $_ -replace "/", "."}

    # Capture workload annotations
    $wid_anno = $workload.annotations

    # last index of this array is the path/to/workload/id
    # first index is conjur_account
    # second index is type of resource
    # conjur_account:kind:path/to/workload/id
    # conjur_account kind path/to/workload/id
    $wid_name = $workloadEntityID[2]

    # Capture owning policy member
    $wid_base = $workload.policy

    # Create clean base to trim workloads loaded into a specific path
    # this is used in authenticators, i.e. github:
    # conjur_account:host:github-branch/repository_claim
    $wid_base_clean = parseEntity -e $wid_base -s ":"
    $wid_base_id = $wid_base_clean[2]

    # Clean workload name up for use
    # remove the policy it was loaded into
    # trim `/` from prefix if loaded
    # if loaded into root without, throw these values away
    $wid_name_clean = $wid_name.TrimStart($wid_base_id)
    $wid_name_clean = $wid_name_clean.TrimStart('/')

    ####

    $thisResourceFile = "tmp/workloads/01_$t.$clean_wid.declare.yml"
    $resourceFileTemp = New-Item -ItemType "File" -Force $thisResourceFile
    
    log -message "Generating policy for [$wid] type [workload]"
    
    Add-Content $resourceFileTemp -Value "# Loaded into $wid_base_id via REST"
    Add-Content $resourceFileTemp -Value "# CLI Example load - conjur policy load -b $wid_base_id -f $thisResourceFile"

    Add-Content $resourceFileTemp -Value "- !host"

    # Check if in root (data) branch, if so give default name, not clean.
    if ( $wid_base_id -eq "root" )
    {
        # If loaded into root
        Add-Content $resourceFileTemp -Value "  id: $wid_name"
    }
    else
    {
        # handle from parsed variable above
        Add-Content $resourceFileTemp -Value "  id: $wid_name_clean"
    }

    Add-Content $resourceFileTemp -Value "  annotations:"
    Add-Content $resourceFileTemp -Value "    Generated: $t"
    $wid_anno.ForEach({
        $annotationKey = $_.name
        $annotationValue = $_.value
        Add-Content $resourceFileTemp -Value "    ${annotationKey}: $annotationValue"
    })
    
}