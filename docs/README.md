## A GitOps Project

For fun, and to keep my skills up to date, I'm building this. Also because I take a lot from the open source community, I want to give this back to you in the hope that it will help somebody who is having a similar (never the same) problem in search of a solution.

# Requirements
1. We must not store secrets anywhere but Vault. No pipeline exposure.
1. We must use terraform to build the basic environment. (IaC)
1. We must trigger an app deployment via GitOps (a merge to a repository)
1. We must not store infrastructure configuration (k8s manifests) with the application code. We are allowed to store application specific things with the app code (like Datadog monitors)
1. It's not done unless it is tested, and monitored

# How will that be accomplished?

Steps.

Steps.

# The Result

Let's show a picture here.