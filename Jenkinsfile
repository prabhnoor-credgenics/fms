pipeline {

    agent any

    tools {
        maven 'Maven3'
    }

    parameters {

        string(
            name: 'BRANCH',
            defaultValue: 'new_recovery',
            description: 'Git branch to execute'
        )

        choice(
            name: 'ENVIRONMENT',
            choices: [
                'stag',
                'dev',
                'uat',
                'prod'
            ],
            description: 'Execution environment'
        )

        choice(
            name: 'EXECUTION_MODE',
            choices: [
                'sequential',
                'parallel'
            ],
            description: 'Sequential or Parallel'
        )

        string(
            name: 'THREAD_COUNT',
            defaultValue: '10',
            description: 'Used only for parallel execution'
        )

        string(
            name: 'CUCUMBER_TAGS',
            defaultValue: '',
            description: 'Example: @regression and not @other-pod'
        )

    }

    stages {

        stage('Checkout') {

            steps {

                checkout([
                    $class: 'GitSCM',

                    branches: [[
                        name: "*/${params.BRANCH}"
                    ]],

                    userRemoteConfigs: [[
                        url: 'git@github.com:credgenics/cg-api-automation.git',
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
                """

            }

        }

        stage('Execute Tests') {

            steps {

                script {

                    def tagCommand = ""

                    if (params.CUCUMBER_TAGS?.trim()) {

                        tagCommand =
                        "\"-Dcucumber.filter.tags=${params.CUCUMBER_TAGS}\""

                    }

                    if (params.EXECUTION_MODE == 'parallel') {

                        sh """
                        mvn clean test \
                        -Pparallel \
                        -DthreadCount=${params.THREAD_COUNT} \
                        ${tagCommand}
                        """

                    } else {

                        sh """
                        mvn clean test \
                        ${tagCommand}
                        """

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

                keepAll:
                true,

                alwaysLinkToLastBuild:
                true,

                allowMissing:
                true
            ])

            publishHTML(target: [

                reportDir:
                'TestReports',

                reportFiles:
                '**/HtmlReport/ExtentReport.html',

                reportName:
                'Extent HTML Report',

                keepAll:
                true,

                alwaysLinkToLastBuild:
                true,

                allowMissing:
                true
            ])

            archiveArtifacts(

                artifacts:
                'TestReports/**/*',

                allowEmptyArchive:
                true

            )

        }

    }

}