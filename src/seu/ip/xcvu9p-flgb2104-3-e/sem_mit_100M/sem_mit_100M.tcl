#-------------------------------------------------------------------------------
#- Copyright (c) 2023 Arista Networks, Inc. All rights reserved.
#-------------------------------------------------------------------------------
#- Maintainers:
#-   fdk-support@arista.com
#-
#- Description:
#-   CREATE IP sem_mit_100M
#-
#- Tags:
#-   license-arista-fdk-agreement
#-   license-bsd-3-clause
#-
#-------------------------------------------------------------------------------

set sem_ultra sem_mit_100M
set_property target_language VHDL [current_project]
create_ip -name sem_ultra -vendor xilinx.com -library ip -module_name $sem_ultra -dir $ipcore_dir

set_property -dict {
  CONFIG.MODE {mitigation_only}
  CONFIG.CLOCK_PERIOD {10000}
} [get_ips $sem_ultra]

# Default Params
#  CONFIG.MODE {mitigation_only}
#  CONFIG.ENABLE_CLASSIFICATION {false}
#  CONFIG.LOCATE_CONFIG_PRIM {example_design}
#  CONFIG.Component_Name {sem_mit_100M}
#  CONFIG.CLK_INTF.INSERT_VIP {0}

