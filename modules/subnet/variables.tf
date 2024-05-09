variable "vpc_id" {}
variable "common_tags" {}
variable "public_route_table_id" {}
variable "nat_gateway_id" {}

variable "public_subnets" {
  description = "A map containing private subnet configurations"
  type        = map(object({
    cidr_block : string
    az : string
  }))

  default = {
    public_1 = {
      cidr_block = "10.1.0.0/19"
      az         = "ap-northeast-1a"
    },
    public_2 = {
      cidr_block = "10.1.64.0/19"
      az         = "ap-northeast-1c"
    },
    public_3 = {
      cidr_block = "10.1.128.0/19"
      az         = "ap-northeast-1d"
    },
  }

}

variable "private_subnets" {
  description = "A map containing private subnet configurations"
  type        = map(object({
    cidr_block : string
    az : string
  }))

  default = {
    private_1 = {
      cidr_block = "10.1.32.0/19"
      az         = "ap-northeast-1a"
    },
    private_2 = {
      cidr_block = "10.1.96.0/19"
      az         = "ap-northeast-1c"
    },
    private_3 = {
      cidr_block = "10.1.160.0/19"
      az         = "ap-northeast-1d"
    },
  }
}
