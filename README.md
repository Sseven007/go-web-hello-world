This is a demo project required by SRE role. 

The candidate should be able to complete the project independently in two days and well document the procedure in a practical and well understanding way.

It is not guaranteed that all tasks can be achieved as expected, in which circumstance, the candidate should trouble shoot the issue, conclude based on findings and document which/why/how.

### Task 0: Install a ubuntu 16.04 server 64-bit

either in a physical machine or a virtual machine

http://releases.ubuntu.com/16.04/<br>
http://releases.ubuntu.com/16.04/ubuntu-16.04.6-server-amd64.iso<br>
https://www.virtualbox.org/

for VM, use NAT network and forward required ports to host machine
- 22->2222 for ssh
- 80->8080 for gitlab
- 8081/8082->8081/8082 for go app
- 31080/31081->31080/31081 for go app in k8s  
  
  
Devices: CE-TU130  
Sever1:  (installed docker gitlab)  
  
Sever2:  (installed single node Kubernetes cluster )  


### Task 1: Update system

ssh to guest machine from host machine ($ ssh user@localhost -p 2222) and update the system to the latest

https://help.ubuntu.com/16.04/serverguide/apt.html

upgrade the kernel to the 16.04 latest  
  
```  
### Step 1 - Update Ubuntu Repository and Upgrade all Packages  
sudo apt update  
sudo apt upgrade -y  
sudo reboot  
sudo apt list --upgradeable  
  
### Step 2 - Checking the Active Kernel Version  
uname -msr  
  
### Step 3 - Install New Kernel Version  

sudo mkdir -p ~/v5.4.6  
cd ~/v5.4.6  

Go to page:  
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.6/  

wget package  
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.6/linux-headers-5.4.6-050406_5.4.6-050406.201912211140_all.deb  
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.6/linux-headers-5.4.6-050406-generic_5.4.6-050406.201912211140_amd64.deb  
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.6/linux-image-unsigned-5.4.6-050406-generic_5.4.6-050406.201912211140_amd64.deb  
https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.6/linux-modules-5.4.6-050406-generic_5.4.6-050406.201912211140_amd64.deb  

dpkg -i -R .  
sudo update-grub  
sudo reboot  

uname -msr
```
 

### Task 2: install gitlab-ce version in the host
https://about.gitlab.com/install/#ubuntu?version=ce

Expect output: Gitlab is up and running at http://127.0.0.1 (no tls or FQDN required)

Access it from host machine http://127.0.0.1:8080  
```
step 1. sudo apt-get install -y curl openssh-server ca-certificates  

step 2. curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash  
        sudo EXTERNAL_URL="http://ce-tu130.rnd.gic.ericsson.se" apt-get install gitlab-ce

step 3. Set port from 80 to 8080  
 
vim /etc/gitlab/gitlab.rb  
1. sidekiq['listen_port'] = 9092  
2. external_url 'http://node-10-210-149-130.rnd.gic.ericsson.se:8080'  
3. # unicorn['listen'] = 'localhost'
   unicorn['port'] = 28080  
4. sudo gitlab-ctl reconfigure
```
  

### Task 3: create a demo group/project in gitlab

named demo/go-web-hello-world (demo is group name, go-web-hello-world is project name).

Use golang to build a hello world web app (listen to 8081 port) and check-in the code to mainline.

https://golang.org/<br>
https://gowebexamples.com/hello-world/

Expect source code at http://127.0.0.1:8080/demo/go-web-hello-world  
```
http://10.210.149.130:8080/demo/go-web-hello-world 
app hello world  
package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Go Web Hello World!", r.URL.Path)
    })

    http.ListenAndServe(":8081", nil)
}

git add hello.go
git commite -m "added go app hello world"  
git psuh 
```

### Task 4: build the app and expose ($ go run) the service to 8081 port

Expect output: 
```
curl http://127.0.0.1:8081
Go Web Hello World!
```  
```
export PATH=$PATH:/usr/local/go/bin  
go run hello.go  
```

### Task 5: install docker
https://docs.docker.com/install/linux/docker-ce/ubuntu/

### Task 6: run the app in container

