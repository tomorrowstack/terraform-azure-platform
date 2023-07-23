## ---------------------------------------------------------------------------------------------------------------------
## REQUIRED PARAMETERS
## ---------------------------------------------------------------------------------------------------------------------
variable "integration_name_suffix" {
  type = string
}

variable "scope" {
  type = string
}

## ---------------------------------------------------------------------------------------------------------------------
## OPTIONAL PARAMETERS
## ---------------------------------------------------------------------------------------------------------------------
variable "additional_required_resource_accesses" {
  type    = list(object({ resource_app_id = string, resource_accesses = list(object({ id = string, type = string })) }))
  default = []
}

variable "additional_permissions" {
  type    = list(string)
  default = []
}

variable "replicator_arg_enabled" {
  type    = bool
  default = false
}