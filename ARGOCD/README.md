 # ARGO CD SETUP

 All those components could be installed using a manifest provided by the Argo Project: use the below commands

 ```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml
```

By default, argocd-server is not publicly exposed. For this project, we will use a Load Balancer to make it usable:

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

One load balancer will created in the AWS
Wait about 2 minutes for the LoadBalancer creation

```bash
sudo apt install jq -y
```

```bash
export ARGOCD_SERVER=`kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`
```

when you run this command, it will export the hostname of the ArgoCD server’s load balancer and store it in the ARGOCD_SERVER environment variable, which you can then use in other commands or scripts to interact with the ArgoCD server. This can be useful when you need to access the ArgoCD web UI or interact with the server programmatically.
If run this command you will get the load balancer external IP

```bash
echo $ARGOCD_SERVER
```

# Login

The command you provided is used to extract the password for the initial admin user of ArgoCD, decode it from base64 encoding, and store it in an environment variable named ARGO_PWD.

```bash
export ARGO_PWD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
```

If you want to see your password provide the below command

```bash
echo $ARGO_PWD
```

Now copy the load balancer IP and paste it into the browser

```bash
echo $ARGOCD_SERVER
```
