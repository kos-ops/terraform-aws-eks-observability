####################################################################################################
# IAM Role
####################################################################################################

resource "aws_iam_role" "role" {
  name                 = var.role_name
  assume_role_policy   = var.external_assume_role_policy != null ? var.external_assume_role_policy : data.aws_iam_policy_document.assume_role_policy.json
  max_session_duration = var.max_session_duration
  description          = var.role_description
  
  tags                 = var.tags
}

## IAM Assume role policy

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = var.services_to_assume_role
    }
  }
}

####################################################################################################
## IAM Inline Policy for the Role
####################################################################################################

resource "aws_iam_role_policy" "role_policy" {
  count = var.create_role_policy ? 1 : 0

  name   = "${var.role_name}-policy"
  role   = aws_iam_role.role.name
  policy = var.role_policy
}

####################################################################################################
## IAM Managed Policy Attachments for the Role
####################################################################################################

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  for_each = { for k, v in var.managed_policy_arns : k => v }

  role       = aws_iam_role.role.name
  policy_arn = each.value
}