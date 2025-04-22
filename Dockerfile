from quay.io/singularity/singularity:v4.1.0

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

ENV HOME="/home/${NB_USER}"
RUN mkdir -p "/home"

# Create NB_USER with name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su
RUN adduser -s /bin/bash -D -h "${HOME}" -u "${NB_UID}" "${NB_USER}"
COPY jupyterhub_singleuser.sif /home/jovyan/jupyterhub_singleuser.sif

RUN apk add --no-cache fuse

RUN chmod g+w /etc/passwd && \
    fix-permissions "${HOME}"

USER ${NB_UID}

WORKDIR "${HOME}"

CMD ["exec", "/home/jovyan/jupyterhub_singleuser.sif", "jupyterhub-singleuser"]
# ENTRYPOINT ["/bin/sh", "-c"]
# CMD ["sleep 1h"]