build a docker image ($ docker build) for the web app and run that in a container ($ docker run), expose the service to 8082 (-p)

https://docs.docker.com/engine/reference/commandline/build/

Check in the Dockerfile into gitlab
```
Expect output:
curl http://127.0.0.1:8082
Go Web Hello World!
```
Dockerfile  
```
# this is to build the image
FROM golang:alpine as build

WORKDIR /go/src/go-web-hello-world
ADD . .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo .

CMD ["./go-web-hello-world"]

# this is to publish the image
FROM scratch AS prod

COPY --from=build /go/src/go-web-hello-world/go-web-hello-world .
CMD ["./go-web-hello-world"]


build docker image
#docker build -t sevendong/go-web-hello-world:v0.1 .  

run docker container 
#docker run -p 8082:8081 -ti sevendong/go-web-hello-world:v0.1 -d



```

### Task 7: push image to dockerhub

tag the docker image using your_dockerhub_id/go-web-hello-world:v0.1 and push it to docker hub (https://hub.docker.com/)

Expect output: https://hub.docker.com/repository/docker/your_dockerhub_id/go-web-hello-world  
```
docker login
docker push sevendong/go-web-hello-world:v0.1   
https://hub.docker.com/repository/docker/sevendong/go-web-hello-world
```

### Task 8: document the procedure in a MarkDown file

create a README.md file in the gitlab repo and add the technical procedure above (0-7) in this file



### Task 9: install a single node Kubernetes cluster using kubeadm
https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

Check in the admin.conf file into the gitlab repo  

cluster: ce-tu130 node-131

### Task 10: deploy the hello world container

in the kubernetes above and expose the service to nodePort 31080

Expect output:
```
curl http://127.0.0.1:31080
Go Web Hello World!
```  
```    
docker login
docker pull sevendong/go-web-hello-world:v0.1
root@node-10-210-149-131:~# cat hello-world.yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello
  labels:
    name: hello
spec:
  containers:
  - name: hello
    image: sevendong/go-web-hello-world:v0.1
    ports:
    - containerPort: 8081
      hostPort: 31080    
  
kubectl create -f hello-world.yaml  
  
  http://10.210.149.131:31080/
```

Check in the deployment yaml file or the command line into the gitlab repo

------------------------------------

### Task 11: install kubernetes dashboard

and expose the service to nodeport 31081

https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

Expect output: https://127.0.0.1:31081 (asking for token)  
```  
Step 1. kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml  
  
Step 2. expose the dashborad by Nodeport  
kubectl edit svc kubernetes-dashboard -n kubernetes-dashboard -o yaml  
  
apiVersion: v1
kind: Service
metadata:
  annotations:
    field.cattle.io/publicEndpoints: '[{"port":31081,"protocol":"TCP","serviceName":"kubernetes-dashboard:kubernetes-dashboard","allNodes":true}]'
  creationTimestamp: "2019-12-27T08:32:57Z"
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
  resourceVersion: "42840"
  selfLink: /api/v1/namespaces/kubernetes-dashboard/services/kubernetes-dashboard
  uid: 9946c612-100e-4fa9-b151-5c71e12b7862
spec:
  clusterIP: 10.96.96.47
  externalTrafficPolicy: Cluster
  ports:
  - nodePort: 31081
    port: 443
    protocol: TCP
    targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}

```

### Task 12: generate token for dashboard login in task 11

figure out how to generate token to login to the dashboard and publish the procedure to the gitlab.  
```
https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md


Create Service Account
We are creating Service Account with name admin-user in namespace kubernetes-dashboard first.

apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboar
  
Create ClusterRoleBinding


apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
  
Bearer Token
Now we need to find token we can use to log in. Execute following command:

For Bash:

kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')



met the token issue during the login 

refer to the page: https://github.com/kubernetes/dashboard/issues/2954

```
--------------------------------------

### Task 13: publish your work

push all files/procedures in your local gitlab repo to remote github repo (e.g. https://github.com/your_github_id/go-web-hello-world)

if this is for an interview session, please send it to bo.cui@ericsson.com, no later than two calendar days after the interview.
