#module "gcloud" {
#  source = "../common"
#}

#terraform {
#  backend "gcs" {
#    bucket = "${var.project}-tfstate"                                   
#    prefix = "bb-singlem-processing"                                                
#  }
#}


terraform {
  backend "gcs" {}
}

data "terraform_remote_state" "state" {
  backend = "gcs"
  config {
    bucket = "${var.project}-tfstate"
    prefix = "bb-singlem-processing"
  }
}

provider "google" {
  project = var.project
  region = var.region
}

provider "google-beta" {
  project = var.project
  region = var.region
}

