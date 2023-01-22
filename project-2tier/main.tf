# --- root/main.tf ---

module "vpc-subs" {
  source           = "./vpc-subs"
  vpc_cidr         = local.vpc_cidr
  private_sn_count = 5
  public_sn_count  = 2
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  max_subnets      = 7
  access_ip        = var.access_ip
}


module "alb" {
  source            = "./alb"
  lb_sg             = module.vpc-subs.lb_sg
  public_subnets    = module.vpc-subs.public_subnets
  tg_port           = 80
  tg_protocol       = "HTTP"
  vpc_id            = module.vpc-subs.vpc_id
  web_asg           = module.autoscale.web_asg
  listener_port     = 80
  listener_protocol = "HTTP"
}

module "autoscale" {
  source                 = "./autoscale"
  bastion_sg             = module.vpc-subs.bastion_sg
  web_sg                 = module.vpc-subs.web_sg
  public_subnets         = module.vpc-subs.public_subnets
  private_subnets        = module.vpc-subs.private_subnets
  bastion_instance_count = 1
  instance_type          = "t2.micro"
  key_name               = "MyKey"
  user_data              = filebase64("./user-install.sh")
  lb_tg_name             = module.alb.lb_tg_name
  lb_tg                  = module.alb.lb_tg
}