# Deployment

Let's talk about how we do the CI (continuous integration of new code) and the CD (continuous deployment of that code) in the context of our project and its requirements.

## The Workflow

Github actions.
- Checkout the code.
- Run the tests.
- Build an image.
- Check the image in to ECR.
- MOVED TODO - Update git-ops repo with the hash of our release (to trigger ArgoCD to deploy it)
- Update the running deploy with the latest image

Items of Interest: 
- the above requires that each previous step complete successfully or we stop, this prevents bad code deployments.
- the above requires that GHA be able to login to AWS. This is where VAULT comes in for storing those credentials.

## TODO

Hardware Test - We test the code. Do we need to test the hardware? Do we just assume terraform has got this? There are test frameworks for infrastructure we could include in the CI pipeline to ensure that not only is the code good, but the place we are about to deploy is sane too.

Deploy - For the sake of speed here the app is deployed with a dirty hack, it would be ideal to get Argo in place.

Rollback - Often skipped. What if we deploy bad code? How do we handle that? If that's built as part of the workflow to begin with, then the inevitable "woops" is so much less painful in the future.