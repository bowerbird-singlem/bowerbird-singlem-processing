terraform {
  backend "gcs" {
    bucket = "REPLACE_WITH_PROJECT-tfstate"                                         
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
