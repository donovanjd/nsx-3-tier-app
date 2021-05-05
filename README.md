# Terraform code to deploy NSX logical topology for a 3 Tier app

Deploys 3 logical segments
Deploys a Tier1 gateway connected to these segments 
Deploys Tier0 gateway connected to the Tier1 gateway and establishes BGP peering with the upstream router/switch
