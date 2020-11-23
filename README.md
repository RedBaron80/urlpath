# Python - Django - http proxy - kubernetes Sample application 

This is a test-driven sample application and installation consisting of:

    1. Python application (/urlpath-django/urlpath/). Given a URL, it will return the path. For example, http://www.example.com/hello will return "hello".
    2. Django framework to serve the above application and handle requests (/urlpath-django)
    3. Apache reverse proxy to forward petitions to the application (/httpd-proxy)
    4. Kubernetes manifest files to load local images of the above.

# Usage
Copy `install.sh` from the root folder of this project and execute it in an ubuntu fresh server (tested in 16.04 LTS).

That's it.

Wait a few minutes for the script to finish and then go to the server public IP address to check that it's working `http://<ip>/hello`

# Components
Explanation of the python-django application, the proxy and the kubernetes files

## Urlpath - app

Application developed using TDD, tests are located in the /urlpath-django/tests/ directory. It's basically one:

```
    assertEqual(urlpath.getUrlPath('http://www.example.com/hello/'), 'hello')   
```

The main code is located in urlpath-django/urlpath/. There are two methods. The main one is using `urlparse(url).path` library to get the path, and `removeFirstAndLastSlash(path)` remove unwanted `/`

## Urlpath - django project
In order to make this app work locally dowload or clone the code. In the /urlpath-django directory run `make init` to install dependencies and then `python3 python manage.py runserver 3000`. Then you can test the application like this.
```
    $ curl localhost:3000/this/is/a/test/
    this/is/a/test 
```
In the /urlpath-server/urls.py file we tell the dispatcher to dispatch all urls to our app
```python
    path('', include("urlpath.urls")), 
    re_path(r'^.*', include("urlpath.urls"))
```

## httpd-proxy
This is a reverse proxy with Apache. It is a clean apache installation with this reverse proxy configuration:
```
    ProxyPass "/"  "http://urlpath:3000/"
    ProxyPassReverse "/"  "http://urlpath:3000/"
```
This configuration works with a service discovery system, for example docker compose or any other containers orchestrator. You can still use this adding the "urlpath" service ip address in the proxy hosts file.

*Improvement:* Use the "urlpath" as an environment variable, not hardcoded.

## kubernetes
In the directories urlpath-django and httpd-proxy you will find the Dockerfiles to build the images.
In the kubernetes directory you will find the manifest files to load the image files from local. In the `install.sh` file we are using local images and import them into the orchestrator system. Another totally valid option would be to use a local or external docker registry and change the deployment files to use that.

```yaml
    containers:
    - image: urlpath:1.0
    imagePullPolicy: IfNotPresent
```
in order to use local images the imagePullPolicy has to be *IfNotPresent* or *Never*

### Services
Urlpath service is type *ClusterIP*, so the other services can use it.
httpd-proxy service is type *NodePort* so we can access the service externally. For example:
```bash
ubuntu@ip-172-31-16-184:~$ kubectl get service httpd-proxy
NAME          TYPE       CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
httpd-proxy   NodePort   10.43.4.60   <none>        80:31030/TCP   15h
ubuntu@ip-172-31-16-184:~$ curl http://localhost:31030/hello
hello
```
Bear in mind that the service external port is random. So we would have to open that port in the firewall to access the application. This is not very convenient. In order to solve that, ingress come to the rescue.

### Ingress
K3s comes with Traefik ingress out of the box. We can access our urlpath service directly, and the ingress controller would act as a reverse proxy.
```yaml
  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    name: urlpath
  spec:
    rules:
    - http:
        paths:
        - backend:
            serviceName: urlpath
            servicePort: 3000
            path: /
            pathType: Prefix
```
By appling the above yaml manifest, we can access our ingress from the 80 port of our server unsing http.

# Q&A

### Is this production ready?
No.

### But...
No.

### What do we need to install this application in a production-ready infrastructure?
* We must not use Django's development server for production-use and debug mode. We should use and apache or nginx's wsgi modules instead.
* The infrastructure should be high availability, now everything is installed in a single node.
* We haven't tested the performance of the application. Django has a module that gets the url path out of the box. Maybe it is more efficient?
* The installation should be done with a configuration management tool like Ansible rather than a bash script.
