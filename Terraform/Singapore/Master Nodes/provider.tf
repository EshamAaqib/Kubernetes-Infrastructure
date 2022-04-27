provider "google" {
  credentials = file("credentials.json")
  project     = "wso2-final-poject"
  region      = "asia-southeast1"
}