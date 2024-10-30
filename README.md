# Amazon-FE

Deploying docker image using jenkins pipeline
```bash
stage('deploying in k8s cluster') {
            steps {
                script{
                    dir('Kubernetes') {
                        withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                                sh 'kubectl apply -f deployment.yml'
                        }  
                    }
                }
            }
        }
```

# adding credentils to jenkins

once you add cluster using cmd
```bash
aws eks update-kubeconfig --name cluster --region ap-south-1
```
you will get ouput
```bash
Added new context arn:aws:eks:ap-south-1:703671923900:cluster/cluster to /home/ubuntu/.kube/config
```
take last parameter and copy the content
```bash
sudo cat /home/ubuntu/.kube/config
```
copy and save in your local machine; filename -->"secret-k8s.txt". And finally add this file in credntials section in jenkins.
