. ./utility/lib/csm-sh.ps1

function Gen-Workload ( $workload ) {

    $t = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }

    $wid = $workload.id
    $whitespace     = ""

    $workloadEntityID = parseEntity -e $wid -s ":"
    $clean_wid = $workloadEntityID[2] | ForEach-Object { $_ -replace "/", "."}

    $wid_anno = $workload.annotations
    $wid_name = $workloadEntityID[2]

    ####

    $thisResourceFile = "tmp/workloads/$t.$clean_wid.declare.yml"
    $resourceFileTemp = New-Item -ItemType "File" -Force $thisResourceFile
    log -message $thisResourceFile
    
    Add-Content $resourceFileTemp -Value "- !host"
    Add-Content $resourceFileTemp -Value "  id: $wid_name"
    Add-Content $resourceFileTemp -Value "  annotations:"
    Add-Content $resourceFileTemp -Value "    Generated: $t"
    $wid_anno.ForEach({
        $annotationKey = $_.name
        $annotationValue = $_.value
        Add-Content $resourceFileTemp -Value "    ${annotationKey}: $annotationValue"
    })

    # Add-Content $resourceFileTemp -Value $whitespace
    # Add-Content $resourceFileTemp -Value "- !grant"
    # Add-Content $resourceFileTemp -Value "  role: !group authenticators"
    # Add-Content $resourceFileTemp -Value "  member: !host $wid_name"
    
}