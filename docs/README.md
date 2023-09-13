# A GitOps Project - The Nitty Gritty Details

Now with 10% less grit, and 20% more nit!

We know from the other file that we need to build an API endpoint (simulated, to keep things easy) and that we need a robust deployment pipeline for it. 

So let's dive right in to *requirements.* Any good project will have walls around it. These might be standards at your company, best practices shared among your team, or even just a few documented "wish list" items in a Jira ticket.

Here are ours:

## Requirements
1. We must use modern best practices (Zero Trust?) for secrets/credentials
1. Infrastructure as Code is an absolute requirement to help us meet automation goals, and also for excellent predictability and repeatability
1. Use GitOps models, such as "a commit is a deploy"
1. Use good repo design, and separation of concern
1. It's not done unless it is tested, and monitored

## The Result
This is what we aim to achieve.

TODO - Let's show a picture here. Everybody likes pictures.

## The Breakdown

Even a seemingly simple project like "Move this code in to production" is actually a series of steps. Like baking a cake, you may see the end result and never see the hundreds of little steps (ingredients, process, safety measures) that create it. It is key to break down your larger problem in to little bits. Bite sized tasks.

You ~~move~~ build a mountain one stone at a time. If you think about [a well formed SDLC](https://aws.amazon.com/what-is/sdlc/) you will probably see this list and think it looks pretty familiar.

### Planning
- Write up READMEs with a reasonable explanation of what we are doing, or will do
- Select components based on a few criteria primarily : Value/Relevance to the project, Cost, Easy to use/implement, Fun
- This is a demo, fun is actually important

### Infrastructure
- Signup for Vault
- Signup for Github
- Signup for AWS
- Create AWS infrastructure with Terraform
 - VPC
 - IAM Policies
 - ECR
 - EKS
 - Configure global EKS resources 
  - Ingress controller (for ALBs)

 Notes: We'll create a few things in AWS manually, because you can't automate some things without an account existing first. So we'll make an account for our good friend Terry Form and issue him some keys. Ideally we'd create a very specific and locked down policy for him, but this is just an exercise so it's ok for us to use Administrator. Also, terraform needs to store State somewhere and I really like the idea of keeping it in S3, because that let's Github, local users, or other locations run this terraform without state concurrency problems. So we need to make that S3 bucket first manually.

### Application
- Create repo ping-app
- Scaffold our app (RESTful, choose a language)
- Flesh out endpoints
- Build some testing
- Hook our repo in to SonarCloud (monitor for code quality/security)
- Build a Dockerfile (assuming tests pass)
- Register the image to ECR

Notes: All done manually. Not managing github repos with Terraform. I feel like there's not enough value for this project to implement that, but it is worth noting that managing github repos with IaC makes settings and users a little easier, as they can tend to skew across projects and having a simple bit of code to update during onboarding/offboarding is a nice way to make your Infosec team happy. For when you tackle that, [this is the resource](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) you will want to use.

### Deployment
- Create a github action in the application to build and register the new image
  - Let's deploy on Release instead of Merge

Notes: While an ideal Enterprise will have multiple environments following a standard Production/Not-Production pattern, we'll keep this one very simple and just trigger deployment of the image only when 

### Monitoring / Maintenance
- DataDog
- Cloudwatch
- Fluentbit

Notes: The above are partially redundant, we could use the Datadog (aka DD) agent OR fluentbit for grabbing logs and consoldating them in one place for easy searching and queries during troubleshooting or forensics. Similarly, DD and cloudwatch will both gather metrics and alert you if something goes awry. I am going to prefer DD for this as it will give us a nicer "single pane" but for the sake of speed/time and money I reserve the right to change my mind.
