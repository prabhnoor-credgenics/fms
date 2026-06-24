pipeline {

    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    stages {

        stage('Checkout') {
            steps {
                git(
                    url: 'https://github.com/credgenics/cg-api-automation.git',
                    branch: 'main'
                )
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Execute Tests') {
            steps {
                sh '''
                mvn clean test
                '''
            }
        }

        stage('Publish Report') {
            steps {

                publishHTML([
                    reportDir: 'target/cucumber-reports',
                    reportFiles: 'overview-features.html',
                    reportName: 'Automation Report'
                ])

            }
        }

    }

    post {

        always {

            junit(
                testResults:
                'target/surefire-reports/*.xml'
            )

            archiveArtifacts(
                artifacts: 'target/**/*'
            )
        }

    }

}