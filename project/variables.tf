variable "region" {}
variable "vpc_cidr" {}
variable "project_name" {}
variable "environment" {}
variable "public_subnet_cidr" {}
variable "private1_subnet_cidr" {}
variable "private2_subnet_cidr" {}
variable "nat_ami_id" {}
variable "key_name" {}
variable "ansible_ami_id" {}
variable "app_ami_id" {}

variable "db_allocated_storage" {}
variable "db_instance_class" {}
variable "db_engine_version" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}


variable "domain_name" {}
variable "san_names" {}
variable "route53_zone_id" {}
variable "alert_email" {}

variable "secret_username" {}

variable "secret_password" {}