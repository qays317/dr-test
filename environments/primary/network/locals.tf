locals {
    
    vpc_endpoints_config = {
        "secretsmanager" = {
            type = "Interface"
            security_group_id = module.sg.secretsmanager_endpoint_sg_id
        }
        "logs" = {
            type = "Interface"
            security_group_id = module.sg.vpc_endpoints_sg_id
        }
        "s3" = {
            type = "Gateway"
        } 
        "ecs" = {
            type = "Interface"
            security_group_id = module.sg.vpc_endpoints_sg_id
        }
        "sts" = {
            type = "Interface"
            security_group_id = module.sg.vpc_endpoints_sg_id
        } 
        "monitoring" = {
            type = "Interface"
            security_group_id = module.sg.vpc_endpoints_sg_id
        }
        "ecr.api" = {
            type = "Interface"
            security_group_id = module.sg.vpc_endpoints_sg_id
        }
        "ecr.dkr" = {
            type = "Interface"
            security_group_id = module.sg.vpc_endpoints_sg_id
        }
        "ssmmessages" = {
            type = "Interface"
            security_group_id = module.sg.vpc_endpoints_sg_id
        }
        "ssm" = {
            type = "Interface"
            security_group_id = module.sg.vpc_endpoints_sg_id
        }
        "ec2messages" = {
            type = "Interface"
            security_group_id = module.sg.vpc_endpoints_sg_id
        }
}  
}
