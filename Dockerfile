FROM quay.io/pypa/${INPUT_MANYLINUX_IMAGE}

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
