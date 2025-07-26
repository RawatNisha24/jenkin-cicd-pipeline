pipeline {
    agent {
        docker {
            image 'node:18'
        }
    }

    parameters {
        string(name: 'DEPLOY_VERSION', defaultValue: 'v1.0', description: 'Deployment version')
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Git branch to deploy')
        choice(name: 'ENV', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
    }

    environment {
        APP_PATH = '/var/www/reactapp'
        BACKUP_PATH = '/var/www/reactapp_backups'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Checking out branch ${params.BRANCH_NAME}"
                git credentialsId: 'github-ssh-key',
                    branch: "${params.BRANCH_NAME}",
                    url: 'git@github.com:RawatNisha24/jenkin-cicd-pipeline.git'
            }
        }

        stage('Install & Build') {
            steps {
                echo "Installing dependencies and building the React app"
                sh '''
                    rm -rf node_modules package-lock.json
                    npm install
                    npm run build
                    cp deploy.sh rollback.sh build/
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying to ${env.APP_PATH}"
                script {
                    try {
                        sh """
                            mkdir -p ${env.BACKUP_PATH}/${params.DEPLOY_VERSION}
                            cp -r ${env.APP_PATH}/* ${env.BACKUP_PATH}/${params.DEPLOY_VERSION}/
                            cp -r build/* ${env.APP_PATH}/
                            chmod +x ${env.APP_PATH}/deploy.sh ${env.APP_PATH}/rollback.sh
                            bash ${env.APP_PATH}/deploy.sh ${params.ENV}
                        """
                    } catch (e) {
                        echo "Deployment error: ${e.getMessage()}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }
    }

    post {
        failure {
            echo 'Deployment failed. Starting rollback.'
            script {
                sh """
                    chmod +x ${env.APP_PATH}/rollback.sh
                    bash ${env.APP_PATH}/rollback.sh ${params.DEPLOY_VERSION}
                """
            }
        }

        success {
            echo 'Deployment completed successfully.'
        }
    }
}
