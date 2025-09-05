provider "aws" {
    region   = var.region
    profile  = "ishan"
}
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0.0" 
    }
  }
}
# create vpc

module "vpc" {

    source                              = "../modules/vpc"
    region                              = var.region
    project_name                        = var.project_name
    environment                         = var.environment
    vpc_cidr                            = var.vpc_cidr
    public_subnet_cidr                  = var.public_subnet_cidr
    private1_subnet_cidr                = var.private1_subnet_cidr
    private2_subnet_cidr                = var.private2_subnet_cidr
    nat_ami_id                          = var.nat_ami_id
    key_name                            = var.key_name
    ansible_ami_id                      = var.ansible_ami_id
    app_ami_id                          = var.app_ami_id
    s3_bucket_arn                       = module.s3.static_bucket_arn
    app_secret_arn                          = module.secret-manager.app_secret_arn
    
  
}

module "rds" {

    source                              = "../modules/rds"
    region                              = var.region
    project_name                        = var.project_name
    environment                         = var.environment
    vpc_cidr                            = var.vpc_cidr
    private_subnet_ids                  = module.vpc.private_subnet_ids
    vpc_id                              = module.vpc.vpc_id
    db_allocated_storage                = var.db_allocated_storage
    db_instance_class                   = var.db_instance_class
    db_engine_version                   = var.db_engine_version
    db_name                             = var.db_name
    db_username                         = var.db_username
    db_password                         = var.db_password
    
    
  
}

module "s3" {

    source                              = "../modules/s3"
    project_name                        = var.project_name
    environment                         = var.environment
   
    
  
}

module "acm" {

    source                              = "../modules/acm"
    project_name                        = var.project_name
    environment                         = var.environment
    domain_name                         = var.domain_name
    san_names                           = var.san_names
    route53_zone_id                     = var.route53_zone_id


}

module "static-site" {

    source                              = "../modules/static-site"
    project_name                        = var.project_name
    environment                         = var.environment
    domain_name                         = var.domain_name
    route53_zone_id                     = var.route53_zone_id
    acm_certificate_arn                 = module.acm.acm_certificate_arn


}

module "ssm-parameter" {

    source                              = "../modules/ssm-parameter"
    project_name                        = var.project_name
    environment                         = var.environment
    db_name                             = var.db_name
    db_username                         = var.db_username
    db_password                         = var.db_password
    rds_endpoint                        = module.rds.rds_endpoint


}

module "cloudtrail" {

    source                              = "../modules/cloudtrail"
    project_name                        = var.project_name
    environment                         = var.environment

}

module "aws-config" {

    source                              = "../modules/aws-config"
    project_name                        = var.project_name
    environment                         = var.environment

}

module "cloudwatch" {

    source                              = "../modules/cloudwatch"
    project_name                        = var.project_name
    environment                         = var.environment
    ansible_instance_id                 = module.vpc.ansible_instance_id
    alert_email                         = var.alert_email
    rds_storage_threshold               = module.rds.rds_storage_threshold  * 1024 * 1024 * 1024 * 0.2
    rds_instance_id                     = module.rds.rds_instance_id
    region                              = var.region



}

module "secret-manager" {
  source                               = "../modules/secret-manager"
  project_name                         = var.project_name
  environment                          = var.environment
  secret_username                      = var.secret_username
  secret_password                      = var.secret_password

}