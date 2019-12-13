#!/usr/bin/python3
from kubernetes import client, config
import os, json, datetime, schedule, time, subprocess

def job():
    print("Job started at: ",datetime.datetime.now())

    outputjson = {}
    outputjson['items'] = []
    clustername = os.environ['CLUSTER_NAME']
    mypodname = os.environ['HOSTNAME']

    #config.load_kube_config()
    config.load_incluster_config()

    v1 = client.CoreV1Api()
    ret = v1.list_pod_for_all_namespaces(watch=False)
    for pod in ret.items:
        namespace = pod.metadata.namespace
        podname = pod.metadata.name
        host_ip = pod.status.host_ip
        pod_ip = pod.status.pod_ip
        containers = pod.spec.containers
        for container in containers:
            name = container.name 
            image = container.image 
            outputjson['items'].append({
                'clustername': clustername,
                'execpodname': mypodname,
                'namespace': namespace,
                'pod': podname,
                'host_ip': host_ip,
                'pod_ip': pod_ip,
                'containername': name,
                'image': image
                #'SHA256': shaid
            })
    with open("/user/k8soper/itam.txt","w") as outfile:
        json.dump(outputjson, outfile, indent=4)
    outfile.close()
    print("Job finished at: ",datetime.datetime.now())

schedule.every(3).minutes.do(job)

while True:
   schedule.run_pending()
   time.sleep(1)
