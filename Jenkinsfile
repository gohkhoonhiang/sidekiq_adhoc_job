@Library('devops-library')

def slack_channel = "#loyalty-notifications"
def env_name = "test"
def ruby_bundler_versions = [
  ['2.7.8', '2.4.22'],
  ['3.1.5', '2.5.10']
]

pipeline {
  agent any
  options {
    buildDiscarder(logRotator(daysToKeepStr: '60', artifactNumToKeepStr: '20'))
  }
  environment {
    SLACK_TOKEN = credentials("PB_SLACK_TOKEN")
  }
  stages{
    stage("Ensure unique build") {
      steps {
        script {
          // Cancel any already running build for the same branch
          def buildNumber = env.BUILD_NUMBER as int
          if (buildNumber > 1) milestone(buildNumber - 1)
          milestone(buildNumber)
        }
      }
    }
    stage("Test") {
      environment {
        BUNDLE_PATH       = "/build/vendor/bundle"
        REDIS_URL         = "redis://redis-${env.BUILD_NUMBER}:6379/1"
      }
      steps {
        script {
          ruby_bundler_versions.each { versions ->
            def ruby_version = versions[0]
            def bundler_version = versions[1]
            docker.image('redis').withRun() { c_redis ->
              docker.image("ruby:${ruby_version}-alpine")
                .inside("-u root --link ${c_redis.id}:redis-${env.BUILD_NUMBER} -v bundle_cache_gem_tests:${env.BUNDLE_PATH} -v logs_gem_tests:${env.WORKSPACE}/log") {
                  stage("Prepare test env (ruby ${ruby_version})") {
                    sh "apk --update --no-cache add build-base git libsodium-dev --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing"
                    sh "apk --update add dockerize --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing --allow-untrusted"
                    sh "gem install bundler:${bundler_version}"
                    sh 'bundle install --jobs=4 --retry=3'
                    sh "dockerize -wait tcp://redis-${env.BUILD_NUMBER}:6379 -timeout 1m"
                  }
                  stage("Run rspec (ruby ${ruby_version})") {
                    sh 'bundle exec rspec --format progress --format RspecJunitFormatter --out rspec.xml'
                  }
                } // end inside
            } // end docker redis
          } // end ruby_bundler_versions.each
        } // end script
      } // end steps
    } // end of test stage
  } // end of stages
  post {
    cleanup {
      pipelineCleanup()
    }
    always {
      postPipeline(slack_channel, env_name)
    }
  }
}
