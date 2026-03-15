pipeline {
    agent any

    environment {
        // You will need to define these in Jenkins Credentials and Environment Variables
        DOCKER_REGISTRY_CREDENTIALS = 'your-docker-registry-credentials-id'
        DOCKER_IMAGE_NAME = 'your-dockerhub-username/personal-website' 
        AWS_SSH_CREDENTIALS = 'your-aws-ssh-credentials-id'
        AWS_EC2_IP_OR_HOSTNAME = 'your.ec2.instance.ip'
    }

    stages {
        stage('Checkout') {
            steps {
                // Pulls the latest code from the GitHub repository
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                script {
                    // Builds the Docker image and tags it with the Jenkins build number
                    dockerImage = docker.build("${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Push Image') {
            steps {
                script {
                    // Logs into the Docker registry and pushes the built image
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_REGISTRY_CREDENTIALS) {
                        dockerImage.push()
                        dockerImage.push('latest') // Also tag it as latest
                    }
                }
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                // Connects to the EC2 instance, pulls the new image, and runs it
                sshagent([AWS_SSH_CREDENTIALS]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ec2-user@${AWS_EC2_IP_OR_HOSTNAME} '
                            # Stop any existing container
                            docker stop personal-website || true
                            docker rm personal-website || true
                            
                            # Pull the latest image
                            docker pull ${DOCKER_IMAGE_NAME}:latest
                            
                            # Run the new container on port 80
                            docker run -d --name personal-website -p 80:80 ${DOCKER_IMAGE_NAME}:latest
                        '
                    """
                }
            }
        }
    }

    post {
        always {
            // Clean up old local images on the Jenkins server to save space
            sh "docker image prune -f"
        }
    }
}
