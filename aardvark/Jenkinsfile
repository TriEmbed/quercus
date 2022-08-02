pipeline {
    agent any
    options {
        timestamps()
    }
    environment {
        ONLINE_SITE = ''
    }
    stages {
        stage('Build') { 
            steps {
                sh 'npm install'
                sh 'npm run build' 
            }
        }
        stage('Deploy') {
        }
    }
    post {
        always {
            emailext body: "View on ${ONLINE_SITE}, See detail at ${BUILD_URL}",
                    recipientProviders: [developers(), requestor()],
                    subject: "Jenkins: ${JOB_NAME} ${GIT_BRANCH} build ${currentBuild.result}",
                    to: 'NickEdgington@gmail.com'
        }
    }
}
