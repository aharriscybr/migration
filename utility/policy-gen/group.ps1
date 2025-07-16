. ./utility/lib/csm-sh.ps1

function Gen-Policy ( $group ) {

    $t = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }

    $grid = $group.id
    $whitespace     = ""

    $groupEntityID = parseEntity -e $grid -s ":"
    $clean_grid = $groupEntityID[2] | ForEach-Object { $_ -replace "/", "."}

    $grid_anno = $group.annotations
    $grid_name = $groupEntityID[2]

    ####

    $thisResourceFile = "tmp/policies/$clean_grid/00_$t.$clean_grid.declare.yml"

    $resourceFileTemp = New-Item -ItemType "File" -Force $thisResourceFile
    
    log -message "Generating policy for [$poid_name] type [group]"
    Add-Content $resourceFileTemp -Value "- !host"
    Add-Content $resourceFileTemp -Value "  id: $grid_name"
    Add-Content $resourceFileTemp -Value "  annotations:"
    Add-Content $resourceFileTemp -Value "    Generated: $t"
    $grid_anno.ForEach({
        $annotationKey = $_.name
        $annotationValue = $_.value
        Add-Content $resourceFileTemp -Value "    ${annotationKey}: $annotationValue"
    })
    
}