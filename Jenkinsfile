// This repo does not actually need Jenkins, but this file is here to
// satisfy branch protection rules that require a Jenkins pipefile to run
// successfully on every PR.

pipeline {
  agent { label 'conjur-enterprise-common-agent' }

  options {
    timestamps()
    buildDiscarder(logRotator(daysToKeepStr: '30'))
    timeout(time: 4, unit: 'HOURS')
  }
  stages{
    stage('Success') {
      steps {
        echo 'Success!'
      }
    }
  }
}
