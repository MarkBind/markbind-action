# markbind-action
A GitHub Action that builds and deploys your MarkBind site.

## Option Summary

Option        | Required |                      Default | Remarks
:-------------|:--------:|-----------------------------:|------------------------------------------------------------------------------
token         |   yes    |                              | The token to be used for the service
service       |    no    |                   'gh-pages' | The publishing service to deploy the site
purpose       |    no    |                 'deployment' | The deployment purpose
domain        |    no    |                           '' | The domain that the site is available at. Required if service chosen is surge
version       |    no    |                     'latest' | The MarkBind version to use to build the site
keepFiles     |    no    |                        false | Whether to keep the files in the published branch before pushing
rootDirectory |    no    |                          '.' | The directory to read source files from
baseUrl       |    no    | Value specified in site.json | The base URL relative to your domain
siteConfig    |    no    |                  'site.json' | The site config file to use

## Option Details

### token
Currently two types of tokens are supported (correspond to the two supported publishing services):
- Token for GitHub Pages
  - Simply use `${{ secrets.GITHUB_TOKEN }}`
  - Note that you need to ensure that your have selected the branch that you want to deploy to in your GitHub repo's Pages settings
- Token for Surge.sh
  - Example: `${{ secrets.SURGE_TOKEN }}`
    - `SURGE_TOKEN` is the environment secret name
  - Require registration with an email address
  - After retrieving the token, put the token as a repository secret in your
  - See [here](https://markbind.org/userGuide/deployingTheSite.html#previewing-prs-using-surge) for a detailed guide on how to retrieve the token

### service
Currently two types of publishing services are supported:
- GitHub Pages
  - 'gh-pages'
  - See [here](https://markbind.org/userGuide/deployingTheSite.html#publishing-to-github-pages) for more details
- Surge.sh
  - 'surge'
  - See [here](https://surge.sh/) for more details

### purpose
The purpose of the deployment. This can be either standard deployment or for PR previewing.
- Standard deployment
  - 'deployment'
  - This is the default value
- PR preview
  - 'pr-preview'
  - This is used when you want to build and preview a site when there is a PR made to the repository. Note that this does not work for PR from a fork(due to security reasons)

### domain
The domain that the site is available at. Required if service chosen is surge. Surge.sh allows you to specify a subdomain as long as it is not taken up by others.

- 'xxx.surge.sh'
  - A typical domain that you can specify. You have to ensure that 'xxx' is unique. Read [here](https://surge.sh/help/adding-a-custom-domain) on how to configure a custom domain with Surge.sh
- 'pr-x-<domain>'
  - Note that for PR Preview purposes, the domain you specify will be prefixed with 'pr-x-', where 'x' is the GitHub event number

### version
The MarkBind version to use to build the site.
- 'latest'
  - This is the latest published version of MarkBind
- 'master'
  - This is the latest, possibly unpublished version of MarkBind in development
- 'X.Y.Z'
  - This is the version of MarkBind with the specified version number
  - A sample version number is '3.1.1'

### keepFiles
Whether to keep the files in the published branch before pushing. This is a boolean parameter.
- false
  - This is the default value
- true
  - This will preserve any existing files in the published branch before an update is made.

### rootDirectory (MarkBind CLI arguments)
The directory to read source files from.
- '.'
  - This is the default value
  - This is for the case that your source files of the MarkBind site are in the root directory of the repository
- './path/to/directory'
  - This is for the case that your source files of the MarkBind site are in a subdirectory of the repository
  - A sample path is './docs'

### baseUrl (MarkBind CLI arguments)
The base URL relative to your domain.
- '/reponame'
  - Defaults to the value of `baseUrl` in your `site.json` file
  - This is important for deploying your site to GitHub Pages
  - Note that you will need to specify this or in the site config file (typically the `site.json`), in order to configure the relative URL correctly.

### siteConfig (MarkBind CLI arguments)
The site config file to use.
- 'site.json'
  - This is the default value

# Usage
In essence, there are two parts to a GitHub Action workflow:
- The trigger event
- The jobs/steps to be run after the trigger event occurs

For our context, there two typical trigger events. This is written at the start of the workflow files:
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
      - name: Build & Deploy to GitHub Pages
        uses: MarkBind/markbind-action@master
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          baseUrl: '/mb-test'
          version: '3.1.1'
```
The above script builds the site from the repository's root directory, with baseUrl of '/mb-test' ('mb-test' is the repository name), with MarkBind version 3.1.1.

Then, it will deploy the site to GitHub Pages. It runs everytime there is a push to the repository.

# Scenarios
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
      - name: Build & Deploy to GitHub Pages
        uses: MarkBind/markbind-action@master
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          version: '3.1.1'
```

## Deploy to Surge.sh
```yaml
name: MarkBind Action

on: [push]

jobs: 
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Build & Deploy to GitHub Pages
        uses: MarkBind/markbind-action@master
        with:
          token: ${{ secrets.SURGE_TOKEN }}
          service: 'surge'
          domain: 'mb-test.surge.sh'
```
Note that if you are using custom domain, you will need to ensure that it is configured with Surge.sh.

## Build with the development branch of MarkBind
```yaml
name: MarkBind Action

on: [push]

jobs: 
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Build & Deploy to GitHub Pages
        uses: MarkBind/markbind-action@master
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          version: 'master'
```
'master' is specified so that the site is built with the latest (possibly unpublished) version of MarkBind.

## Build with files that is not at the root level of the repository
```yaml
name: MarkBind Action

on: [push]

jobs: 
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Build & Deploy to GitHub Pages
        uses: MarkBind/markbind-action@master
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          rootDirectory: './docs'
```

## PR Preview for PRs made following a branching workflow
```yaml
name: MarkBind Action

on:
  pull_request:
    branches:
      - master

jobs: 
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Build & Deploy to GitHub Pages
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