AKS_ID=$(az aks show \
    --resource-group $RG_NAME \
    --name $CLUSTER_NAME \
    --query id -o tsv)

# Create the "aks-dashboard-admins" group. Sometime you need to wait for a few seconds for the new group to be fully available for the next steps
DASHBOARD_ADMINS_ID=$(az ad group create \
    --display-name AKS-Dashboard-Admins \
    --mail-nickname aks-dashboard-admins \
    --query objectId -o tsv)

# Create Azure role assignment for the group, this will allow members to access AKS via kubectl, dashboard
az role assignment create \
  --assignee $DASHBOARD_ADMINS_ID \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope $AKS_ID

# We will add the current logged in user to the dashboard admins group
# Get the UPN for a user in the same AAD directory
SIGNED_USER_UPN=$(az ad signed-in-user show --query userPrincipalName -o tsv)

# Use Object Id if the user is in external directory (like guest account on the directory)
SIGNED_USER_UPN=$(az ad signed-in-user show --query objectId -o tsv)

# Add the user to dashboard group
az ad group member add --group $DASHBOARD_ADMINS_ID --member-id $SIGNED_USER_UPN

# Create role and role binding for the new group (after replacing the AADGroupID)
wget https://raw.githubusercontent.com/mohamedsaif/AKS-Adv-Provision/master/provisioning/dashboard-proxy-binding.yaml
sed -i dashboard-proxy-binding.yaml -e "s/AADGroupID/$DASHBOARD_ADMINS_ID/g"
kubectl apply -f dashboard-proxy-binding.yaml

------DASHBOARD LOGIN
SIGNED_USER_TOKEN=$(az account get-access-token --query accessToken -o tsv)
echo $SIGNED_USER_TOKEN

# establish a tunnel and login via token above
# If AAD enabled, you should see the AAD sign in experience with a link and a code to https://microsoft.com/devicelogin
az aks browse --resource-group $RG_NAME --name $CLUSTER_NAME
az aks browse --resource-group rg-btcturk-azwe-prod-aks --name btcturk-k8s-cls
