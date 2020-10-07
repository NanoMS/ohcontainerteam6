#!/bin/bash

rg=cedaksrg
location=northeurope
aksname=cedaks
acrname=registryatk4536
yamlconf=config.$$.

echo Check if kubctl is installed ?
if [[ $(which kubectl) != "/usr/bin/kubectl" ]]
then
	echo Installing aks ?
	az aks install-cli
	echo ...
	echo DONE
else
	echo kubectl is installed in your path
fi

echo Checking credentials for kubectl / aks
az aks get-credentials --resource-group $rg --name $aksname --overwrite-existing

echo Test aks cluster with a get nodes
kubectl get nodes

echo STOP here
