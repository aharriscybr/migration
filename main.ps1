. ./utility/lib/csm-sh.ps1
. ./utility/policy-gen/generator.ps1

$u = ""
$key = ""

getCSMInfo $u

$authz = (getCSMToken admin $key)

$workloads = (getWorkloads -authz $authz)

$workload_count = $workloads.length

log -message "Generating policy for $workload_count workloads"

foreach ( $workload in $workloads ) {

    Gen-Workload $workload

}