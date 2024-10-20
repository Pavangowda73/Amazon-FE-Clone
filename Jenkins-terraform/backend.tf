terraform {
  backend "s3"{
   bucket = "s3bucketforamazon2024"
   key = "Jenkins/terraform.tfstate"
   region = "ap-south-1"
}
}