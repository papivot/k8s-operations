# Moving to Distroless from Alpine

This document is my experience of moving my Python application from an Alpine base image to a "distroless" image. 

As described in their [git hub repo](https://github.com/GoogleContainerTools/distroless) - `"Distroless" images contain only your application and its runtime dependencies. They do not contain package managers, shells or any other programs you would expect to find in a standard Linux distribution. `

## Background
My Python application uses the [Kubernetes-python client libraries](https://github.com/kubernetes-client/python) to generate, every 3 minutes, a JSON output of certain container statistics/information for all PODs running within a Kubernetes cluster. It also runs a very simple web server on port 80, in the background, to service the generated JSON output. A sample output from the application can be similar to this - 

```json
{
    "items": [
        {
            "pod_ip": "10.200.18.7",
            "containername": "nginx-ingress-controller",
            "host_ip": "10.0.11.6",
            "pod": "nginx-ingress-controller-b688677f6-mbqjl",
            "execpodname": "k8s-operations-75d8cddd97-4htxs",
            "clustername": "clustername.demo.local",
            "image": "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.26.1",
            "namespace": "ingress"
        },
        {
        ...
        }
     ]
}
```
The application consists of the following files -

 - `runhttp.py` - Python file to run a simple web server on port 80 in the background.
 - `exportjson.py` - Python file that is executed, every 3 minutes, to generate a JSON dump of the container information of all the PODs in a K8S cluster. 
 - `dockerrun.sh` - A wrapper shell script that runs the two Python scripts. 
 ```shell
 #!/bin/sh
/usr/local/bin/runhttp.py &
/usr/local/bin/exportjson.py
```

## Alpine build

The following Dockerfile was used to build an Alpine based Docker image - 
```shell
FROM alpine:latest
RUN apk update \
    && apk add python3 \
    && pip3 install schedule \
    && pip3 install kubernetes \
    && rm -rf /var/cache/apk/*
RUN mkdir -p /usr/local/bin && mkdir -p /user/k8soper

ENV HOME=/user/k8soper
ADD ./exportjson.py /usr/local/bin/exportjson.py
ADD ./dockerrun.sh /usr/local/bin/dockerrun.sh
ADD ./runhttp.py /usr/local/bin/runhttp.py

RUN chmod +x /usr/local/bin/runhttp.py \
 && chmod +x /usr/local/bin/exportjson.py \
 && chmod +x /usr/local/bin/dockerrun.sh

RUN adduser k8soper -Du 9999 -h /user/k8soper
USER k8soper
WORKDIR /user/k8soper
EXPOSE 8080
CMD ["/usr/local/bin/dockerrun.sh"]
```
While there can be further modifications and simplifications to the above Dockerfile (feedbacks welcome), this does the job and build an image that is approx. 30MB in size. Unfortunately, Alpine provides a bunch of packages besides the ones required to run the image. All these need to be maintained and updated regularly. 

---
## Distroless build

While using a distroless image build the container image, one does not have access to any shell commands and package manager binaries. In the above Dockerfile, the following commands would not work - `apk`, `mkdir`, `chmod`,`adduser`. These requirements have to be achieved by  using a stepped build. 

The 

<!--stackedit_data:
eyJoaXN0b3J5IjpbLTQ3NTk1MTg5OSwxODIxNjU5NzY1LDE4MD
UxNTkyNDNdfQ==
-->