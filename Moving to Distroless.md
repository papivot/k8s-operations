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

The following standard Dockerfile was used to build an Alpine based Docker image - 
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

While using a distroless image build the container image, one does not have access to any shell commands and package manager binaries. In the above Dockerfile, the following commands would not work - `apk`, `mkdir`, `chmod`,`adduser`, `pip`. These requirements have to be achieved by  using a [multi-staged build](https://docs.docker.com/develop/develop-images/multistage-build/). 
Multi-Stage builds allow you to `build` the program in one container image, and copy over only the artifacts required from the first container image to a target image, which is what is used to run your program.

The new Dockerfile (with line numbers for reference below) that was used is as follows - 

```shell
  1 FROM python:3-slim AS build-env
  2 RUN mkdir -p /app && mkdir -p /user/k8soper
  3 ADD ./exportjson.py /app/exportjson.py
  4 ADD ./dockerrun.sh /app/dockerrun.sh
  5 ADD ./runhttp.py /app/runhttp.py
  6 ADD ./execdockerrun.py /app/execdockerrun.py
  7 RUN chmod +x /app/dockerrun.sh \
  8  && chmod +x /app/runhttp.py \
  9  && chmod +x /app/exportjson.py \
 10  && chmod +x /app/execdockerrun.py
 11 RUN pip3 install --upgrade pip \
 12     && pip3 install schedule \
 13     && pip3 install kubernetes
 14
 15 FROM gcr.io/distroless/python3
 16 COPY --from=build-env /user /user
 17 COPY --from=build-env /app /usr/local/bin
 18 COPY --from=build-env /usr/local/lib/python3.8/site-packages /usr/lib/python3.5/site-packages
 19 ENV PYTHONPATH=/usr/lib/python3.5/site-packages
 20 USER nonroot
 21 WORKDIR /user/k8soper
 22 EXPOSE 8080
 23 CMD ["/usr/local/bin/execdockerrun.py"]
```
* `1`. We start with a temporary/build image - python:3-slim - that has all the relevant shell and Python3 package manager installed. Call it the `build-env`.
* `2`. Create the necessary **directory structure** where to copy the app binaries or where the app would be creating files. 
* `3. .. 6`. Copy the app scripts/files to the temp image. 
* `7. .. 10`. Mark the files executable. Not sure if this is needed??? May be required (TBD)
* `11. .. 13`. Run PIP to download and install the relevant Python3 packages to the known location in the build env. 
* `15. Now that the build environment is ready/prepared, we get the relevant distroless Docker image from gcr.io. The links/details are provided [here.](https://github.com/GoogleContainerTools/distroless)
* 16. ... 17. Copy the relevant files/directory structure(s) from the `build-env` to the distroless image. 
* 18. Copy the pip packages from the `build-env` to the relevant folder in the distroless image.  
*  19. Optional - if using a non-standard site-package path (default is /usr/local/lib/python{version}/site-packages) set the `PYTHONPATH` env variable. 
* 20. By default, distroless has only 3 users -  `root`, `nonroot` and `nobody`. Since the image will be executed as a non root user, set the `USER` variable accordingly.
* 21. Default home directory of `nonroot` is `/home/nonroot`. Since our application needs to work in `/user/k8soper` set the `WORKDIR` accordingly. 
* 22. Expose the port 8080. 
* 23.   Distroless images by default do not contain a shell. That means the Dockerfile `ENTRYPOINT` command, when defined, must be specified in `vector` form, to avoid the container runtime prefixing with a shell. For the same reasons, if the entrypoint is left to the default empty vector, the CMD command should be specified in `vector` form


<!--stackedit_data:
eyJoaXN0b3J5IjpbMTQyNDA2NTU1MiwxODIxNjU5NzY1LDE4MD
UxNTkyNDNdfQ==
-->