#!/bin/sh

set -e

echo '👍 MAIN ENTRYPOINT HAS STARTED—'
npm install -g markbind-cli
echo '👍 BUILDING THE SITE'
markbind build --baseUrl ${BASE_URL}
echo '👍 THE SITE IS BUILT—PUSHING IT BACK TO GITHUB-PAGES'
cd _site
remote_repo="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" && \
remote_branch="gh-pages" && \
git init && \
git config user.name "${GITHUB_ACTOR}" && \
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com" && \
git add . && \
echo -n 'Files to Commit:' && ls -l | wc -l && \
git commit -m'action build' > /dev/null 2>&1 && \
git push --force $remote_repo master:$remote_branch > /dev/null 2>&1 && \
rm -fr .git && \
cd ../
echo '👍 GREAT SUCCESS!'
