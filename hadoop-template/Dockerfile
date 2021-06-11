# Dockerfile for renkubigdata/renkulab-py-bigdata:1.0.0
ARG RENKU_BASE_IMAGE=renku/renkulab-py:3.7-0.7.3
FROM ${RENKU_BASE_IMAGE}

#Install hadoop  3.1.1 and hive 3.1.0
USER root
ENV HDP_HOME=/home/jovyan/hdp/
ENV HADOOP_HOME=${HDP_HOME}/hadoop-3.1.1
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop/
ENV HIVE_HOME=${HDP_HOME}/hive-3.1.0/
ENV PATH=${PATH}:${HADOOP_HOME}/bin:${HIVE_HOME}/bin
RUN mkdir -p ${HDP_HOME} && \
    cd ${HDP_HOME} && \
    wget -q https://archive.apache.org/dist/hadoop/core/hadoop-3.1.1/hadoop-3.1.1.tar.gz && \
    tar --no-same-owner -xf hadoop-3.1.1.tar.gz && \
    if [ ! -d ${HADOOP_HOME} ]; then mv hadoop-3.1.1 ${HADOOP_HOME}; fi && \
    mkdir -p ${HADOOP_CONF_DIR} && \
    rm hadoop-3.1.1.tar.gz
RUN mkdir -p ${HDP_HOME} && \
    cd ${HDP_HOME} && \
    wget -q https://archive.apache.org/dist/hive/hive-3.1.0/apache-hive-3.1.0-bin.tar.gz && \
    tar --no-same-owner -xf apache-hive-3.1.0-bin.tar.gz && \
    if [ ! -d ${HIVE_HOME} ]; then mv apache-hive-3.1.0-bin ${HIVE_HOME}; fi && \
    mkdir -p ${HIVE_HOME}/conf && \
    rm apache-hive-3.1.0-bin.tar.gz
RUN chown -R jovyan $HDP_HOME

# Add entrypoint scripts
COPY entrypoint.sh /entrypoint.sh
COPY get_configuration.sh /get_configuration.sh
COPY load_configuration.sh /load_configuration.sh

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-utils \
    vim \
    openjdk-8-jre-headless \
    libsasl2-dev libsasl2-2 libsasl2-modules-gssapi-mit \
    jq
RUN apt-get clean

# Install sparkmagic
USER ${NB_USER}
RUN /opt/conda/bin/pip install sparkmagic && \
    export JUPYTERLAB_DIR=/opt/conda/share/jupyter/lab && \
    export JUPYTERLAB_SETTINGS_DIR=/home/jovyan/.jupyter/lab/user-settings && \
    export JUPYTERLAB_WORKSPACES_DIR=/home/jovyan/.jupyter/lab/workspaces && \
    /opt/conda/bin/jupyter labextension install -y --log-level=INFO @jupyter-widgets/jupyterlab-manager && \
    cd "$(pip show sparkmagic|sed -En 's/Location: (.*)$/\1/p')" && \
    jupyter-kernelspec install sparkmagic/kernels/sparkkernel --user && \
    jupyter-kernelspec install sparkmagic/kernels/sparkrkernel --user && \
    jupyter-kernelspec install sparkmagic/kernels/pysparkkernel --user && \
    jupyter serverextension enable --py sparkmagic

# Install bash kernel
RUN /opt/conda/bin/pip install bash_kernel && \
    python -m bash_kernel.install
