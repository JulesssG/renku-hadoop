#!/bin/bash

# Whitelist of all environment variables usable in configuration files
export RENKU_HADOOP_ENVS=(HDP_HOME HADOOP_HOME HIVE_HOME HADOOP_CONF_DIR HADOOP_DEFAULT_FS HADOOP_USER_NAME HIVE_JDBC_URL HIVE_SERVER_2 HBASE_SERVER YARN_NM_HOSTNAME YARN_NM_ADDRESS YARN_RM_HOSTNAME YARN_RM_ADDRESS YARN_RM_SCHEDULER YARN_RM_TRACKER LIVY_SERVER_URL JAVA_HOME JUPYTERLAB_DIR JUPYTERLAB_SETTINGS_DIR JUPYTERLAB_WORKSPACES_DIR)

# Load backend environment variables
for key in $(jq -r "keys[]" $RENKU_HADOOP_DIR/backend-conf.json); do
    value="$(jq -r ".\"$key\"" $RENKU_HADOOP_DIR/backend-conf.json)"
    value="$(eval echo $value)"
    export $key="$value"
done

# Load environment variables for all modules
export HADOOP_USER_NAME="${JUPYTERHUB_USER}"
export HDP_HOME="/home/jovyan/hdp"
export HADOOP_DEFAULT_FS="${HADOOP_DEFAULT_FS_ARG}"
export HADOOP_HOME="${HDP_HOME}/hadoop-3.1.1"
export HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop/"
export HIVE_JDBC_URL="${HIVE_JDBC_ARG}"
export HIVE_HOME="${HDP_HOME}/hive-3.1.0/"
export HIVE_SERVER_2="${HIVE_SERVER_ARG}"
export HBASE_SERVER="${HBASE_SERVER_ARG}"
export YARN_NM_HOSTNAME="${YARN_NM_HOSTNAME_ARG}"
export YARN_NM_ADDRESS="${YARN_NM_HOSTNAME_ARG}:45454"
export YARN_RM_HOSTNAME="${YARN_RM_HOSTNAME_ARG}"
export YARN_RM_ADDRESS="${YARN_RM_HOSTNAME_ARG}:8050"
export YARN_RM_SCHEDULER="${YARN_RM_HOSTNAME_ARG}:8030"
export YARN_RM_TRACKER="${YARN_RM_HOSTNAME_ARG}:8025"
export LIVY_SERVER_URL="${LIVY_SERVER_ARG}"
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/"
export JUPYTERLAB_DIR="/opt/conda/share/jupyter/lab"
export JUPYTERLAB_SETTINGS_DIR="$HOME/.jupyter/lab/user-settings"
export JUPYTERLAB_WORKSPACES_DIR="$HOME/.jupyter/lab/workspaces"

# Load template files with known location
filenames=("sparkmagic.conf" "beeline.conf" "hadoop-core-site.xml" "hadoop-yarn-site.xml" \
"hive-beeline-site.xml")
paths=("$HOME/.sparkmagic/config.json" "$HOME/.beeline/beeline-hs2-connection.xml" \
"$HADOOP_CONF_DIR/core-site.xml" "$HADOOP_CONF_DIR/yarn-site.xml" "$HIVE_HOME/conf/beeline-site.xml")
last_index=$((${#filenames[@]} - 1))
for i in $(seq 0 $last_index); do
    key=${filenames[$i]}
    path=${paths[$i]}
    mkdir -p ${path%/*}
    mv $RENKU_HADOOP_DIR/$key "$path"
done

if [ -f $RENKU_HADOOP_DIR/backend-modules-conf.json ]; then
    # Load other template files with their location defined in the main configuration
    # file of the repository for the modules configuration (backend-modules-conf.json)
    for key in $(jq -r ".CONF_FILES|keys[]" $RENKU_HADOOP_DIR/backend-modules-conf.json); do
        path="$(jq -r ".CONF_FILES.\"$key\"" $RENKU_HADOOP_DIR/backend-modules-conf.json)"
        path="$(eval echo $path)"
        filenames+=($key)
        paths+=($path)
        mkdir -p ${path%/*}
        mv $RENKU_HADOOP_DIR/$key "$path"
    done

    # Load environment variables
    for key in $(jq -r ".ENV_VARIABLES|keys[]" $RENKU_HADOOP_DIR/backend-modules-conf.json); do
        value="$(jq -r ".ENV_VARIABLES.\"$key\"" $RENKU_HADOOP_DIR/backend-modules-conf.json)"
        value="$(eval echo $value)"
        export $key="$value"
        RENKU_HADOOP_ENVS+=($key)
    done
fi

# Substitute environment variable in configuration files
last_index=$((${#filenames[@]} - 1))
for i in $(seq 0 $last_index); do
    path=${paths[$i]}
    last_index=$((${#RENKU_HADOOP_ENVS[@]} - 1))
    for j in $(seq 0 $last_index); do
        env_name=${RENKU_HADOOP_ENVS[$j]}
        env_value="$(eval echo \$$env_name)"
        sed -i -e "s|$env_name|$env_value|" "$path"
    done
done

