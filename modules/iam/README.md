<!-- BEGIN_TF_DOCS -->
# Module: iam

## Contents
- [Description](#description)
- [Dependencies](#dependencies)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)

## Description
Terraform module which creates IAM resources.


## Resources

| ID | Type | Name |
|----|------|------|
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource | `var.role_name` |
| [aws_iam_role_policy.role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource | `replace(var.role_name,"-role","-policy")` |
| [aws_iam_role_policy_attachment.role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource | n/a |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source | n/a |



## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| <a name="input_create_role_policy"></a> [create\_role\_policy](#input\_create\_role\_policy) | Flag to indicate whether to create the IAM role policy. | `bool` | `false` |
| <a name="input_external_assume_role_policy"></a> [external\_assume\_role\_policy](#input\_external\_assume\_role\_policy) | Custom JSON encoded assume role policy document. | `string` | `null` |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | The ARNs of the existing Managed IAM policies to attach to the execution role. | `list(string)` | `[]` |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | The maximum session duration (in seconds) for the IAM role. | `number` | `null` |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | A description for the IAM role. | `string` | `null` |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | The name of the IAM role. | `string` | `null` |
| <a name="input_role_policy"></a> [role\_policy](#input\_role\_policy) | The IAM role policy document in JSON format. | `string` | `null` |
| <a name="input_services_to_assume_role"></a> [services\_to\_assume\_role](#input\_services\_to\_assume\_role) | A list of service principal identifiers that are allowed to assume the IAM role. | `list(string)` | `[]` |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role. |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the IAM role. |
<!-- END_TF_DOCS -->