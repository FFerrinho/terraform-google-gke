terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.16.0"
    }
  }

  required_version = ">= 1.5"
}
