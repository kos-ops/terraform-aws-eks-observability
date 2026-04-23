variable "role_name" {
  description = "The name of the IAM role."
  type        = string
  default     = null
}

variable "role_description" {
  description = "A description for the IAM role."
  type        = string
  default     = null
}

variable "services_to_assume_role" {
  description = "A list of service principal identifiers that are allowed to assume the IAM role."
  type        = list(string)
  default     = []
}

variable "create_role_policy" {
  description = "Flag to indicate whether to create the IAM role policy."
  type        = bool
  default     = false
}

variable "role_policy" {
  description = "The IAM role policy document in JSON format."
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "The ARNs of the existing Managed IAM policies to attach to the execution role."
  type        = list(string)
  default     = []
}

variable "external_assume_role_policy" {
  description = "Custom JSON encoded assume role policy document."
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "The maximum session duration (in seconds) for the IAM role."
  type        = number
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}
