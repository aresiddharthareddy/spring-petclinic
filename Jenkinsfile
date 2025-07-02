pipeline {
    agent any


    environment {
        ARTIFACT = 'target/*.jar'
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building the project...'
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                echo 'Packaging the project...'
                sh 'mvn package'
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
