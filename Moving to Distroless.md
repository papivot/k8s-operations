# Moving to Distroless from Alpine

This document is my experience of moving my Python application from an Alpine base image to a "distroless" image. 

As described in their [git hub repo](https://github.com/GoogleContainerTools/distroless) - `"Distroless" images contain only your application and its runtime dependencies. They do not contain package managers, shells or any other programs you would expect to find in a standard Linux distribution. `

## Background
My Python application uses the Kubernetes-python client lruns a very simple web server on port 80.
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTc3MTUzNDQ2NCwxODA1MTU5MjQzXX0=
-->