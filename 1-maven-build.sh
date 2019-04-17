#!/usr/bin/env bash
if [ -z "$JENKINS_URL" ]; then
  # if not set in environment use default
  JENKINS_URL=https://ci.eclipse.org/xtext/
fi

mvn \
  -f org.eclipse.xtext.maven.parent/pom.xml \
  --batch-mode \
  --update-snapshots \
  -fae \
  -Dmaven.repo.local=.m2/repository \
  -Dmaven.test.failure.ignore=true  \
  -DJENKINS_URL=$JENKINS_URL \
  -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn \
  -PuseJenkinsSnapshots
  $@
