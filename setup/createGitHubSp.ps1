# https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Cwindows

$app=$(az ad app create --display-name wviriya-iac-demo-nonprod | ConvertFrom-Json)
$sp=$(az ad sp create --id $app.appId | ConvertFrom-Json)
az group create -n iac-demo-nonprod-rg -l australiaeast
az role assignment create --role contributor --subscription $subscriptionId --assignee-object-id $sp.id --assignee-principal-type ServicePrincipal --scope /subscriptions/$subscriptionId/resourceGroups/iac-demo-nonprod-rg


$app=$(az ad app create --display-name wviriya-iac-demo-prod | ConvertFrom-Json)
$sp=$(az ad sp create --id $app.appId | ConvertFrom-Json)
az group create -n iac-demo-prod-rg -l australiaeast
az role assignment create --role contributor --subscription $subscriptionId --assignee-object-id $sp.id --assignee-principal-type ServicePrincipal --scope /subscriptions/$subscriptionId/resourceGroups/iac-demo-prod-rg