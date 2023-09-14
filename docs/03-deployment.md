# Deployment

Let's talk about how we do the CI (continuous integration of new code) and the CD (continuous deployment of that code) in the context of our project and its requirements.

## Build

Github actions.
- Checkout the code.
- Run the tests.
- Build an image.
- Check the image in to ECR.
- Update git-ops repo with the hash of our release (to trigger ArgoCD to deploy it)

Items of Interest: 
- the above requires that each previous step complete successfully or we stop, this prevents bad code deployments.
- the above requires that GHA be able to login to AWS. This is where VAULT comes in for storing those credentials.

## Test

We test the code. Do we need to test the hardware? Do we just assume terraform has got this? There are test frameworks for infrastructure we could include in the CI pipeline to ensure that not only is the code good, but the place we are about to deploy is sane too.

## Deploy

## Rollback

Often skipped. What if we deploy bad code? How do we handle that? If that's built as part of the workflow to begin with, then the inevitable "woops" is so much less painful in the future.