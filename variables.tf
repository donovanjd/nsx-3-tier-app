variable "nsx_mgr" {  
}
variable "nsx_mgr_username" {  
}
variable "nsx_mgr_password" {  
}
variable "nsx_edge_cluster" {  
}
variable "nsx_overlay_tz" {
}
variable "tz_vlan_105" {
}
variable "tz_vlan_106" {
}
variable "t0_uplink1_vlan_105" {
}
variable "t0_uplink1_vlan_106" {
}
variable "tier1_subnets" {
    default = {
    web = "172.16.210.1/24"
    app = "172.16.211.1/24"
    db  = "172.16.212.1/24"
    }
}  
variable "t0_uplink_int_105_1" {
}
variable "t0_uplink_int_106_1" {
}
variable "t0_uplink_int_105_2" {
}
variable "t0_uplink_int_106_2" {
}
variable "t0_105_bgp_neigh" {
}
variable "t0_106_bgp_neigh" {
}