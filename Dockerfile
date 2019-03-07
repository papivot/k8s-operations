FROM alpine:latest
RUN apk update \
    && apk add python3 \
    && pip3 install schedule \
    && rm -rf /var/cache/apk/*
RUN mkdir -p /usr/local/bin && mkdir -p /user/k8soper

ENV HOME=/user/k8soper
ADD ./kubectl /usr/local/bin/kubectl
ADD ./dumpconfig.sh /usr/local/bin/dumpconfig.sh
ADD ./exportjson.py /usr/local/bin/exportjson.py
ADD ./dockerrun.sh /usr/local/bin/dockerrun.sh
ADD ./runhttp.py /usr/local/bin/runhttp.py

RUN chmod +x /usr/local/bin/kubectl \
	&& chmod +x /usr/local/bin/dumpconfig.sh \
	&& chmod +x /usr/local/bin/runhttp.py \
	&& chmod +x /usr/local/bin/exportjson.py \
	&& chmod +x /usr/local/bin/dockerrun.sh 

RUN adduser k8soper -Du 9999 -h /user/k8soper
USER k8soper
WORKDIR /user/k8soper
EXPOSE 8080
CMD ["/usr/local/bin/dockerrun.sh"]
