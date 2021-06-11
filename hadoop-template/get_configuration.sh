#!/bin/bash

# Get user's groups and their configuration (custom configuration and backend)
# If there is more public groups than 100 on the gitlab instance some group may be missed
group_paths=()
base_url_api="$GITLAB_URL/api/v4/"
for group_path in $(curl "$(sed 's:$:groups?per_page=100:' <<< $base_url)" | jq '.[].path'); do
    group_paths+=($group_id)
done

USER_ENV='/tmp/renku-env'
GROUP_ENV='/tmp/renku-env-group'

# Clone the renku-env of the groups if present
for group_path in $group_paths; do
    GIT_TERMINAL_PROMPT=0 git clone $GITLAB_URL/$group_path/renku-env.git $GROUP_ENV 2>/dev/null
done

# Clone the renku-env of the user, uses the one with access token if defined in the Dockerfile of the project
user_env_url="${GITLAB_URL}/${JUPYTERHUB_USER}/renku-env.git"
if [ -n CUSTOM_RENKU_ENV_URL ]; then
    user_env_url="$CUSTOM_RENKU_ENV_URL"
fi
git clone $user_env_url $USER_ENV

ENVS=($GROUP_ENV $USER_ENV)
for ENV in "${ENVS[@]}"; do
    # Get definition of backend in current renku-env if present
    backend_repo="$(jq -r ".BACKEND_CONF_REPO" $ENV/hadoop-conf.json)"
    if ! [ -z $backend_repo ] && ! [ $backend_repo = 'null' ]; then
        git clone "$backend_repo" /tmp/backend-repo && \
            mv -f /tmp/backend-repo/backend-conf.json $RENKU_HADOOP_DIR && \
            rm -rf /tmp/backend-repo 2>/dev/null
    else
        mv -f $ENV/backend-conf.json $RENKU_HADOOP_DIR 2>/dev/null
    fi

    # Get configuration of backend's modules in current renku-env if present
    modules_repo="$(jq -r ".BACKEND_MODULES_CONF_REPO" $ENV/hadoop-conf.json)"
    ! [ -z $modules_repo ] && ! [ $modules_repo = 'null' ] && \
        git clone "$modules_repo" /tmp/modules-conf-repo && \
        find /tmp/modules-conf-repo -type f -not -path '/tmp/modules-conf-repo/.git/*' |\
            grep -vi 'readme' |\
            xargs -I {} mv {} $RENKU_HADOOP_DIR && \
        rm -rf /tmp/modules-conf-repo/
done



