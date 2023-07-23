## ---------------------------------------------------------------------------------------------------------------------
## REQUIRED PARAMETERS
## --------------------------------------------------------------------------------------------------------------------- 
variable "integration_name_suffix" {
  type = string
}

variable "management_group_name" {
  type = string
}

## ---------------------------------------------------------------------------------------------------------------------
## OPTIONAL PARAMETERS
## ---------------------------------------------------------------------------------------------------------------------
variable "replicator_enabled" {
  type    = bool
  default = true
}

variable "replicator_arg_enabled" {
  type    = bool
  default = false
}

variable "metering_enabled" {
  type    = bool
  default = true
}

variable "additional_required_resource_accesses" {
  type = list(object({
    resource_app_id = string, resource_accesses = list(object({ id = string, type = string }))
  }))
  default = []
}

variable "additional_permissions" {
  type    = list(string)
  default = []
}