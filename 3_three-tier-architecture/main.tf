module "networking" {
  source    = "./modules/networking"
  project = var.project
}  

module "database" {
  source = "./modules/database"
  project = var.project
  vpc = module.networking.vpc
  sg = module.networking.sg
}

module "app" {
  source = "./modules/app"
  project = var.project
  vpc = module.networking.vpc
  sg = module.networking.sg
  db_config = module.database.db_config
}

module "web" {
  source = "./modules/web"
  project = var.project
  vpc = module.networking.vpc
  sg = module.networking.sg
}