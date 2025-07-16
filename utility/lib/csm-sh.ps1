function Get-Spacing($functionName){

    try  {

        $spacing = 15 - $functionName.length
        " " * $spacing

    } catch {

        "    "
    }

}

function log(){
    param(
        $message,
        $functionName = $true
    )

    if ($functionName){

        $functionName = (Get-PSCallStack)[1].Command
        $spacing = Get-Spacing $functionName
        $message = "$functionName()$($spacing): $message"
    }

    Write-Host $message
    #Write-Host "-LogName "Application" -Source "CyberArk Secrets Manager - Self Hosted Migration Service" -EventID 43868 -EntryType Information -Message $message"

}

function parseEntity( $e, $s ){

    log -message "Parsing [$e]"

    $option = [System.StringSplitOptions]::RemoveEmptyEntries

    $returnEntity = $e.split($s, $option)

    return $returnEntity

}

function getCSMToken( $h, $k ){

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

    $headers.Add("Accept-Encoding", "base64")
    $headers.Add("Content-Type", "text/plain")

    $cLogon = "host/" + $h

    $encodedLogin = $h#[System.Web.HttpUtility]::UrlEncode($cLogon)

    $authHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

    try {

        $authn_response = Invoke-RestMethod -UseBasicParsing -Headers $headers -Uri "https://$CONJUR_URL/authn/$CONJUR_ACCOUNT/$encodedLogin/authenticate" -Method POST -Body $k -SkipCertificateCheck -ErrorAction SilentlyContinue

        $authHeaders.Add("Authorization", "Token token=`"$authn_response`"")
        $authHeaders.Add("Content-Type", "text/plain")
        
        return $authHeaders

    } catch {

        echo $_

    }


}

function getCSMInfo ( $uri ) { 

    $c_uri = "https://$uri/info"

    #$CONJUR_ACCOUNT = Invoke-RestMethod -UseBasicParsing -Uri "$c_uri"  -Method GET -SkipCertificateCheck
    
    Set-Variable -Name "CONJUR_INFO" -Value ( Invoke-RestMethod -UseBasicParsing -Uri "$c_uri" -Method GET -SkipCertificateCheck) -Scope Global
    Set-Variable -Name "CONJUR_ACCOUNT" -Value $CONJUR_INFO.configuration.conjur.account -Scope Global
    Set-Variable -Name "CONJUR_VERSION" -Value $CONJUR_INFO.release -Scope Global
    Set-Variable -Name "CONJUR_HOSTS" -Value $CONJUR_INFO.configuration.conjur.master_altnames -Scope Global
    Set-Variable -Name "CONJUR_LEADER" -Value $CONJUR_INFO.configuration.conjur.hostname -Scope Global
    Set-Variable -Name "CONJUR_URL" -Value "$uri" -Scope Global


}

function getWorkloads ( $authz ) {

    $queryParams = @{
        kind = "host"
        #search = "delegation/consumers"
    }

    try {

        $workloads = Invoke-RestMethod -Uri "https://$CONJUR_URL/resources/$CONJUR_ACCOUNT" -Body $queryParams -Method GET -Headers $authz -SkipCertificateCheck -ErrorAction SilentlyContinue

        $cnt = $workloads.length
        log -message "Workload Count: $cnt"

        return $workloads

    } catch {

        log $_

    }

}

function getPolicies ( $authz ) {

    $queryParams = @{
        kind = "policy"
        #search = "delegation/consumers"
    }

    try {

        $policies = Invoke-RestMethod -Uri "https://$CONJUR_URL/resources/$CONJUR_ACCOUNT" -Body $queryParams -Method GET -Headers $authz -SkipCertificateCheck -ErrorAction SilentlyContinue

        $cnt = $policies.length
        log -message "Policy Count: $cnt"

        return $policies

    } catch {

        log $_

    }

}

function getWorkloadMetadata ( $workload, $authz ) {

    try {

        $metadata = Invoke-RestMethod -Uri "https://$CONJUR_URL/resources/$CONJUR_ACCOUNT/host/$workload" -Body $queryParams -Method GET -Headers $authz -SkipCertificateCheck -ErrorAction SilentlyContinue

        log $metadata

        return $metadata

    } catch {

        log $_

    }

}