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
        NPM_CACHE = "${WORKSPACE}/.npm_cache"
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
                    # Set custom npm cache
                    export npm_config_cache=$NPM_CACHE
                    mkdir -p $npm_config_cache

                    # Clean up any existing installs
                    rm -rf node_modules package-lock.json

                    # Install dependencies
                    npm ci || npm install

                    # Build the app
                    npm run build

                    # Copy deploy scripts only if they exist
                    if [ -f deploy.sh ] && [ -f rollback.sh ]; then
                      cp deploy.sh rollback.sh build/
                    fi
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
                            cp -r ${env.APP_PATH}/* ${env.BACKUP_PATH}/${params.DEPLOY_VERSION}/ || true
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
                sh '''
                    if [ -f ${env.APP_PATH}/rollback.sh ]; then
                        chmod +x ${env.APP_PATH}/rollback.sh
                        bash ${env.APP_PATH}/rollback.sh ${params.DEPLOY_VERSION}
                    fi
                '''
            }
        }

        success {
            echo 'Deployment completed successfully.'
        }
    }
}
