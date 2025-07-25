pipeline {
    agent any

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
        stage('Check Node') {
            steps {
                sh 'which node'
                sh 'node -v'
                sh 'npm -v'
            }
        }
        stage('Install & Build') {
            steps {
                echo "Installing dependencies and building the React app"
                sh 'npm install'
                sh 'npm run build'

                // Copy deploy/rollback scripts into the build folder for later use
                sh 'cp deploy.sh rollback.sh build/'
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying locally to $APP_PATH"
                script {
                    try {
                        sh """
                            mkdir -p $BACKUP_PATH/${params.DEPLOY_VERSION}
                            cp -r $APP_PATH/* $BACKUP_PATH/${params.DEPLOY_VERSION}/
                            cp -r build/* $APP_PATH/
                            chmod +x $APP_PATH/deploy.sh $APP_PATH/rollback.sh
                            bash $APP_PATH/deploy.sh ${params.ENV}
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
            sh """
                chmod +x $APP_PATH/rollback.sh
                bash $APP_PATH/rollback.sh ${params.DEPLOY_VERSION}
            """
        }
        success {
            echo 'Deployment completed successfully.'
        }
    }
}
