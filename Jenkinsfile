pipeline {

    agent any

    tools {
        jdk 'JDK17'
        maven 'Maven3'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'new_recovery',
                    url: 'https://github.com/credgenics/cg-api-automation.git'
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