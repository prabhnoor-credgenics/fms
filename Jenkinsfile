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



            stage('Create Secrets File') {

                steps {

                    withCredentials([
                        string(
                            credentialsId: 'crypto-properties',
                            variable: 'CRYPTO_CONTENT'
                        )
                    ]) {

                        sh '''
                        mkdir -p src/main/resources/secrets

                        cat > src/main/resources/secrets/crypto.properties <<EOF
            $CRYPTO_CONTENT
            EOF

                        echo "crypto.properties created"
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