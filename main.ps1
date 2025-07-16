. ./utility/lib/csm-sh.ps1
. ./utility/policy-gen/generator.ps1

$u = "leader.mvenegas.cybr.andyharrislab.com"
$key = ""

getCSMInfo $u

$authz = (getCSMToken admin $key)

$workloads = (getWorkloads $authz)

foreach ( $workload in $workloads ) {

    

}