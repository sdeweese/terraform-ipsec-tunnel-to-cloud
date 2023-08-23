# What you need to do to run this file
# 1. Install Terraform and modify variables in aws.tfvars
# 2. Run these commands:
#   teraform init
#   terraform plan -var-file="aws.tfvars"
#   terraform apply -var-file="aws.tfvars" -auto-approve
# 3. Validate that the IPsec tunnels are up and running
# 4. To remove the config from AWS, run the following command
#    terraform destroy -var-file="aws.tfvars" -auto-approve


# Generate and Apply the 9300X config
#   a. Crypto for Tunnel1
#   b. Tunnel1 (tunnel destinations will be the ones generated in aws.tf step 2b)
#   c. Crypto for Tunnel2
#   d. Tunnel2 (tunnel destinations will be the ones generated in aws.tf step 2b)
#   e. Add static routes for 9300X to reach AWS tunnels and for traffic from AWS tunnel to reach 9300X

terraform {
  required_providers {
    iosxe = {
      source  = "CiscoDevNet/iosxe"
      version = "0.1.1" # phase 2
    }
  }
}

provider "iosxe" { # variables initialized in variables.tf and values stored in 9300X.tfvars
  host            = var.host_url
  insecure        = var.insecure
  device_username = var.device_username
  device_password = var.device_password
}


# a. Add Crypto Config to Cisco IOS XE Device for Tunnel 1
resource "iosxe_rest" "crypto_example_post" {
  depends_on = [ aws_vpn_connection.main ]
  method = "PATCH"
  path = "/data/Cisco-IOS-XE-native:native/crypto"
  payload = jsonencode(

{
    "Cisco-IOS-XE-native:crypto": {
       "Cisco-IOS-XE-crypto:ikev2": {
          "keyring": [
            {
              "name": var.crypto_name,
              "peer": [
                {
                  "name": var.crypto_name,
                  "address": {
                    "ipv4": {
                      "ipv4-address": "0.0.0.0",
                      "ipv4-mask": "0.0.0.0"
                    }
                  },
                  "pre-shared-key": {
                    "key": var.psk
                  }
                }
              ]
            }
          ],
          "policy": [
            {
              "name": var.crypto_name,
              "match": {
                "fvrf": {
                  "any": [null]
                }
              },
              "proposal": [
                {
                  "proposals": var.crypto_name
                }
              ]
            }
          ],
          "profile": [
            {
              "name": var.crypto_name,
              "authentication": {
                "local": {
                  "pre-share": {
                  }
                },
                "remote": {
                  "pre-share": {
                  }
                }
              },
              "config-exchange": {
                "request-1": false
              },
              "dpd": {
                "interval": 10,
                "retry": 2,
                "query": "periodic"
              },
              "identity": {
                "local": {
                  "address": var.host_ip
                }
              },
              "keyring": {
                "local": {
                  "name": var.crypto_name
                }
              },
              "match": {
                "identity": {
                  "remote": {
                    "address": {
                      "ipv4": [
                        {
                          "ipv4-address": aws_vpn_connection.main.tunnel1_address,
                          "ipv4-mask": var.external_subnet
                        }
                      ]
                    }
                  }
                }
              }
            }
          ],
          "proposal": [
            {
              "name": var.crypto_name,
              "encryption": {
                "aes-cbc-256": [null]
              },
              "group": {
                "fourteen": [null],
                "nineteen": [null],
                "twenty": [null]
              },
              "integrity": {
                "sha1": [null]
              }
            }
          ]
        },
        "Cisco-IOS-XE-crypto:ipsec": {
          "transform-set": [
            {
              "tag": var.crypto_name,
              "esp": "esp-aes",
              "esp-hmac": "esp-sha-hmac",
              "mode": {
                "tunnel-choice": [null]
              }
            }
          ],
          "profile": [
            {
              "name": var.crypto_name,
              "set": {
                "ikev2-profile": var.crypto_name,
                "transform-set": [var.crypto_name]
              }
            }
          ]
        }
    }
}
  )
}

# b. Add Tunnel  Config to Cisco IOS XE Device - update to create 2 tunnels based on what AWS provides us
resource "iosxe_rest" "tunnel_example_post" {
  depends_on = [ aws_vpn_connection.main, aws_vpn_gateway_attachment.vpn_attachment ]
  method = "POST"
  path = "/data/Cisco-IOS-XE-native:native/interface"
  payload = jsonencode(
    {
    "Cisco-IOS-XE-native:Tunnel": {
    "name": var.tunnel1id
    "description": "Terraform Tunnel to AWS Transit Gateway",
    "ip": {
      "address": {
        "primary": {
          "address": var.internal_ip,    
          "mask": var.internal_subnet   
        }
      }
    },
    "Cisco-IOS-XE-tunnel:tunnel": {
      "source": "Vlan2", # can be a var
      "destination-config": {
        "ipv4": aws_vpn_connection.main.tunnel1_address        
      },
      "mode": {
        "ipsec": {
          "ipv4": {
          }
        }
      },
      "protection": {
        "Cisco-IOS-XE-crypto:ipsec": {
          "profile-option": {
            "name": var.crypto_name
          }
        }
      }
    }
  }
    }
  )
}


