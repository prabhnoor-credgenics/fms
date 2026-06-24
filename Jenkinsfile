pipeline {

    agent any

    tools {
        maven 'Maven3'
        jdk 'JDK17'
    }

    parameters {

        string(
            name: 'BRANCH',
            defaultValue: 'main',
            description: 'Enter branch name'
        )

        choice(
            name: 'ENVIRONMENT',
            choices: [
                'dev',
                'stag',
                'uat',
                'prod'
            ],
            description: 'Select environment'
        )

        choice(
            name: 'EXECUTION_MODE',
            choices: [
                'sequential',
                'parallel'
            ],
            description: 'Select execution mode'
        )

    }

    stages {

        stage('Checkout') {

            steps {

                checkout([
                    $class: 'GitSCM',

                    branches: [[
                        name:
                        "*/${params.BRANCH}"
                    ]],

                    userRemoteConfigs: [[
                        url:
                        'git@github.com:credgenics/cg-api-automation.git',

                        credentialsId:
                        'ca53bb45-e65c-433a-b0d3-60ab83c1b41a'
                    ]]
                ])

            }

        }

        stage('Prepare Secrets') {

            steps {

                withCredentials([
                    file(
                        credentialsId:
                        'crypto-properties',

                        variable:
                        'CRYPTO_FILE'
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

        stage('Set Environment') {

            steps {

                sh """
                sed -i.bak \
                's/^environment=.*/environment=${params.ENVIRONMENT}/' \
                src/main/resources/global.properties

                echo "Environment set to ${params.ENVIRONMENT}"
                """
            }

        }

        stage('Execute Tests') {

            steps {

                script {

                    if (
                        params.EXECUTION_MODE
                        ==
                        'parallel'
                    ) {

                        echo 'Running Parallel Execution'

                        sh '''
                        mvn clean test -Pparallel
                        '''

                    } else {

                        echo 'Running Sequential Execution'

                        sh '''
                        mvn clean test
                        '''

                    }

                }

            }

        }

    }

    post {

        always {

            junit(
                allowEmptyResults: true,
                testResults:
                'target/surefire-reports/*.xml'
            )

            publishHTML(target: [

                reportDir:
                'TestReports',

                reportFiles:
                '**/SparkReport/Spark.html',

                reportName:
                'Extent Spark Report',

                keepAll: true,

                alwaysLinkToLastBuild: true,

                allowMissing: true

            ])

            publishHTML(target: [

                reportDir:
                'TestReports',

                reportFiles:
                '**/HtmlReport/ExtentReport.html',

                reportName:
                'Extent HTML Report',

                keepAll: true,

                alwaysLinkToLastBuild: true,

                allowMissing: true

            ])

            archiveArtifacts(
                artifacts:
                'TestReports/**/*',
                allowEmptyArchive: true
            )

        }

        success {

            echo '''
            Build Completed Successfully
            '''

        }

        failure {

            echo '''
            Build Failed
            '''

        }

    }

}