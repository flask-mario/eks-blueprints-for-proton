terraform {
  backend "s3" {
      bucket    = "aws-proton-terraform-bucket-027500179340" 
      key       = "non-proton/" 
  }
}
