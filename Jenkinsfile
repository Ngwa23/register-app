pipeline {
    agent any
    
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }

    environment {
        SCANNER_HOME= tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
             git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/Ngwa23/register-app.git'
            }
        }
        
        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }
        
        stage('Test') {
            steps {
                sh "mvn test"
            }
        }
        
        stage('File System Scan') {
            steps {
                sh "trivy fs --format table -o trivy-fs-report.html ."
            }
        }
        
        stage('SonarQube Analsyis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Registrationapp -Dsonar.projectKey=Registrationapp \
                            -Dsonar.java.binaries=. '''
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                script {
                  waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
                }
            }
        }
        
        stage('Build') {
            steps {
               sh "mvn package"
            }
        }
        /*
       stage('Publish To Nexus') {
            steps {
             withMaven(globalMavenSettingsConfig: 'global-settings02', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
               // some block
                  sh "mvn deploy"
                }
                    
            }
        }
        
        */
        stage('Build & Tag Docker Image') {
            steps {
               script {
                 // This step should not normally be used in your script. Consult the inline help for details.
                  withDockerRegistry(credentialsId: 'docker-credentials', toolName: 'docker') {
                      // some block
                   sh "docker build -t ngwa23/registrationapp:v1 . "
                       
                   }
                }
            }
        
        }
        
        stage('Docker Image Scan') {
            steps {
                sh "trivy image --format table -o trivy-image-report.html  ngwa23/registrationapp:v1 "
            }
        }
        
        stage('Push Docker Image') {
            steps {
               script {
                   // This step should not normally be used in your script. Consult the inline help for details.
                   withDockerRegistry(credentialsId: 'docker-credentials', toolName: 'docker') {
                    // some block
                sh "docker push  ngwa23/registrationapp:v1"    
             }
            
            }
         }
           
         }
        
        stage('RemoveDockerImages'){
            steps {
            sh 'docker rmi -f ngwa23/registrationapp:v1'
             }
        }
        
        stage('manualApproval'){
            steps {
          sh "echo Review the application and confirm its performance within 5 hours"
      timeout(time:5, unit:'HOURS') {
       input message: 'Dear Client Ici Sr DevOps NGWA your Application is ready for deployment into K8S, Please review and approve'  
      }
     }
        } 
       stage("Trigger CD Pipeline") {
            steps {
                script {
                    sh "curl -v -k --user NGWA CLOVIS OCHANG:${JENKINS_API_TOKEN} -X POST -H 'cache-control: no-cache' -H 'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=${IMAGE_TAG}' 'http://192.168.244.145:8080/job/REGISTRATION-APP-CD/buildWithParameters?token=gitops-token'"
                }
            }
       }
        
         /*
        stage('Deploy To Kubernetes') {
            steps {
            withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'k8s-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://172.16.59.134:6443') {
              // some block

                 sh "kubectl apply -f deployment-service.yaml"  
                }
            }
        }
     
        
        
        stage('Verify the Deployment') {
            steps {
              withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'k8s-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://172.16.59.134:6443') {
               // some block

                    sh "kubectl get pods -n webapps"
                   sh "kubectl get svc -n webapps"
                }
             }
        }
        */
     }  
     
    post {
    always {
        script {
            def jobName = env.JOB_NAME
            def buildNumber = env.BUILD_NUMBER
            def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
            def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'

            def body = """
                <html>
                <body>
                <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                <h2>${jobName} - Build ${buildNumber}</h2>
                <div style="background-color: ${bannerColor}; padding: 10px;">
                <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                </div>
                <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                </div>
                </body>
                </html>
            """

            emailext (
                subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                body: body,
                to: 'ngwaco23@gmail.com',
                from: 'jenkins@example.com',
                replyTo: 'jenkins@example.com',
                mimeType: 'text/html',
                attachmentsPattern: 'trivy-image-report.html'
            )
       }
    }
}
}

