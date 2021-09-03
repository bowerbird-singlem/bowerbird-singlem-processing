terraform {
  backend "gcs" {
    bucket = "maximal-dynamo-308105-tfstate"
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
