pipeline {
    agent any

    environment {
        OPENAI_API_KEY = 'AIzeSyCkOH15hWfIviZPpF_jZ9T9gsBAlmYSDtI'  // replace with your key
        EMAIL_TO = 'sare@osidigital.com'
        APP_PORT = '9000'
        BUILD_LOG = "${WORKSPACE}\\build.log"
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building the project...'
                bat "mvn clean compile > ${BUILD_LOG} 2>&1"
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                bat "mvn test >> ${BUILD_LOG} 2>&1"
            }
        }

        stage('Package') {
            steps {
                echo 'Packaging the project...'
                bat "mvn package >> ${BUILD_LOG} 2>&1"
            }
        }

        stage('Archive Artifact') {
            steps {
                echo 'Archiving JAR file...'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Deploy Application') {
            steps {
                echo "Deploying Spring Petclinic on port ${APP_PORT}..."
                bat """
                    start "" java -jar target\\spring-petclinic-3.5.0-SNAPSHOT.jar --server.port=${APP_PORT} >> ${BUILD_LOG} 2>&1
                    ping -n 10 127.0.0.1 > nul
                """
                echo "Application deployed. Check http://localhost:${APP_PORT}"
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished — generating AI log summary...'

            script {
                // Read local log file
                def logs = readFile(BUILD_LOG).replaceAll("\\r?\\n"," ")

                // Call GenAI API using curl
                def apiResponse = bat(
                    script: """
                        curl https://api.openai.com/v1/chat/completions ^
                        -H "Content-Type: application/json" ^
                        -H "Authorization: Bearer ${OPENAI_API_KEY}" ^
                        -d "{\\"model\\": \\"gpt-4\\", \\"messages\\":[{\\"role\\":\\"user\\",\\"content\\":\\"Summarize these deployment-level CI/CD logs in bullet points, highlight failures, root causes, and suggested fixes: ${logs}\\"}], \\"temperature\\":0}" ^
                        -s
                    """,
                    returnStdout: true
                ).trim()

                def jsonSlurper = new groovy.json.JsonSlurper()
                def json = jsonSlurper.parseText(apiResponse)
                def summary = json.choices[0].message.content

                echo "==== CI/CD Deployment Log Summary ===="
                echo summary

                // Send summary email
                mail to: "${EMAIL_TO}",
                     subject: "Deployment Pipeline Summary - Job '${env.JOB_NAME}' [#${env.BUILD_NUMBER}]",
                     body: "Hello Team,\n\nHere is the AI-generated deployment pipeline summary:\n\n${summary}\n\nCheck full logs at: ${env.BUILD_URL}"
            }
        }
    }
}
