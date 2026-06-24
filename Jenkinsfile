pipeline {

    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    stages {

    stage('Checkout') {
            steps {
                checkout scm
            }
        }



            stage('Prepare Secrets') {

                steps {

                    withCredentials([
                        file(
                            credentialsId: 'crypto-properties',
                            variable: 'CRYPTO_FILE'
                        )
                    ]) {

                        sh '''
                        mkdir -p src/main/resources/secrets

                        cp "$CRYPTO_FILE" \
                        src/main/resources/secrets/crypto.properties

                        echo "crypto.properties copied"
                        '''

                    }

                }

            }

        stage('Verify Secret Keys') {
            steps {

                sh '''
                grep "stag_public_key" \
                src/main/resources/secrets/crypto.properties \
                && echo "STAG KEY FOUND"
                '''

            }
        }

        stage('Execute Tests') {
            steps {
                sh 'mvn clean test'
            }
        }

    }

    post {

        always {

            junit(
                allowEmptyResults: true,
                testResults: 'target/surefire-reports/*.xml'
            )

            publishHTML(target: [
                reportDir: 'TestReports',
                reportFiles: '**/SparkReport/Spark.html',
                reportName: 'Extent Spark Report',
                keepAll: true,
                alwaysLinkToLastBuild: true,
                allowMissing: true
            ])

            publishHTML(target: [
                reportDir: 'TestReports',
                reportFiles: '**/HtmlReport/ExtentReport.html',
                reportName: 'Extent HTML Report',
                keepAll: true,
                alwaysLinkToLastBuild: true,
                allowMissing: true
            ])
        }

    }

}