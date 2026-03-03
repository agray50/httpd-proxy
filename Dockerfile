FROM registry.access.redhat.com/ubi9/httpd-24:latest

USER root

# Remove all default conf.d files and create mount points for Secret-mounted
# certificates. GID 0 ownership + group-readable permissions ensures the
# directories are accessible regardless of which UID OpenShift assigns at runtime.
RUN rm -f \
    /etc/httpd/conf.d/ssl.conf \
    /etc/httpd/conf.d/welcome.conf \
    /etc/httpd/conf.d/autoindex.conf \
    /etc/httpd/conf.d/userdir.conf \
    /etc/httpd/conf.d/auth_mellon.conf \
    /etc/httpd/conf.d/mod_security.conf \
    /etc/httpd/conf.d/rhel-snipolicy.conf \
    && mkdir -p /etc/httpd/ssl/server \
    && mkdir -p /etc/httpd/ssl/ca \
    && chown -R 1001:0 /etc/httpd/ssl \
    && chmod -R g+rX   /etc/httpd/ssl

# Run as non-root (satisfies OpenShift restricted SCC)
USER 1001

# Only mTLS/HTTPS is exposed
EXPOSE 8443

# Run httpd directly, bypassing the S2I wrapper scripts.
# The proxy.conf ConfigMap handles all configuration including Listen 8443.
CMD ["httpd", "-D", "FOREGROUND"]
