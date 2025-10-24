pipeline {
    agent any

    environment {
        OPENAI_API_KEY = 'AIzaSyCkOH15hWhIviZPpF_jZ9T0gsBAlmYSDtI' // <-- Replace with actual key (don’t commit it)
        EMAIL_TO = 'sare@osidigital.com'
        ARTIFACT = 'target/*.jar'
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
                archiveArtifacts artifacts: "${ARTIFACT}", fingerprint: true
            }
        }

        stage('Run Application for 2 Minutes') {
            steps {
                echo "Starting Spring Petclinic on port ${APP_PORT}..."
                bat """
                    start "" java -jar target\\spring-petclinic-3.5.0-SNAPSHOT.jar --server.port=${APP_PORT} >> ${BUILD_LOG} 2>&1
                    ping -n 121 127.0.0.1 > nul
                    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :${APP_PORT} ^| findstr LISTENING') do taskkill /PID %%a /F || exit 0
                """
                echo "Application stopped after 2 minutes."
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished — generating AI summary...'

            script {
                // Safely read build logs
                def logs = readFile(BUILD_LOG).take(12000).replaceAll("\\r?\\n"," ")

                // Prepare JSON payload
                def payload = """
                {
                    "model": "gpt-4o-mini",
                    "messages": [
                        {
                            "role": "user",
                            "content": "Summarize this Jenkins CI/CD build and deployment log in bullet points. Highlight key build steps, any failures, and suggested fixes: ${logs}"
                        }
                    ],
                    "temperature": 0.2
                }
                """

                // Call OpenAI API (Windows-friendly curl)
                def apiResponse = bat(
                    script: """
                        curl -s https://api.openai.com/v1/chat/completions ^
                        -H "Content-Type: application/json" ^
                        -H "Authorization: Bearer ${OPENAI_API_KEY}" ^
                        -d "${payload.replace('"', '\\"')}"
                    """,
                    returnStdout: true
                ).trim()

                // Parse response JSON
                def json = new groovy.json.JsonSlurper().parseText(apiResponse)
                def summary = json?.choices?.getAt(0)?.message?.content ?: "AI summary not available."

                echo "==== AI Generated CI/CD Summary ===="
                echo summary

                // Email summary to team
                mail to: "${EMAIL_TO}",
                     subject: "CI/CD Build Summary - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                     body: """Hello Team,

The CI/CD pipeline has completed. Below is the AI-generated summary:

${summary}

You can view detailed logs here: ${env.BUILD_URL}
"""
            }
        }

        success {
            echo '✅ Build & Test pipeline completed successfully!'
        }

        failure {
            echo '❌ Build failed. Check the logs.'
        }
    }
}
