#!/usr/bin/python3
import json
import os
import subprocess
import schedule
import time
import datetime

def job():
    print("job started at: ",datetime.datetime.now())

    nsarray = []
    outputjson = {}
    outputjson['items'] = []
    clustername = os.environ['CLUSTER_NAME']
    mypodname = os.environ['HOSTNAME']

    json_file1 = subprocess.check_output(["/usr/local/bin/kubectl","get","namespaces","-o","json"])
    json_file2 = subprocess.check_output(["/usr/local/bin/kubectl","get","pods","--all-namespaces","-o","json"])

    nsdata = json.loads(json_file1)
    nss = nsdata["items"]
    for ns in nss:
            nsmetadata = ns["metadata"]
            nsname = nsmetadata["name"]
            nsarray.append([nsname])

    data = json.loads(json_file2)
    pods = data["items"]
    for pod in pods:
            metadata = pod["metadata"]
            spec = pod["spec"]
            status = pod["status"]
            try:
                containerstatuses = status["containerStatuses"]
            except KeyError:
                containerstatuses = 0
            podname = metadata["name"]
            podnamespace = metadata["namespace"]

            for nsinfo in nsarray:
                if nsinfo[0] == podnamespace:
                    namespace = nsinfo[0]
                    break

            containers = spec["containers"]
            for container in containers:
                name = container["name"]
                image = container["image"]
                resources = container["resources"]
                try:
                    limits = resources["limits"]
                except KeyError:
                    limits = 0
                try:    
                    requests = resources["requests"]
                except KeyError:
                    requests = 0

                if limits == 0:
                    cpulimits = 0
                    memlimits = 0
                else:
                    try:
                        cpulimits = limits["cpu"]
                    except KeyError:
                        cpulimits = 0
                    try:
                        memlimits = limits["memory"]
                    except KeyError:
                        memlimits = 0
                
                if requests == 0:
                    cpurequest = 0
                    memrequest = 0
                else:
                    try:
                        cpurequest = requests["cpu"]
                    except KeyError:
                        cpurequest = 0
                    try:
                        memrequest = requests["memory"]
                    except KeyError:
                        memrequest = 0

                if containerstatuses == 0:
                    shaid = "NULL"
                else:
                    advstat = next(containerstatus for containerstatus in containerstatuses if containerstatus["name"] == name)
                    imageid = advstat["imageID"]
                    shaids = imageid.split("@")
                    try:
                        shaid = shaids[1]
                    except:
                        shaid = "NULL"

                print(namespace,podname,name,image,shaid,cpulimits,memlimits,cpurequest,memrequest)
                outputjson['items'].append({
                    'clustername': clustername,
                    'execpodname': mypodname,
                    'namespace': namespace,
                    'pod': podname,
                    'containername': name,
                    'image': image,
                    'SHA256': shaid
                })

    with open("/user/k8soper/itam.txt","w") as outfile:
        json.dump(outputjson, outfile, indent=4)
    outfile.close()

schedule.every(3).minutes.do(job)

while True:
   schedule.run_pending()
   time.sleep(1)
