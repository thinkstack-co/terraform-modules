locals {
  # VM sizes that support accelerated networking
  # This list includes common VM sizes that support accelerated networking
  # Reference: https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli
  accelerated_networking_supported_sizes = [
    # D-series v3
    "Standard_D2s_v3", "Standard_D4s_v3", "Standard_D8s_v3", "Standard_D16s_v3", "Standard_D32s_v3", "Standard_D48s_v3", "Standard_D64s_v3",
    "Standard_D2_v3", "Standard_D4_v3", "Standard_D8_v3", "Standard_D16_v3", "Standard_D32_v3", "Standard_D48_v3", "Standard_D64_v3",
    # D-series v4
    "Standard_D2s_v4", "Standard_D4s_v4", "Standard_D8s_v4", "Standard_D16s_v4", "Standard_D32s_v4", "Standard_D48s_v4", "Standard_D64s_v4",
    "Standard_D2_v4", "Standard_D4_v4", "Standard_D8_v4", "Standard_D16_v4", "Standard_D32_v4", "Standard_D48_v4", "Standard_D64_v4",
    # D-series v5
    "Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5", "Standard_D16s_v5", "Standard_D32s_v5", "Standard_D48s_v5", "Standard_D64s_v5", "Standard_D96s_v5",
    "Standard_D2_v5", "Standard_D4_v5", "Standard_D8_v5", "Standard_D16_v5", "Standard_D32_v5", "Standard_D48_v5", "Standard_D64_v5", "Standard_D96_v5",
    # E-series v3
    "Standard_E2s_v3", "Standard_E4s_v3", "Standard_E8s_v3", "Standard_E16s_v3", "Standard_E32s_v3", "Standard_E48s_v3", "Standard_E64s_v3",
    "Standard_E2_v3", "Standard_E4_v3", "Standard_E8_v3", "Standard_E16_v3", "Standard_E32_v3", "Standard_E48_v3", "Standard_E64_v3",
    # E-series v4
    "Standard_E2s_v4", "Standard_E4s_v4", "Standard_E8s_v4", "Standard_E16s_v4", "Standard_E32s_v4", "Standard_E48s_v4", "Standard_E64s_v4",
    "Standard_E2_v4", "Standard_E4_v4", "Standard_E8_v4", "Standard_E16_v4", "Standard_E32_v4", "Standard_E48_v4", "Standard_E64_v4",
    # E-series v5
    "Standard_E2s_v5", "Standard_E4s_v5", "Standard_E8s_v5", "Standard_E16s_v5", "Standard_E32s_v5", "Standard_E48s_v5", "Standard_E64s_v5", "Standard_E96s_v5",
    "Standard_E2_v5", "Standard_E4_v5", "Standard_E8_v5", "Standard_E16_v5", "Standard_E32_v5", "Standard_E48_v5", "Standard_E64_v5", "Standard_E96_v5",
    # F-series v2
    "Standard_F2s_v2", "Standard_F4s_v2", "Standard_F8s_v2", "Standard_F16s_v2", "Standard_F32s_v2", "Standard_F48s_v2", "Standard_F64s_v2", "Standard_F72s_v2",
    # M-series
    "Standard_M8ms", "Standard_M16ms", "Standard_M32ms", "Standard_M64ms", "Standard_M128ms",
    "Standard_M32ls", "Standard_M64ls", "Standard_M64s", "Standard_M128s",
    # NC-series v3
    "Standard_NC6s_v3", "Standard_NC12s_v3", "Standard_NC24s_v3",
    # ND-series
    "Standard_ND6s", "Standard_ND12s", "Standard_ND24s",
    # NV-series v3
    "Standard_NV12s_v3", "Standard_NV24s_v3", "Standard_NV48s_v3"
  ]

  # VM sizes that support Premium storage
  # These VM sizes can use Premium_LRS disks
  premium_storage_supported_sizes = [
    # All s-series VMs support premium storage
    # D-series
    "Standard_D2s_v3", "Standard_D4s_v3", "Standard_D8s_v3", "Standard_D16s_v3", "Standard_D32s_v3", "Standard_D48s_v3", "Standard_D64s_v3",
    "Standard_D2s_v4", "Standard_D4s_v4", "Standard_D8s_v4", "Standard_D16s_v4", "Standard_D32s_v4", "Standard_D48s_v4", "Standard_D64s_v4",
    "Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5", "Standard_D16s_v5", "Standard_D32s_v5", "Standard_D48s_v5", "Standard_D64s_v5", "Standard_D96s_v5",
    # E-series
    "Standard_E2s_v3", "Standard_E4s_v3", "Standard_E8s_v3", "Standard_E16s_v3", "Standard_E32s_v3", "Standard_E48s_v3", "Standard_E64s_v3",
    "Standard_E2s_v4", "Standard_E4s_v4", "Standard_E8s_v4", "Standard_E16s_v4", "Standard_E32s_v4", "Standard_E48s_v4", "Standard_E64s_v4",
    "Standard_E2s_v5", "Standard_E4s_v5", "Standard_E8s_v5", "Standard_E16s_v5", "Standard_E32s_v5", "Standard_E48s_v5", "Standard_E64s_v5", "Standard_E96s_v5",
    # F-series
    "Standard_F2s_v2", "Standard_F4s_v2", "Standard_F8s_v2", "Standard_F16s_v2", "Standard_F32s_v2", "Standard_F48s_v2", "Standard_F64s_v2", "Standard_F72s_v2",
    # M-series
    "Standard_M8ms", "Standard_M16ms", "Standard_M32ms", "Standard_M64ms", "Standard_M128ms",
    "Standard_M32ls", "Standard_M64ls", "Standard_M64s", "Standard_M128s",
    # B-series (burstable)
    "Standard_B2s", "Standard_B2ms", "Standard_B4ms", "Standard_B8ms", "Standard_B12ms", "Standard_B16ms", "Standard_B20ms"
  ]

  # Validation helpers
  supports_accelerated_networking = contains(local.accelerated_networking_supported_sizes, var.vm_size)
  supports_premium_storage        = contains(local.premium_storage_supported_sizes, var.vm_size)

  # Warning messages for configuration validation
  accelerated_networking_warning = var.enable_accelerated_networking && !local.supports_accelerated_networking ? "WARNING: VM size ${var.vm_size} does not support accelerated networking" : ""
  premium_storage_warning        = var.os_disk_storage_account_type == "Premium_LRS" && !local.supports_premium_storage ? "WARNING: VM size ${var.vm_size} does not support Premium storage" : ""
}
