. ./utility/lib/csm-sh.ps1
. ./utility/policy-gen/generator.ps1

$u = "leader.mvenegas.cybr.andyharrislab.com"
$key = "14b7kxd2xmgcbdccsq0e26p9yb2190xk2b2q9cv4z3ptw899255mtpa"

getCSMInfo $u

$authz = (getCSMToken admin $key)

$workloads = (getWorkloads -authz $authz)

$workload_count = $workloads.length

log -message "Generating policy for $workload_count workloads"

foreach ( $workload in $workloads ) {

    Gen-Workload $workload

}