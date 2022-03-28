# markbind-action
A GitHub Action that builds and deploys your MarkBind site.

## Option Summary

Option                          | Required |                      Default | Remarks
:-------------------------------|:--------:|-----------------------------:|-----------------------------------------------------------------
[token](#token)                 |   yes    |                              | The token to be used for the service
[service](#service)             |    no    |                 `'gh-pages'` | The publishing service to deploy the site
[purpose](#purpose)             |    no    |               `'deployment'` | The deployment purpose
[domain](#domain)               |    no    |                         `''` | The domain that the site is available at
[version](#version)             |    no    |                   `'latest'` | The MarkBind version to use to build the site
[keepFiles](#keepFiles)         |    no    |                      `false` | Whether to keep the files in the published branch before pushing
[rootDirectory](#rootdirectory-markbind-cli-arguments) |    no    |                        `'.'` | The directory to read source files from
[baseUrl](#baseurl-markbind-cli-arguments)             |    no    | Value specified in site.json | The base URL relative to your domain
[siteConfig](#siteconfig-markbind-cli-arguments)       |    no    |                `'site.json'` | The site config file to use

## Option Details

### token
Currently two types of tokens are supported (correspond to the two supported publishing services):
- Token for GitHub Pages
  - Simply use `${{ secrets.GITHUB_TOKEN }}`
  - Note that you need to ensure that your have selected the branch that you want to deploy to in your [GitHub repo's Pages settings](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#choosing-a-publishing-source)
  - Deployment to GitHub Pages might take 5-10 minutes before the site is available/refreshed
- Token for Surge.sh
  - `${{ secrets.SURGE_TOKEN }}`
    - `SURGE_TOKEN` is the environment secret name
  - Require registration with an email address
  - After retrieving the token, put the token as a repository secret in your
  - See [here](https://markbind.org/userGuide/deployingTheSite.html#previewing-prs-using-surge) for a detailed guide on how to retrieve the token

### service
Currently two types of publishing services are supported:
- GitHub Pages
  - `'gh-pages'`
  - See [here](https://markbind.org/userGuide/deployingTheSite.html#publishing-to-github-pages) for more details
- Surge.sh
  - `'surge'`
  - See [here](https://surge.sh/) for more details

### purpose
The purpose of the deployment. This can be either standard deployment or for PR previewing.
- Standard deployment
  - `'deployment'`
  - This is the default value
- PR preview
  - `'pr-preview'`
  - This is used if you want to build and preview the updated site whenever there is a PR made to the repository
  - The `service` must be `'surge'` and the `domain` must be specified
  - Note that this does not work for PR from a fork (due to security reasons)
  - This action will not automatically cleanup merged PR deployments. Follow this [instruction](https://surge.sh/help/tearing-down-a-project) to manually tear down the deployed site if required

### domain
The domain that the site is available at. Required if `service` chosen is Surge.
- A surge.sh subdomain
  - `'<subDomain>.surge.sh'`
  - Surge allows you to specify a subdomain for free as long as it has not been taken up by others. You have to ensure that the `<subDomain>` is unique. 
  - A possible subdomain to use is your repository name: e.g. `mb-test.surge.sh`
- A custom domain that you have configured with Surge
  - Read the [Surge documentation](https://surge.sh/help/adding-a-custom-domain) to understand how to set it up
- Additional notes
  - for PR preview purposes, the domain you specify will automatically be prefixed with 'pr-x-', where 'x' is the GitHub event number
    - E.g. `'pr-x-<domain>'` (and hence `'pr-1-mb-test.surge.sh'`)
  - Custom domain does not work with PR preview
  - This action will not automatically cleanup merged PR deployments. Follow this [instruction](https://surge.sh/help/tearing-down-a-project) to manually tear down the deployed site if required

### version
The MarkBind version to use to build the site.
- Latest
  - `'latest'`
  - This is the latest published version of MarkBind
- Development
  - `'development'`
  - This is the latest, possibly unpublished version of MarkBind in development
- Any valid version
  - `'X.Y.Z'`
  - This is the version of MarkBind with the specified version number
  - E.g. `'3.1.1'`
- Any valid version range
  - Internally the action calls [`npm install`](https://docs.npmjs.com/cli/v6/commands/npm-install) to install the specified version of MarkBind
  - Hence, a version range such as `'>=3.0.0'` (or semantic versioning like `'^3.1.1'`) is also valid

### keepFiles
Whether to keep the files in the published branch before pushing. This is a boolean parameter.
- Keep
  - `false`
  - This is the default value
- Don't keep
  - `true`
  - This will preserve any existing files in the published branch before an update is made.

### rootDirectory (MarkBind CLI arguments)
The directory to read source files from.
- Root
  - `'.'`
  - This is the default value
  - This is for the case that your source files of the MarkBind site are in the root directory of the repository
- Any subdirectory
  - `'./path/to/directory'`
  - This is for the case that your source files of the MarkBind site are in a subdirectory of the repository
    - E.g. `'./docs'`

### baseUrl (MarkBind CLI arguments)
The base URL relative to your domain.
- Default
  - The value of `baseUrl` in the site config file (typically `site.json`)
- Any valid base URL
  - For GitHub Pages, you will need to specify this here or in the site config file, in order to configure the relative URL correctly.
    - e.g. `'/reponame'`
  - For Surge, you will need to ensure that it's specfied as `''` here or in the site config file.

### siteConfig (MarkBind CLI arguments)
The site config file to use.
- Default site config file
  - `'site.json'`
  - This is the default value
- Name of your site config file
  - If your site config file is not named `site.json`, specify the name here
    - E.g. `'ug-site.json'`

# Usage
In essence, there are two parts to a GitHub Action workflow:
- The trigger event
- The jobs/steps to be run after the trigger event occurs

For our context, there two typical trigger events. This is written at the start of a workflow file:
(Assuming 'master' is the target branch)
1. Trigger the action whenever there is a push to the repository
```yaml
on:
  push:
    branches:
      - master
```

2. Trigger the action whenever there is a pull request to the repository
```yaml
on:
  pull_request:
    branches:
      - master
```

Then, specify a step to use this action:

E.g.
```yaml
name: MarkBind Action

on:
  push:
    branches:
      - master

jobs: 
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Build & Deploy MarkBind site
        uses: MarkBind/markbind-action@master
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          baseUrl: '/mb-test'
          version: '3.1.1'
```
The above script builds the site from the repository's root directory, with `baseUrl` of '/mb-test' ('mb-test' is the repository name), with MarkBind version 3.1.1.

Then, it will deploy the site to GitHub Pages. It runs everytime there is a push to the repository's master branch.

# Recipes
## Deploy to Github Pages on push to main
```yaml
name: MarkBind Action

on:
  push:
    branches:
      - main

jobs: 
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Build & Deploy MarkBind site
        uses: MarkBind/markbind-action@master
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          version: '3.1.1'
```

## Deploy to Surge.sh
```yaml
name: MarkBind Action

on:
  push:
    branches:
      - main

jobs: 
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Build & Deploy MarkBind site
        uses: MarkBind/markbind-action@master
        with:
          token: ${{ secrets.SURGE_TOKEN }}
          service: 'surge'
          domain: 'mb-test.surge.sh'
```

## Build with the latest developmental version of MarkBind
```yaml
name: MarkBind Action

on:
  push:
    branches:
      - main

jobs: 
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Build & Deploy MarkBind site
        uses: MarkBind/markbind-action@master
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          version: 'development'
```

## Build with files that is not at the root level of the repository
```yaml
name: MarkBind Action

on:
  push:
    branches:
      - main

jobs: 
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Build & Deploy MarkBind site
        uses: MarkBind/markbind-action@master
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          rootDirectory: './docs'
```

## PR preview for PRs made within the same repository
```yaml
name: MarkBind Action

on:
  pull_request:
    branches:
      - main

jobs: 
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Build & Deploy MarkBind site
        uses: MarkBind/markbind-action@master
        with:
          token: ${{ secrets.SURGE_TOKEN }}
          service: 'surge'
          purpose: 'pr-preview'
          domain: 'mb-test.surge.sh'
```

## Behind the Scenes
Besides processing a few bash scripts, this action utilises the following actions:
- [actions/checkout](https://github.com/actions/checkout)
- [actions/setup-node](https://github.com/actions/setup-node)
- [peter-evans/find-comment](https://github.com/peter-evans/find-comment)
- [peter-evans/create-or-update-comment](https://github.com/peter-evans/create-or-update-comment)
- [peaceiris/actions-gh-pages](https://github.com/peaceiris/actions-gh-pages)