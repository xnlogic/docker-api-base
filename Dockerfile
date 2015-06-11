FROM xnlogic/jruby

ENV APPS_PATH   /opt/xn_apps
ENV XN_BKP_PATH /opt/xn_bkp

ENV M2_REPO       vendor/jars
ENV VENDOR_BUNDLE vendor/bundle

EXPOSE 8080

WORKDIR /app

# NOTE: bundle config contains ref to $VENDOR_BUNDLE value
COPY bundle_config.yml /usr/local/bundle/config
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
