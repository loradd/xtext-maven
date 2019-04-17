pipeline {
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr:'15'))
  }

  tools { 
    maven 'M3'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        dir('build') { deleteDir() }
        dir('.m2/repository/org/eclipse/xtext') { deleteDir() }
        dir('.m2/repository/org/eclipse/xtend') { deleteDir() }
      }
    }

    stage('Maven Build') {
      steps {
        sh './1-maven-build.sh'
      }
    }
  }

  post {
    success {
      archiveArtifacts artifacts: 'build/**'
    }
    changed {
      script {
        def envName = ''
        if (env.JENKINS_URL.contains('ci.eclipse.org/xtext')) {
          envName = ' (JIPP)'
        } else if (env.JENKINS_URL.contains('jenkins.eclipse.org/xtext')) {
          envName = ' (CBI)'
        } else if (env.JENKINS_URL.contains('typefox.io')) {
          envName = ' (TF)'
        }
        
        def curResult = currentBuild.currentResult
        def color = '#00FF00'
        if (curResult == 'SUCCESS' && currentBuild.previousBuild != null) {
          curResult = 'FIXED'
        } else if (curResult == 'UNSTABLE') {
          color = '#FFFF00'
        } else if (curResult == 'FAILURE') {
          color = '#FF0000'
        }
        
        slackSend message: "${curResult}: <${env.BUILD_URL}|${env.JOB_NAME}#${env.BUILD_NUMBER}${envName}>", botUser: true, channel: 'xtext-builds', color: "${color}"
      }
    }
  }
}


node {
	properties([
		[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '15']]
	])
	
	stage('Checkout') {
		checkout scm
		
		dir('build') { deleteDir() }
		dir('.m2/repository/org/eclipse/xtext') { deleteDir() }
		dir('.m2/repository/org/eclipse/xtend') { deleteDir() }
	}
	
	stage('Maven Build') {
		def workspace = pwd()
		def mvnHome = tool 'M3'
		env.M2_HOME = "${mvnHome}"
		sh "${mvnHome}/bin/mvn --batch-mode --update-snapshots -fae -PuseJenkinsSnapshots -DJENKINS_URL=$JENKINS_URL -Dmaven.test.failure.ignore=true -Dmaven.repo.local=${workspace}/.m2/repository -f org.eclipse.xtext.maven.parent/pom.xml -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn clean deploy"
		step([$class: 'JUnitResultArchiver', testResults: '**/target/surefire-reports/*.xml'])
	}
	
	archive 'build/**'
}
