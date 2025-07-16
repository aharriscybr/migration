

function workload_gen ( $workload ) {

    $workloadDeclare    = "- !workload"
    $workloadId         = "  id: $thisworkload"
    $annoLine       = "  annotations:"
    $whitespace     = ""
    $grantDeclare   = "- !grant"
    $grantRole      = "  role: !group authenticators"
    $grantMember    = "  member: !workload $thisworkload"
    
}