# mastodon_block_hashtags

This repository contains a script for blocking / removing contents of certain tags and blocking their accounts.

## Motivation
When running a single user mastodon instance you often use relays to get content to your instance and increase reachability of your posts.
A side effect is that unwanted content reaches your instance from federated instances you maybe not want to host or spread.

For myself this mainly applies to NSFW content.

## What the script is doing
- it searches for all posts containing defined hashtags and media attachements
- if the account of one of these posts is not you and not one of your followings
  - the account gets suspended
  - the account data gets deleted

## Setup

You can either run this locally on your machine, or as a github action:

### 1) Get the required access token:

Regardless of how you wish to run your script, you first need to register a new application in your mastodon instance:

1. Preferences > Development > New Application
   1. give it a nice name
   2. enable `admin:write:accounts`
   3. Save
   4. Copy the value of `Your access token`

### 2) Run as GitHub Action

If you wish to run this as a GitHub action:
1. Fork this repository
2. In the `./config.sh` file define your server url, and any hashtags you wish to block
3. Create an Actions Secret called `ACCESS_TOKEN`, and supply the token generated above:
   1.  Go to Settings > Secrets and Variables > Actions
   2.  Click New Repository Secret
   3.  Supply the Name and Secret
4. Finally go to the 'Actions' tab and enable the action.

### 3) Run locally

Honestly, if you want to run this locally, you are probably better of using the original script, as it's a self-contained version, but if you do want run this version locally you could:

1. copy the script on your machine
2. In the `./config.sh` file define your server url, and any hashtags you wish to block
3. setup a cronjob that would run `bash /path/to/repo/block_hashtags.sh "{ACCESS_TOKEN}"`

## Epilogue
Both the idea and the original implementation are based on [@stefan@social.stefanberger.net](https://social.stefanberger.net/@stefan)'s script. I've just added a GitHub action, to clear up server resources, and split out the config into a separte script as that's easier for github actions.

Find me on my Mastodon instance at [@michael@thms.uk](http://mstdn.thms.uk/@michael).
