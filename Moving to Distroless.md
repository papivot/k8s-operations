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

 - `

<!--stackedit_data:
eyJoaXN0b3J5IjpbMTA0OTkwNiwxODA1MTU5MjQzXX0=
-->