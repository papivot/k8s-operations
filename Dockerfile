FROM python:3-slim AS build-env
RUN mkdir -p /app && mkdir -p /user/k8soper
ADD ./exportjson.py /app/exportjson.py
ADD ./dockerrun.sh /app/dockerrun.sh
ADD ./runhttp.py /app/runhttp.py
ADD ./execdockerrun.py /app/execdockerrun.py
RUN chmod +x /app/dockerrun.sh \
 && chmod +x /app/runhttp.py \
 && chmod +x /app/exportjson.py \
 && chmod +x /app/execdockerrun.py
RUN pip3 install --upgrade pip \
    && pip3 install schedule \
    && pip3 install kubernetes

FROM gcr.io/distroless/python3
COPY --from=build-env /user /user
COPY --from=build-env /app /usr/local/bin
COPY --from=build-env /usr/local/lib/python3.8/site-packages /usr/lib/python3.5/site-packages
ENV PYTHONPATH=/usr/lib/python3.5/site-packages
USER nonroot
WORKDIR /user/k8soper
EXPOSE 8080
CMD ["/usr/local/bin/execdockerrun.py"]
