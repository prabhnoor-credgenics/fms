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