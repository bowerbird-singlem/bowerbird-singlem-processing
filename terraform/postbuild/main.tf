terraform {
  backend "gcs" {
    bucket = "${var.project}-tfstate"
    prefix = "bowerbird-singlem-processing"
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
