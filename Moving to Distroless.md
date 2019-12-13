# Moving to Distroless from Alpine

This document is my experience of moving my Python application from an Alpine base image to a "distroless" image. 

As described in their [git hub repo](https://github.com/GoogleContainerTools/distroless) - `"Distroless" images contain only your application and its runtime dependencies. They do not contain package managers, shells or any other programs you would expect to find in a standard Linux distribution. `

## Background
My Python application uses the [Kubernetes-python client libraries](https://github.com/kubernetes-client/python) to generate, every 3 minutes, a JSON output of certain container statistics/information for all PODs running within a Kubernetes cluster. It also runs a very simple web server on port 80, in the background, to service the generated JSON output. A sample output from the application can be similar to this - 

```json

```
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTA4NjQzNzE4MSwxODA1MTU5MjQzXX0=
-->