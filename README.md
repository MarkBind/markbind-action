# markbind-deploy-gh-pages

Deploys your MarkBind site on push, using GitHub actions.


## How to use this action?

Make sure that your markbind project is on the master branch.

1. On the top of your repo, click **Actions**
2. Click **New workflow**
3. Click **Set up workflow yourself** on the top right corner
4. Configure your `main.yml` as follows (note that you need to specify the **BASE_URL** of your GitHub pages)

```yaml
name: MarkBind Deploy

on: [push]

jobs: 
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: Build & Deploy to GitHub Pages
        env: 
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITHUB_REPOSITORY: ${{ secrets.GITHUB_REPOSITORY }}
          GITHUB_ACTOR: ${{ secrets.GITHUB_ACTOR }}
          BASE_URL: # base URL to your gh-page
        uses: le0tan/markbind-deploy-gh-pages@master

```

This action will be triggered on push, and built files will be in `gh-pages` branch of the same repo.
