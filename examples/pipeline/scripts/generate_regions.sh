#!/bin/bash
# Copyright 2023 Chris Farris <chris@primeharbor.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

VERSION=$1

if [[ -z "$VERSION" ]] ; then
  REPO=github.com/primeharbor/org-kickstart//modules/security_services
else
  REPO=github.com/primeharbor/org-kickstart//modules/security_services?ref=$VERSION
fi

REGIONS=`aws ec2 describe-regions  | jq -r '.Regions[].RegionName'`

# Over write the existing files because we can't have duplicates
echo "# File autogenerated at `date`" > security_account_regions.tf
echo "# File autogenerated at `date`" > payer_regions.tf
echo "# File autogenerated at `date`" > security_services.tf

for r in $REGIONS ; do
  cat <<EOF >> security_account_regions.tf

provider "aws" {
  alias  = "security-account-$r"
  region = "$r"
  assume_role {
    role_arn = "arn:aws:iam::\${module.organization.security_account_id}:role/OrganizationAccountAccessRole"
  }
  default_tags {
    tags = local.default_tags
  }
}
EOF

  cat <<EOF >> payer_regions.tf

provider "aws" {
  alias  = "payer-$r"
  region = "$r"
  default_tags {
    tags = local.default_tags
  }
}
EOF

    cat <<EOF >> security_services.tf

module "security-services-$r" {
  source = "$REPO"
  providers = {
    aws.security_account = aws.security-account-$r
    aws.payer_account    = aws.payer-$r
  }
  security_account_id = module.organization.security_account_id
  security_services   = var.organization["security_services"]
  macie_key_arn       = module.organization.macie_key_arn
  macie_bucket_name   = var.organization["macie_bucket_name"]
}
EOF

done

echo "You may need to re-run terraform init"
