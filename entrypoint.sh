#!/usr/bin/env bash
set -e
cd /var/www/html

if [ ! -f composer.json ]; then
  echo ">> Creating TYPO3 ${TYPO3_VERSION} project..."
  composer create-project "typo3/cms-base-distribution:${TYPO3_VERSION}" /tmp/typo3 --no-interaction
  cp -a /tmp/typo3/. /var/www/html/
  rm -rf /tmp/typo3
fi

if [ ! -d vendor ]; then
  echo ">> Installing dependencies..."
  composer install --no-interaction
fi

if [ ! -f config/system/settings.php ]; then
  if [ "${AUTO_SETUP}" = "1" ]; then
    echo ">> Running non-interactive TYPO3 setup..."
    vendor/bin/typo3 setup \
      --driver=mysqli \
      --host="${DB_HOST}" \
      --port="${DB_PORT}" \
      --dbname="${DB_NAME}" \
      --username="${DB_USER}" \
      --password="${DB_PASSWORD}" \
      --admin-username="${ADMIN_USER}" \
      --admin-user-password="${ADMIN_PASSWORD}" \
      --admin-email="${ADMIN_EMAIL}" \
      --project-name="${PROJECT_NAME}" \
      --create-site="${BASE_URL}" \
      --server-type=apache \
      --no-interaction
  else
    echo ">> Enabling the web installer (visit /typo3/install.php)."
    mkdir -p public && touch public/FIRST_INSTALL
  fi
fi

chown -R www-data:www-data /var/www/html
exec "$@"
