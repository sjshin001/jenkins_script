pipeline {
    agent any

    environment {
        SELENIUM_REPO = 'https://github.com/sjshin001/ssj_test_selenium.git'
        SELENIUM_BRANCH = 'master'
    }

    stages {
        stage('Checkout Selenium Project') {
            steps {
                // 워크스페이스 정리 후 Selenium 프로젝트 체크아웃
                cleanWs()
                git url: "${SELENIUM_REPO}", branch: "${SELENIUM_BRANCH}"
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            cleanWs()
        }
    }
}
