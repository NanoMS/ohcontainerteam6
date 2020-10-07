#!/bin/bash

rg=cedaksrg
location=northeurope
aksname=cedaks
acrname=registryatk4536
yamlconf=config.$$.

echo Create rg $rg in $location
if [[ $(az group list -o table | egrep "^${rg}" | awk '{print $1}') != $rg ]]
then
	echo ResourceGroup $rg does not exist, creating it :
	az group create --name $rg --location $location
	echo ...
	echo DONE
else
	echo ResourceGroupe $rg exists in $location
	echo Deleting rg $rg
	az group delete --name $rg -y
	echo ResourceGroup $rg does not exist, creating it :
	az group create --name $rg --location $location
	echo ...
	echo DONE
fi

echo Checking registrations
if [ $(az provider show -n Microsoft.OperationalInsights -o json | jq -r ".registrationState") != "Registered" ]
then
	echo Service OperationalInsights is not Registered
	az provider register --namespace Microsoft.OperationalInsights
	echo ...
	echo DONE
else
	echo Service OperationalInsights is Registered
fi
if [ $(az provider show -n Microsoft.OperationsManagement -o json | jq -r ".registrationState") != "Registered" ]
then
	echo Service OperationsManagement is not Registered
	az provider register --namespace Microsoft.OperationsManagement 
	echo ...
	echo DONE
else
	echo Service OperationsManagement is Registered
fi

echo Checking aks
if [[ $(az aks list -o table | egrep "^${aksname}" | awk '{print $1}') != $aksname  ]]
then
	echo AKS $aksname does not exist, creating it now :
	az aks create --resource-group $rg --name $aksname --enable-addons monitoring --generate-ssh-keys --attach-acr $acrname
	echo ...
	echo DONE
else
	echo AKS $aksname exists
fi

echo STOP here
