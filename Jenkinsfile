properties([
    parameters([
        string(
            defaultValue: 'dev',
            name: 'Environment'
        ),
        choice(
            choices: ['plan', 'apply', 'destroy'], 
            name: 'Terraform_Action'
        )
    ])
])

pipeline {
    agent any
    stages {
        stage('Preparing') {
            steps {
                sh 'echo Preparing...'
            }
        }
        stage('Git Pulling') {
            steps {
                git branch: 'main', url: 'https://github.com/sandeep459238/Microservice-Apps.git'
            }
        }
        stage('Init') {
            steps {
                sh 'terraform -chdir=dev-eks/ init'
            }
        }
        stage('Validate') {
            steps {
                sh 'terraform -chdir=dev-eks/ validate'
            }
        }
        stage('Action') {
            steps {
                script {
                    if (params.Terraform_Action == 'plan') {
                        sh "terraform -chdir=dev-eks/ plan -var-file=${params.Environment}.tfvars"
                    } else if (params.Terraform_Action == 'apply') {
                        sh "terraform -chdir=dev-eks/ apply -var-file=${params.Environment}.tfvars -auto-approve"
                        // Run post-cluster creation script
                        sh "chmod +x microservice/cluster-check-status.sh"
                        sh "bash microservice/cluster-check-status.sh"
                    } else if (params.Terraform_Action == 'destroy') {
                        sh "terraform -chdir=dev-eks/ destroy -var-file=${params.Environment}.tfvars -auto-approve"
                    } else {
                        error "Invalid value for Terraform_Action: ${params.Terraform_Action}"
                    }
                }
            }
        }
    }
}
