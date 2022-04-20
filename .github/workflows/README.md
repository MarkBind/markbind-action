# markbind-reusable-workflows

A list of GitHub Reusable Workflows that help improve your CI/CD with a MarkBind site.

- Create a new workflow to set up PR preview for your MarkBind site, including PRs from forks
  - `fork-build.yml`
  - `fork-preview.yml`
- Unpublish PR preview site
  - `unpublish-preview.yml`

## Option Summary

### fork-build

Option                                                 | Required |                      Default | Remarks
:------------------------------------------------------|:--------:|-----------------------------:|----------------------------------------------
[version](#version)                                    |    no    |                   `'latest'` | The MarkBind version to use to build the site
[rootDirectory](#rootdirectory-markbind-cli-arguments) |    no    |                        `'.'` | The directory to read source files from
[siteConfig](#siteconfig-markbind-cli-arguments)       |    no    |                `'site.json'` | The site config file to use

### fork-preview & unpublish-preview

Option            | Required | Remarks
:-----------------|:--------:|-----------------------------------------
[token](#token)   |   yes    | The token to be used for the service
[domain](#domain) |   yes    | The domain that the site is available at

## Option Details

### version

The MarkBind version to use to build the site.

- Latest
  - `'latest'`
  - This is the default value
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

### siteConfig (MarkBind CLI arguments)

The site config file to use.

- Default site config file
  - `'site.json'`
  - This is the default value
- Name of your site config file
  - If your site config file is not named `site.json`, specify the name here
    - E.g. `'ug-site.json'`

### token

Token for Surge.sh

- `${{ secrets.SURGE_TOKEN }}`
  - `SURGE_TOKEN` is the environment secret name
- Require registration with an email address
- After retrieving the token, put the token as a repository secret in your repository
- See [here](https://markbind.org/userGuide/deployingTheSite.html#previewing-prs-using-surge) for a detailed guide on how to retrieve the token

### domain

The domain that the site is available at.

- A surge.sh subdomain
  - `'<subDomain>.surge.sh'`
  - Surge allows you to specify a subdomain for free as long as it has not been taken up by others. You have to ensure that the `<subDomain>` is unique.
  - A possible subdomain to use is your repository name: e.g. `mb-test.surge.sh`
- Additional notes
  - for PR preview purposes, the domain you specify will automatically be prefixed with 'pr-x-', where 'x' is the GitHub event number
    - E.g. `'pr-x-<domain>'` (and hence `'pr-1-mb-test.surge.sh'`)
  - Custom domain does not work with PR preview
  - This action will not automatically cleanup merged PR deployments. Follow this [instruction](https://surge.sh/help/tearing-down-a-project) to manually tear down the deployed site if required

## Usage

With `fork-build.yml` and `fork-preview.yml`, you can establish a secure workflow that builds your MarkBind site triggered by a fork PR.
Then, the site artifact will be uploaded and deployed for preview. Note that the choice of using two separate workflows is to reduce possible security issues, as [recommended](https://securitylab.github.com/research/github-actions-preventing-pwn-requests/) by the GitHub Security Lab.

In your repository, you will need to add two workflows to the `.github/workflows` folder.

- The first workflow being `fork-build.yml` will be triggered by a pull request.
  - Adjust the target branch accordingly
    - The sample workflow below will be triggered by PR against the `main` branch
- The second workflow being `fork-preview.yml` will be triggered whenever `fork-build` is completed.
  - Adjust the domain accordingly
    - The sample workflow below publish to `pr-x-mb-test.surge.sh`

1. Create a `fork-build.yml`

```yaml
name: Build Fork PR

# read-only
# no access to secrets
on:
  pull_request:
    branches:
      - main

# cancel multiple runs at the same time, can be removed if you don't want it
concurrency: 
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build:
    name: Build Fork PR
    uses: MarkBind/markbind-action/.github/workflows/fork-build.yml@master
    with:
      version: "3.1.1"
```

2. Create a `fork-preview.yml`

```yaml
name: Preview Fork PR

on:
  workflow_run:
    workflows: ["Build Fork PR"]
    types: [completed]

jobs:
  on-success:
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    name: Deploying to Surge
    uses: MarkBind/markbind-action/.github/workflows/fork-preview.yml@master
    with:
      domain: "mb-test.surge.sh"
    secrets:
      token: ${{ secrets.SURGE_TOKEN }}
```

### Unpublish PR preview site

*(This is Optional)*

By default, the site will be published to surge.sh and will be available for preview. The site will not be deleted when the PR is merged. However, if you wish to unpublish the site whenever the PR is merged/closed, you can use the following workflow.

Note that this workflow uses the `pull_request_target` in order to expose the secrets to the workflow triggered by a fork. This is still secure (admittedly, not as secure as not exposing the secrets at all) as the workflow does not require dangerous processing, say building or running the content of the PR. Read [Keeping your GitHub Actions and workflows secure Part 1: Preventing pwn requests](https://securitylab.github.com/research/github-actions-preventing-pwn-requests/) if you want to learn more about this.

You may also consider a manual teardown of a surge site by following the [instruction](https://surge.sh/help/tearing-down-a-project), if required.

1. Create a `unpublish-preview.yml`
   - Adjust the target branch accordingly
      - The sample workflow below will be triggered by PR against the `main` branch

```yaml
name: Unpublish preview site

on:
  pull_request_target:
    types: [closed]
    branches:
      - main

jobs:
  build:
    name: Unpublish from Surge
    uses: MarkBind/markbind-action/.github/workflows/unpublish-preview.yml@master
    with:
      domain: "mb-test.surge.sh"
    secrets:
      token: ${{ secrets.SURGE_TOKEN }}
```
