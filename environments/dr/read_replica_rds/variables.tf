variable "rds_identifier" {
  type = string
}

variable "rds_replica_identifier" {
  type = string
}

variable "security_group" {
    type = map(object({
        ingress = optional (map(object({
            from_port = number
            to_port = number
            ip_protocol = string
            cidr_block = optional(string)
            vpc_cidr = optional(bool)
            source_security_group_name = optional(string)
            prefix_list_ids = optional (list(string))
        })))
        egress = optional(map(object({
            from_port = number
            to_port = number
            ip_protocol = string
            cidr_block = optional(string)
            vpc_cidr = optional(bool)
            source_security_group_name = optional(string)
            prefix_list_ids = optional (list(string))
        })))
        tags = optional(map(string))
    }))  
}
