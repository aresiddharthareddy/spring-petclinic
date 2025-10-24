pipeline {
    agent any

    environment {
        OPENAI_API_KEY = 'YOUR_OPENAI_API_KEY'  // replace with your key
        EMAIL_TO = 'developer@example.com'
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building the project...'
                bat 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                bat 'mvn test'
            }
        }

        stage('Package') {
            steps {
                echo 'Packaging the project...'
                bat 'mvn package'
            }
        }

        stage('Archive Artifact') {
            steps {
                echo 'Archiving JAR file...'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Run on localhost for 2 minutes') {
            steps {
                echo 'Starting server on port 9000 for 2 minutes...'
                bat '''
                    start "" java -jar target\\spring-petclinic-3.5.0-SNAPSHOT.jar --server.port=9000
                    ping -n 121 127.0.0.1 > nul
                    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :9000 ^| findstr LISTENING') do taskkill /PID %%a /F || exit 0
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished — generating AI log summary...'

            script {
                // Read the Jenkins log file
                def logFile = "${WORKSPACE}\\pipeline.log"
                bat "powershell -Command \"Get-Content ${BUILD_URL}consoleText | Out-File -FilePath ${logFile}\""

                def logs = readFile(logFile).replaceAll("\\r?\\n"," ")

                // Call GenAI API using curl
                def apiResponse = bat(
                    script: """
                        curl https://api.openai.com/v1/chat/completions ^
                        -H "Content-Type: application/json" ^
                        -H "Authorization: Bearer ${OPENAI_API_KEY}" ^
                        -d "{\\"model\\": \\"gpt-4\\", \\"messages\\":[{\\"role\\":\\"user\\",\\"content\\":\\"Summarize these CI/CD logs in bullet points, highlight failures, root causes, and suggested fixes: ${logs}\\"}], \\"temperature\\":0}" ^
                        -s
                    """,
                    returnStdout: true
                ).trim()

                def jsonSlurper = new groovy.json.JsonSlurper()
                def json = jsonSlurper.parseText(apiResponse)
                def summary = json.choices[0].message.content

                echo "==== CI/CD Log Summary ===="
                echo summary

                // Send summary email using Jenkins mail plugin
                mail to: "${EMAIL_TO}",
                     subject: "CI/CD Pipeline Summary - Job '${env.JOB_NAME}' [#${env.BUILD_NUMBER}]",
                     body: "Hello Team,\n\nHere is the AI-generated CI/CD pipeline summary:\n\n${summary}\n\nCheck full logs at: ${env.BUILD_URL}"
            }
        }
    }
}
