# Provider configuration for using the S3 Inventory module
# All 14 regional providers must be defined and passed to the module

# Define all required regional providers
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  # Add your authentication configuration here
  # profile = "your-profile"
  # or use environment variables: AWS_PROFILE, AWS_ACCESS_KEY_ID, etc.
}

provider "aws" {
  alias  = "us_east_2"
  region = "us-east-2"
}

provider "aws" {
  alias  = "us_west_1"
  region = "us-west-1"
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}

provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "eu_west_2"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "eu_central_1"
  region = "eu-central-1"
}

provider "aws" {
  alias  = "ap_south_1"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "ap_southeast_1"
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "ap_southeast_2"
  region = "ap-southeast-2"
}

provider "aws" {
  alias  = "ap_northeast_1"
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "ap_northeast_2"
  region = "ap-northeast-2"
}

provider "aws" {
  alias  = "sa_east_1"
  region = "sa-east-1"
}

provider "aws" {
  alias  = "ca_central_1"
  region = "ca-central-1"
}