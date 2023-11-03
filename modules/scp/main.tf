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

variable "policy_name" {
  description = "Name of the SCP to Create"
  type        = string
}

variable "policy_description" {
  description = "Description of the Policy"
  type        = string
  default     = null
}

variable "policy_targets" {
  description = "OU to attach Policy to"
  type        = list(string)
  default     = []
}

variable "policy_json" {
  description = "JSON Document"
  type        = string
}

resource "aws_organizations_policy" "scp" {
  name        = var.policy_name
  type        = "SERVICE_CONTROL_POLICY"
  description = var.policy_description
  content     = var.policy_json
}

resource "aws_organizations_policy_attachment" "scp_attachment" {
  count     = length(var.policy_targets)
  policy_id = aws_organizations_policy.scp.id
  target_id = var.policy_targets[count.index]
}
