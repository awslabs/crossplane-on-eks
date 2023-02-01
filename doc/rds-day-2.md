# RDS day 2 operations 


## Background and problem statement


Managing databases can be challenging because they are stateful, not easily replaceable, and data loss could have significant business impact. An unexpected restart could cause havoc to applications that depend on them. Because of this, people want to offload management, maintenance, and availability of databases to another entity such as cloud providers. Amazon RDS is one of such services. 
Crossplane AWS provider aims to create building blocks for self-service experience for developers by providing abilities to manage AWS resources in Kubernetes native ways. 

In Amazon RDS some operations require an instance restart. For example, version upgrade and storage size modification require an instance restart. RDS attempts to minimize impact of such operations by:
1. Define a scheduled maintenance window.
2. Queue changes that you want to make.
3. During the next scheduled maintenance window, changes are applied.

This approach is fundamentally different from GitOps. In GitOps, when a change is checked into your repository, it is expected that actual resources are to match the specifications provided in the repository. 

RDS supports applying these changes immediately instead of waiting for a scheduled maintenance window, and when using Crossplane AWS providers, they have the option to apply changes immediately as well. This is the option that should be used when using RDS with GitOps. However this leads to problems when enabling self service model where developers can provision resources on their own. 

One of most notable problems is that updates made to certain fields could trigger database restarts. Developers may not know which fields would cause restarts because they are not familiar with underlying technologies. You could document potentially dangerous fields, but it is not enough to reliably stop it from happening. 

## Solutions

### Check during PR
Use Pull Request as a checkpoint and ensure developers are aware of potential consequences of the changes. An example process may look something like the following. 


```mermaid
flowchart LR
    FieldDefinitions(Fields that need restarting)
    StepFiles(Get changed files)
    StepCheck(Check if fields that require restart changed)
    Comment(Comment on PR)
    FieldDefinitions <--reference--> StepCheck

    PR(PR Created) --> CR(Does this need DB Restart) --need restart--> StepFiles --> StepCheck --> Comment --> Approval --> Merge
    CR --no restart--> Approval
```

In this example, whenever a pull request is created, a workflow is executed and a comment is created on the PR warning the developers of potential impacts. When developers approve the PR, it implies that they are aware of consequences.
To check if a PR is impacted, you can use of the following options:
- Parse git diff and search for changes to "dangerous" fields
- Use `kubectl diff` then look for changes to "dangerous" fields. This requires read access to the target cluster but more accurate.

In this approach, it is important for the check mechanisms to work reliably. It's easy to lose developers' trust when checks say there will be restarts but no restart happened. Or worse, checks did not detect potential restarts and caused an outage.

### Check at runtime

Another approach is to deny such operation at runtime using a policy engine and/or custom validating web hook unless certain conditions are met. This means problems with RDS configuration is communicated to the developers through their GitOps tooling by providing reasons for denial.

```mermaid
flowchart LR
    subgraph Kubernetes
        ConfigMap(ConfigMap w/ ticket numbers)
        ValidatingController(Policy Engine / Validating controller)
    end 

    subgraph Git 
        PR(PR Merged)
    end

    subgraph Ticketing
       Approved(Approved Changes)
    end
    
    GitOps(GitOps tooling)

    PR(PR Merged) --> GitOps --> ValidatingController
    ValidatingController --reference--> ConfigMap
    ValidatingController --deny and provide reason--> GitOps
    Approved --push--> ConfigMap
```
In the example above, no check is performed during PR. During admission into the Kubernetes cluster, a validating controller will lookup config map which contain ticket number and validate the request is valid. If no ticket number associated with this change is approved, it's rejected with provided reason. 

## Blue Green deployment
RDS added native support for blue green deployment. This allows for safer database updates.
As of writing this doc, neither providers support this functionality. Because the functionality is available in [Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#blue_green_update), the Upbound official provider should be able to support this in the future.
In addition, this functionality is supported for MariaDB and MySQL only.

# References
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.DBInstance.Modifying.html
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/modify-multi-az-db-cluster.html
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/blue-green-deployments-overview.html
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#blue_green_update