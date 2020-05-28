---
page_type: sample
languages:
- bash
products:
- azure, azure kubernetes service
description: "Application to demo AKS features"
urlFragment: "aks-demos"
---

# Set up an Azure Kubernetes Service cluster to test out new features

This content was prepared based on the demos presented at Microsoft Ignite 2019.

This samples shows you how to set up an Azure Kubernetes Cluster and enable features such as Azure Policy, Azure Security Center, Windows Containers for AKS, and Virtual Nodes.

## Contents

| File/folder       | Description                                |
|-------------------|--------------------------------------------|
| `azure-policy`             | Sample code and instructions to set up a Kubernetes cluster and enable Azure Policy                     |
| `azure-security-center`             | Sample code and instructions to set up a Kubernetes cluster and enable Azure Security Center                       |
| `private-clusters`             | Sample code and instructions to set up a Kubernetes cluster and enable private clusters                       |
| `virtual-node-autoscale`             | Sample code and instructions to set up a Kubernetes cluster and enable virtual node.            |
| `windows-demo`             | Sample code and instructions to set up a Kubernetes cluster and enable Windows containers for AKS
| `.gitignore`      | Define what to ignore at commit time.      |
| `CHANGELOG.md`    | List of changes to the sample.             |
| `CONTRIBUTING.md` | Guidelines for contributing to the sample. |
| `README.md`       | This README file.                          |
| `LICENSE`         | The license for the sample.                |

## Prerequisites

The samples assume that you have an Azure subscription and a terminal to run the bash scripts for setup. Some samples have additional prequisites that are outline in their respective READMEs.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
