# PSRule for Azure Quick Start

This repository contains a sample code you can use to quickly start using PSRule for Azure.
To learn more about PSRule for Azure, see <https://aka.ms/ps-rule-azure>.

[![Use this template](https://img.shields.io/static/v1?label=GitHub&message=Use%20this%20template&logo=github&color=007acc)][1]
[![Open in vscode.dev](https://img.shields.io/badge/Open%20in-vscode.dev-blue)][2]

  [1]: https://github.com/Azure/PSRule.Rules.Azure-quickstart/generate
  [2]: https://vscode.dev/github/Azure/PSRule.Rules.Azure-quickstart

## What's included?

This repository includes:

- **Azure Bicep deployment** &mdash; Starter Azure Bicep deployments.
  - Use the files in the `deployments/` folder if you are using Bicep to deploy resources.
- **Azure Bicep modules** &mdash; Starter Azure Bicep modules.
  - Use the files in the `modules/` folder if you are using Bicep to create reusable modules with tests.
- **GitHub Actions** &mdash; Starter workflow for checking Azure Infrastructure as Code (IaC).
  - Use the files in the `.github/workflows/` to check your Azure IaC with GitHub Actions.
  - The `ms-analyze.yaml` file can be ignore or removed as this will not execute outside this repository.
- **Azure Pipelines** &mdash; Starter pipeline for checking Azure Infrastructure as Code (IaC).
  - Use the files in the `.pipelines/` to check your Azure IaC with Azure Pipelines.
- **Custom rules and baselines** &mdash; Example custom rules and baselines.
  - These rules and baselines can be used to enforce organization specific requirements.
  - Use the files in the `.ps-rule/` folder to configure custom rules and baselines.
- **PSRule options** &mdash; Example options for using PSRule for Azure.
  - PSRule options are configures within `ps-rule.yaml`.
  - Options include suppressing rules, configuring input/ output, and any rules modules.

> [!NOTE]
> PSRule for Azure supports ARM templates in addition to Bicep code.
> However going forward this repository will focus on Bicep deployments and modules.
> Existing ARM templates samples are no longer maintained and have been archived.
> To access these samples jump to the [archive/with-arm-templates][3] branch.

  [3]: https://github.com/Azure/PSRule.Rules.Azure-quickstart/tree/archive/with-arm-templates

## What to expect?

This repository shows valid uses of PSRule for Azure, both pass and failure cases.
Inspect the following files for instructions to test PSRule for Azure rules by creating a failure.

- [deployments/contoso/landing-zones/subscription-1/rg-app-001/dev.bicepparam](deployments/contoso/landing-zones/subscription-1/rg-app-001/dev.bicepparam)
- [deployments/contoso/landing-zones/subscription-1/rg-app-002/deploy.bicep](deployments/contoso/landing-zones/subscription-1/rg-app-002/deploy.bicep)

For examples of how to reference resources that require secrets to be passed in, see:

- [deployments/contoso/landing-zones/subscription-1/rg-vm-001/deploy.bicep](deployments/contoso/landing-zones/subscription-1/rg-vm-001/deploy.bicep)

## Support

This project uses GitHub Issues to track bugs and feature requests.
Please search the existing issues before filing new issues to avoid duplicates.

- For new issues, file your bug or feature request as a new [issue].
- For help, discussion, and support questions about using this project, join or start a [discussion].

Support for this project/ product is limited to the resources listed above.

## Contributing

This project welcomes contributions and suggestions.
If you are ready to contribute, please visit the [contribution guide](CONTRIBUTING.md).

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Maintainers

- [Bernie White](https://github.com/BernieWhite)

## License

This project is [licensed under the MIT License](LICENSE).

## Trademarks

This project may contain trademarks or logos for projects, products, or services.
Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.

[issue]: https://github.com/Azure/PSRule.Rules.Azure-quickstart/issues
[discussion]: https://github.com/Azure/PSRule.Rules.Azure-quickstart/discussions
