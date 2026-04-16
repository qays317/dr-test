vpc_config = {
    name = "WordPress-VPC"
    cidr_block = "172.16.0.0/16"    
}

route_table_config = {
    Public-RT = {
        routes = {
            default = {
                cidr_block = "0.0.0.0/0"
                gateway = true
            }
        }
        subnets_names = ["Pub-A", "Pub-B"]
    }
    Private-RT = {
        routes = {}
        subnets_names = ["Prv-A", "Prv-B"]
    }
}

