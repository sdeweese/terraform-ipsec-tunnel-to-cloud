# AWS Variables

variable aws_vpc {
    type = string
    default = "vpc-id"
    description = "Virtual Private Cloud instance that is already created in AWS"
} 

variable aws_route {
    type = string
    default = "route-id"
    description = "Route ID that is already created in AWS"
} 

variable customer_gw {
    type = string
    default = "10.1.1.1"
    description = "New and unused IP address within the VPC CIDR block"
} 

variable tunnel1_inside_cidr {
    type = string
    default = "1.1.1.0/24"
    description = "This is the CIDR that will be used for Tunnel1"
} 

variable tunnel2_inside_cidr {
    type = string
    default = "2.2.2.0/24"
    description = "This is the CIDR that will be used for Tunnel2"
} 

variable tunnel1_preshared_key {
    type = string
    default = "verySecureTunnel1SharedKey"
    description = "This is the key that will be used for Tunnel1 by both AWS and the 9300X"
} 

variable tunnel2_preshared_key {
    type = string
    default = "verySecureTunnel2SharedKey"
    description = "This is the key that will be used for Tunnel2 by both AWS and the 9300X"
} 

variable destination_cidr_block {
    type = string
    default = "192.1.1.0/24"
    description = "This is the key that will be used for Tunnel2 by both AWS and the 9300X"
} 

# 9300X Varaibles
# device variables
variable "host_url" {
  description = "Device host path starting with 'https://'"
  type        = string
  sensitive   = true
}

variable "host_ip" {
  description = "Device host IP address"
  type        = string
  sensitive   = true
}

variable "insecure" {
  description = "Device insecure mode boolean"
  type        = string
  sensitive   = true
}

variable "device_username" {
  description = "Device username"
  type        = string
  sensitive   = true
}

variable "device_password" {
  description = "Device password"
  type        = string
  sensitive   = true
}

# crypto variables
variable "crypto_name" {
  description = "Crypto name"
  type        = string
  sensitive   = true
}

variable "tunnel1id" {
  description = "Tunnel1 Name (ID)"
  default     = "2"
  type        = string
  sensitive   = true
}

variable "psk" {
  description = "Pre-shared key"
  type        = string
  sensitive   = true
}

variable "external_subnet" {
  description = "external subnet of tunnel"
  type        = string
  sensitive   = true
}

variable "internal_ip" {
  description = "internal IP address of tunnel"
  type        = string
  sensitive   = true
}

variable "internal_subnet" {
  description = "internal subnet of tunnel"
  type        = string
  sensitive   = true
}

# Variables for second Tunnel
# crypto variables
variable "crypto_name2" {
  description = "Crypto name2"
  type        = string
  sensitive   = true
}

variable "tunnel2id" {
  description = "Tunnel2 Name (ID)"
  default     = "2"
  type        = string
  sensitive   = true
}


variable "psk2" {
  description = "Pre-shared key of tunnel2"
  type        = string
  sensitive   = true
}

variable "external_subnet2" {
  description = "external subnet of tunnel2"
  type        = string
  sensitive   = true
}

variable "internal_ip2" {
  description = "internal IP address of tunnel2"
  type        = string
  sensitive   = true
}

variable "internal_subnet2" {
  description = "internal subnet of tunnel2"
  type        = string
  sensitive   = true
}

# Static Routes
variable "default_gateway" {
  description = "Default Gateway used by 9300X"
  type        = string
  sensitive   = true
  default = "8.8.8.8"
}

variable "default_gateway_netmask" {
  description = "Default Gateway Subnet Mask used by 9300X"
  type        = string
  sensitive   = true
  default = "255.255.255.0"
}
