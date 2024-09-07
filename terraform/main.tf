module "api" {
  source = "./apis"
}

module "resources" {
  source     = "./resources"
  depends_on = [module.api]
}
