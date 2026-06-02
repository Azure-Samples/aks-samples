@description('The location of the managed userNode resource.')
param location string = resourceGroup().location

@description('The name of the virtual network.')
param vnetName string = 'aksAutomaticVnet'

@description('The address prefix of the virtual network.')
param addressPrefix string = '172.19.0.0/16'

@description('The name of the API server subnet.')
param apiServerSubnetName string = 'apiServerSubnet'

@description('The subnet prefix of the API server subnet.')
param apiServerSubnetPrefix string = '172.19.0.0/28'

@description('The name of the user node subnet.')
param userNodeSubnetName string = 'userNodeSubnet'

@description('The subnet prefix of the user node subnet.')
param userNodeSubnetPrefix string = '172.19.1.0/24'

@description('The name of the system node subnet.')
param systemNodeSubnetName string = 'systemNodeSubnet'

@description('The subnet prefix of the system node subnet.')
param systemNodeSubnetPrefix string = '172.19.0.64/26'

// Virtual network with an API server subnet and a userNode subnet
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
    name: vnetName
    location: location
    properties: {
        addressSpace: {
            addressPrefixes: [ addressPrefix ]
        }
        subnets: [
            {
                name: apiServerSubnetName
                properties: {
                    addressPrefix: apiServerSubnetPrefix
                }
            }
            {
                name: userNodeSubnetName
                properties: {
                    addressPrefix: userNodeSubnetPrefix
                }
            }
            {
                name: systemNodeSubnetName
                properties: {
                    addressPrefix: systemNodeSubnetPrefix
                }
            }
        ]
    }
}

output apiServerSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, apiServerSubnetName)
output userNodeSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, userNodeSubnetName)
output systemNodeSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, systemNodeSubnetName)
