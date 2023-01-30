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
- register a new application in your mastodon instance
  - Preferences > Development > New Application
    - give it a nice name
    - enable `admin:write:accounts`
    - Save
    - Copy the value of `Your access token`
- copy the script on your machine, which should run the job
- in the script 
  - replace `serverURL`
  - set `applicationUserToken` with the token you just generated
- run
- setup a cronjob

## Epilogue
I created the script just for myself but maybe it is also useful for others, so I'm sharing this.

I also created an [Mastodon Issue - Administrative block of posts including special hashtags #21685](https://github.com/mastodon/mastodon/issues/21685) to get this functionality implemented.

Feel free to use the script, change, improve.

Find me on my Mastodon instance at [@stefan@social.stefanberger.net](https://social.stefanberger.net/@stefan).