# c. Add Crypto Config to Cisco IOS XE Device
resource "iosxe_rest" "crypto_example_post2" {
  depends_on = [ aws_vpn_connection.main, aws_vpn_gateway_attachment.vpn_attachment ]
  method = "PATCH"
  path = "/data/Cisco-IOS-XE-native:native/crypto"
  payload = jsonencode(

{
    "Cisco-IOS-XE-native:crypto": {
       "Cisco-IOS-XE-crypto:ikev2": {
          "keyring": [
            {
              "name": var.crypto_name2,
              "peer": [
                {
                  "name": var.crypto_name2,
                  "address": {
                    "ipv4": {
                      "ipv4-address": "0.0.0.0",
                      "ipv4-mask": "0.0.0.0"
                    }
                  },
                  "pre-shared-key": {
                    "key": var.psk2
                  }
                }
              ]
            }
          ],
          "policy": [
            {
              "name": var.crypto_name2,
              "match": {
                "fvrf": {
                  "any": [null]
                }
              },
              "proposal": [
                {
                  "proposals": var.crypto_name2
                }
              ]
            }
          ],
          "profile": [
            {
              "name": var.crypto_name2,
              "authentication": {
                "local": {
                  "pre-share": {
                  }
                },
                "remote": {
                  "pre-share": {
                  }
                }
              },
              "config-exchange": {
                "request-1": false
              },
              "dpd": {
                "interval": 10,
                "retry": 2,
                "query": "periodic"
              },
              "identity": {
                "local": {
                  "address": var.host_ip
                }
              },
              "keyring": {
                "local": {
                  "name": var.crypto_name2
                }
              },
              "match": {
                "identity": {
                  "remote": {
                    "address": {
                      "ipv4": [
                        {
                          "ipv4-address": aws_vpn_connection.main.tunnel2_address,
                          "ipv4-mask": var.external_subnet2
                        }
                      ]
                    }
                  }
                }
              }
            }
          ],
          "proposal": [
            {
              "name": var.crypto_name2,
              "encryption": {
                "aes-cbc-256": [null]
              },
              "group": {
                "fourteen": [null],
                "nineteen": [null],
                "twenty": [null]
              },
              "integrity": {
                "sha1": [null]
              }
            }
          ]
        },
        "Cisco-IOS-XE-crypto:ipsec": {
          "transform-set": [
            {
              "tag": var.crypto_name2,
              "esp": "esp-aes",
              "esp-hmac": "esp-sha-hmac",
              "mode": {
                "tunnel-choice": [null]
              }
            }
          ],
          "profile": [
            {
              "name": var.crypto_name2,
              "set": {
                "ikev2-profile": var.crypto_name2,
                "transform-set": [var.crypto_name2]
              }
            }
          ]
        }
    }
}
  )
}

# d. Add Tunnel  Config to Cisco IOS XE Device - update to create 2 tunnels based on what AWS provides us
resource "iosxe_rest" "tunnel_example_post2" {
  depends_on = [ aws_vpn_connection.main ]
  method = "POST"
  path = "/data/Cisco-IOS-XE-native:native/interface"
  payload = jsonencode(
    {
    "Cisco-IOS-XE-native:Tunnel": {
    "name": var.tunnel2id #306
    "description": "Terraform Tunnel to AWS Transit Gateway",
    "ip": {
      "address": {
        "primary": {
          "address": var.internal_ip2,    
          "mask": var.internal_subnet2   
        }
      }
    },
    "Cisco-IOS-XE-tunnel:tunnel": {
      "source": "Vlan2", # can be a var
      "destination-config": {
        "ipv4": aws_vpn_connection.main.tunnel2_address        
      },
      "mode": {
        "ipsec": {
          "ipv4": {
          }
        }
      },
      "protection": {
        "Cisco-IOS-XE-crypto:ipsec": {
          "profile-option": {
            "name": var.crypto_name2
          }
        }
      }
    }
  }
    }
  )
}

# Get VPC CIDR blocks and masks
data "aws_vpc" "selected" {
  id = var.aws_vpc
}

# Add Static Routes 
resource "iosxe_rest" "static_routes" {
  depends_on = [ aws_vpn_connection.main, iosxe_rest.crypto_example_post, iosxe_rest.crypto_example_post2, iosxe_rest.tunnel_example_post, iosxe_rest.tunnel_example_post2 ]
  method = "PATCH"
  path = "/data/Cisco-IOS-XE-native:native/ip/route/ip-route-interface-forwarding-list"
  payload = jsonencode(
    {
      "Cisco-IOS-XE-native:ip-route-interface-forwarding-list": [
        {
          "prefix": aws_vpn_connection.main.tunnel1_address
          "mask": var.default_gateway_netmask
          "fwd-list": [
            {
              "fwd": var.default_gateway
            }
          ]
        },
        {
          "prefix": aws_vpn_connection.main.tunnel2_address
          "mask": var.default_gateway_netmask
          "fwd-list": [
            {
              "fwd": var.default_gateway
            }
          ]
        },
        {
          "prefix": split("/", data.aws_vpc.selected.cidr_block)[0]
          "mask": cidrnetmask(data.aws_vpc.selected.cidr_block) 
          "fwd-list": [
            {
              "fwd": "Tunnel${var.tunnel1id}"
            }
          ]
        },
        {
          "prefix": split("/", data.aws_vpc.selected.cidr_block)[0] # "172.31.0.0",
          "mask": cidrnetmask(data.aws_vpc.selected.cidr_block)
          "fwd-list": [
            {
              "fwd": "Tunnel${var.tunnel2id}"
            }
          ]
        },
      ]
    }
  )
}
