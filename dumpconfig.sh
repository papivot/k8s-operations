#!/bin/sh

collect_global_objects()
{
        WORKDIR=$1
        K8SOBJ=$2
        EXPORT=$3
        newdir=$WORKDIR/$K8SOBJ
        mkdir -p $newdir
        echo "=== Collecting $K8SOBJ information for the cluster === "
        objs=`kubectl get $K8SOBJ -o name`
        for obj in $objs
        do
#               echo $obj
                objname=`echo $obj|cut -d/ -f2`
                kubectl get $K8SOBJ $objname  --export=$EXPORT -o yaml > $newdir/$K8SOBJ-$objname.yaml
        done
}

collect_ns_objects()
{
        WORKDIR=$1
        K8SOBJ=$2
        EXPORT=$3
        newdir=$WORKDIR/$K8SOBJ
        mkdir -p $newdir
        echo "=== Collecting $K8SOBJ information for the cluster === "
        namespaces=`kubectl get namespace -o name`
        for ns in $namespaces
        do
#               echo $ns
                nsname=`echo $ns|cut -d/ -f2`
                mkdir -p $newdir/$nsname
                objs=`kubectl get $K8SOBJ -o name -n $nsname`
                for obj in $objs
                do
#                       echo $obj
                        objname=`echo $obj|cut -d/ -f2`
                        kubectl get $K8SOBJ $objname -n $nsname --export=$EXPORT -o yaml > $newdir/$nsname/$K8SOBJ-$objname.yaml
                done
        done
}

#CLUSTERNAME=`kubectl config current-context`
CLUSTERNAME=$CLUSTER_NAME
DATE=`date +%F`
WORKINGDIR=/var/lib/nginx/html/$CLUSTERNAME/
mkdir -p $WORKINGDIR
#kubectl config view -o yaml > $WORKINGDIR/kubectl-config.yaml

collect_global_objects $WORKINGDIR clusterrolebindings false
collect_global_objects $WORKINGDIR clusterroles false
collect_global_objects $WORKINGDIR customresourcedefinition true
collect_global_objects $WORKINGDIR namespaces true
collect_global_objects $WORKINGDIR nodes true
collect_global_objects $WORKINGDIR persistentvolumes true
collect_global_objects $WORKINGDIR configmaps true

collect_ns_objects $WORKINGDIR controllerrevisions true
collect_ns_objects $WORKINGDIR cronjobs true
collect_ns_objects $WORKINGDIR daemonsets true
collect_ns_objects $WORKINGDIR deployments true
collect_ns_objects $WORKINGDIR endpoints true
collect_ns_objects $WORKINGDIR horizontalpodautoscalers true
collect_ns_objects $WORKINGDIR ingresses true
collect_ns_objects $WORKINGDIR jobs true
collect_ns_objects $WORKINGDIR limitranges true
collect_ns_objects $WORKINGDIR networkpolicies true
collect_ns_objects $WORKINGDIR persistentvolumeclaims true
collect_ns_objects $WORKINGDIR pods true
collect_ns_objects $WORKINGDIR replicasets true
collect_ns_objects $WORKINGDIR replicationcontrollers true
collect_ns_objects $WORKINGDIR resourcequotas true
collect_ns_objects $WORKINGDIR rolebindings false
collect_ns_objects $WORKINGDIR roles false
#collect_ns_objects $WORKINGDIR secrets false
collect_ns_objects $WORKINGDIR serviceaccounts true
collect_ns_objects $WORKINGDIR services true
