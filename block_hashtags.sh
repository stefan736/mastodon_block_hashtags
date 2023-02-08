#!/bin/bash

. ./config.sh

accessToken="$1"

get_local_users() {
    nextURL=$serverURL/api/v1/admin/accounts?local=1
    echo "" > accounts.tmp
    while :
    do
	    curl -s -H "Authorization: Bearer $accessToken" $nextURL | jq -r .[].id >> accounts.tmp
        curl -Is -w '%header{link}' -H "Authorization: Bearer $accessToken" $nextURL > header.tmp
        if ! grep -q 'rel="next"' "header.tmp"; then
            break;
        fi

        nextURL=$(grep "link:" header.tmp | cut -d ' ' -f 2 | cut -d '>' -f 1 | cut -d '<' -f 2)
    done
}

get_all_followings () {
    accountId=$1
    # get followers to exclude from blocking
    echo '"'$accountId'"' >> followings.tmp
    nextURL=$serverURL/api/v1/accounts/$accountId/following?limit=80
    while :
    do
        curl -s -H "Authorization: Bearer $accessToken" $nextURL | jq .[].id >> followings.tmp
        curl -Is -w '%header{link}' -H "Authorization: Bearer $accessToken" $nextURL > header.tmp
        if ! grep -q 'rel="next"' "header.tmp"; then
            break;
        fi

        nextURL=$(grep "link:" header.tmp | cut -d ' ' -f 2 | cut -d '>' -f 1 | cut -d '<' -f 2)
    done
}

block_unknown_accounts_with_posts_tagged_with () {
    tag=$1

    tagURL="$serverURL/api/v1/timelines/tag/$tag?only_media=1"

    while :
    do
        echo "Getting $tagURL"
        # get all accounts from posts with media for a given tag
        accountIdsToBlock=$(curl -sf $tagURL | jq '.[] | select(.media_attachments | length > 0)' | jq -r .account.id | sort | uniq)
        curl -Is -w '%header{link}' -H "Authorization: Bearer $accessToken" $tagURL > header.tmp
        for accountId in $accountIdsToBlock; do
            echo "$tag: checking account $accountId ..."
            if ! grep -q "$accountId" "followings.tmp"; then
                echo "$tag: suspending account $accountId ..."
                curl -s -H "Authorization: Bearer $accessToken" -X POST -F type=suspend $serverURL/api/v1/admin/accounts/$accountId/action
                echo "$tag: deleting account data $accountId ..."
                curl -s -H "Authorization: Bearer $accessToken" -X DELETE -F type=suspend $serverURL/api/v1/admin/accounts/$accountId
            fi
        done

        if ! grep -q 'rel="next"' "header.tmp"; then
            break;
        fi

        tagURL=$(grep "link:" header.tmp | cut -d ' ' -f 2 | cut -d '>' -f 1 | cut -d '<' -f 2)
    done
}

echo
echo "################### START $(date) #############"

echo "" > followings.tmp

if $multiUserMode; then
    echo 'Running in multi user mode'
    get_local_users

    while read accountId
    do
        if [ -n "$accountId"  ]; then
            get_all_followings $accountId
        fi
    done < accounts.tmp
    
    rm accounts.tmp
else
    echo 'Running in single user mode'
    myAccountId=$(curl -s -H "Authorization: Bearer $accessToken" $serverURL/api/v1/accounts/verify_credentials | jq -r .id)
    get_all_followings $myAccountId
fi

if ! grep -q '[^[:space:]]' < "followings.tmp"
then
    echo 'No followings found. Aborting to protect yourself.'
    exit 1
fi;

for tag in "${tags[@]}"
do
    echo "Blocking tag '$tag'"
    block_unknown_accounts_with_posts_tagged_with $tag
done

rm followings.tmp
rm header.tmp

echo "################### END $(date) #############"