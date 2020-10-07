#!/bin/bash

rg=teamResources
aksname=team6akscluster
kvname=kv-ohteam6
subid=949447fd-874d-4802-8a3e-129cab71c209

SP_ID=$(az aks show --resource-group $rg --name $aksname \
	    --query servicePrincipalProfile.clientId -o tsv)

echo App ID 		: $SP_ID
echo Expiration Date	: $(az ad sp credential list --id $SP_ID --query "[].endDate" -o tsv)

SP_SECRET=$(az ad sp credential reset --name $SP_ID --query password -o tsv)

echo Secret - true one	: $SP_SECRET
echo storing secret in the keyvault so we do not lose it again
az keyvault secret set --vault-name $kvname --name "spnsecret" --value ${SP_SECRET}
az keyvault secret set --vault-name $kvname --name "spnappid" --value ${SP_ID}

echo Create role assignments :
az role assignment create --role Reader --assignee $SP_ID --scope /subscriptions/$subid/resourcegroups/$rg/providers/Microsoft.KeyVault/vaults/$kvname

echo Set policy :
az keyvault set-policy -n $kvname --secret-permissions get --spn $SP_ID

echo create secret kubectl
kubectl create secret generic secrets-store-creds --from-literal clientid=$SP_ID --from-literal clientsecret=$SP_SECRET

echo Updating credentials :
az aks update-credentials --resource-group $rg --name $aksname --reset-service-principal --service-principal $SP_ID --client-secret $SP_SECRET
echo az aks update-credentials --resource-group $rg --name $aksname --reset-service-principal --service-principal $SP_ID --client-secret $SP_SECRET
