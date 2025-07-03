pipeline {
    agent any


    environment {
        ARTIFACT = 'target/*.jar'
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
                archiveArtifacts artifacts: "${ARTIFACT}", fingerprint: true
            }
        }

        stage('Run on localhost for 2 minutes') {
            steps {
                echo 'Starting server on port 9000 for 2 minutes...'
                bat '''
                    start "" java -jar target\\spring-petclinic-3.5.0-SNAPSHOT.jar --server.port=9000
                    ping -n 121 127.0.0.1 > nul
                    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :9000 ^| findstr LISTENING') do taskkill /PID %%a /F
                '''
            }
        }
    
    }
    
    post {
        success {
            echo 'Build & Test pipeline completed successfully!'
        }
        failure {
            echo 'Build failed. Check the logs.'
        }
    }
}
