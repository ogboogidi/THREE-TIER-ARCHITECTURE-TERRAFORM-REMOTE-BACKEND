#create a locals file for dynamic tagging of resources

locals {
  apci_tags = {
    project = "firestone"
    application = "apci_s3_reader"
    environment = "dev"
    owner = "ogboogidi"
  }
}
