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
