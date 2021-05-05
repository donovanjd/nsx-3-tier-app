provider "nsxt" {
    host = var.nsx_mgr
    username = var.nsx_mgr_username
    password = var.nsx_mgr_password
    allow_unverified_ssl = true
  
}

data "nsxt_policy_edge_cluster" "edge_cluster" {
    display_name = var.nsx_edge_cluster
}

data "nsxt_policy_edge_node" "en1" {
    edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path
    member_index = 0
}

data "nsxt_policy_transport_zone" "overlay_tz" {
    display_name = var.nsx_overlay_tz
}

data "nsxt_policy_transport_zone" "tz_vlan_105" {
    display_name = var.tz_vlan_105
}

data "nsxt_policy_transport_zone" "tz_vlan_106" {
    display_name = var.tz_vlan_106
}

resource "nsxt_policy_segment" "logical-segments" {
    for_each = var.tier1_subnets
    display_name = each.key
    description = "Segment created using Terrform"
    transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
    connectivity_path = nsxt_policy_tier1_gateway.dev_tier1.path
    subnet {
        cidr = each.value
    }
}

resource "nsxt_policy_vlan_segment" "seg-vlan105-uplink1" {
    display_name = var.t0_uplink1_vlan_105
    vlan_ids = ["0"]
    description = "VLAN segment created using Terrform"
    transport_zone_path = data.nsxt_policy_transport_zone.tz_vlan_105.path  
}

resource "nsxt_policy_vlan_segment" "seg-vlan106-uplink1" {
    display_name = var.t0_uplink1_vlan_106
    vlan_ids = ["0"]
    description = "VLAN segment created using Terrform"
    transport_zone_path = data.nsxt_policy_transport_zone.tz_vlan_106.path  
}


resource "nsxt_policy_tier0_gateway" "Infra_Tier0" {
    display_name = "Infra_Tier0"
    description  = "Tier0 created using Terraform"
    failover_mode = "NON_PREEMPTIVE"
    ha_mode = "ACTIVE_ACTIVE"
    edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path 
    bgp_config {
      enabled = "true"
      local_as_num = "100"
    }
    redistribution_config {
      enabled = "true"
      rule {
       name = "infra_t0_rr"
       types = ["TIER1_CONNECTED","TIER1_SEGMENT"]
      }   
    }
}

resource "nsxt_policy_tier0_gateway_interface" "uplink1-vlan105" {
    display_name = "uplink1-vlan105"
    gateway_path = nsxt_policy_tier0_gateway.Infra_Tier0.path
    edge_node_path = data.nsxt_policy_edge_node.en1.path
    type = "EXTERNAL"
    segment_path = nsxt_policy_vlan_segment.seg-vlan105-uplink1.path
    subnets = var.t0_uplink_int_105_1   
}

resource "nsxt_policy_tier0_gateway_interface" "uplink1-vlan106" {
    display_name = "uplink1-vlan106"
    gateway_path = nsxt_policy_tier0_gateway.Infra_Tier0.path
    edge_node_path = data.nsxt_policy_edge_node.en1.path
    type = "EXTERNAL"
    segment_path = nsxt_policy_vlan_segment.seg-vlan106-uplink1.path
    subnets = var.t0_uplink_int_106_1    
}

resource "nsxt_policy_bgp_neighbor" "infra-t0-neigh-105-1" {
    display_name = "Infra-Tier-neighbors"
    description  = "Tier0 neighbours created using Terraform"
    bgp_path = nsxt_policy_tier0_gateway.Infra_Tier0.bgp_config[0].path
    neighbor_address = var.t0_105_bgp_neigh[0]
    remote_as_num = 250   

}

resource "nsxt_policy_bgp_neighbor" "infra-t0-neigh-106-1" {
    display_name = "Infra-Tier-neighbors"
    description  = "Tier0 neighbours created using Terraform"
    bgp_path = nsxt_policy_tier0_gateway.Infra_Tier0.bgp_config[0].path
    neighbor_address = var.t0_106_bgp_neigh[0]
    remote_as_num = 250   

}

resource "nsxt_policy_tier1_gateway" "dev_tier1" {
    description = "Dev Tier1 created using Terraform"
    display_name = "Dev_Tier1"
    edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path
    tier0_path = nsxt_policy_tier0_gateway.Infra_Tier0.path
    failover_mode = "PREEMPTIVE"
    route_advertisement_types = ["TIER1_CONNECTED"]
}
