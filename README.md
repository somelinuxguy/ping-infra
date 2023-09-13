## A GitOps Project

For fun, and to keep my skills up to date, I'm building this. Also because I take a lot from the open source community, I want to give this back to you in the hope that it will help somebody who is having a similar (never the same) problem in search of a solution.

# Requirements
1. We must use modern and zero trust approaches for security.
1. Use infrastructure as code. Avoid ClickOps.
1. Take a GitOps approach to deploying newly merged code.
1. We must not store infrastructure configuration (k8s manifests) with the application code. We are allowed to store application specific things with the app code (like Datadog monitors)
1. It's not done unless it is tested, and monitored

# How will that be accomplished?

To keep the README short, please visit the [docs directory here](https://github.com/somelinuxguy/ping-infra/docs)

# The Result

When all of this is complete our goal is to have a working application that acts as a RESTful API endpoint. Merging code to that application repository will trigger a build process in github actions, and then deployment of the code to an AWS environment. That's the workflow summary.

In order to accomplish this we need to also add a few more tools in to the mix. We will create the AWS environment using Terraform, so that the code has a place to deploy to, and a place to run. The code itself will need some quality control and testing. The docker image we deploy that contains our app will need to be secure.

We will also want to ensure that not just the app is working, we'll also want to make sure that our infrastructure is monitored so we can see healthy and performant (is that a word?) systems. In the case of illness, we should be able to trigger alerts.

See the README in the docs folder for more detailed explanations, steps to accomplish this desired result, and probably more Monty Python jokes.