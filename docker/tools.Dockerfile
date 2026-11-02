# PHP checking tools for scripts/run-tool.sh. Runs without network against a read-only project.
FROM composer:2
WORKDIR /tools
RUN composer init --no-interaction --name=vibecode-help/tools \
 && composer config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true \
 && composer config --no-plugins allow-plugins.phpstan/extension-installer true \
 && composer require --no-interaction wp-coding-standards/wpcs:3.4.1 phpstan/phpstan:2.3.4 szepeviktor/phpstan-wordpress:2.0.4 phpstan/extension-installer:1.4.3
ENV PATH="/tools/vendor/bin:$PATH"
WORKDIR /src
