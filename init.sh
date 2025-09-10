#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f .env ]]; then
  echo "ERROR: .env not found next to compose.yml"
  exit 1
fi

export $(grep -E '^(MYSQL_ROOT_PASSWORD|MYSQL_DATABASE|MYSQL_USER|MYSQL_PASSWORD|TZ)=' .env | xargs)

DB_URL="mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@db:3306/${MYSQL_DATABASE}?charset=utf8mb4"

if [ -n "$(ls -A app 2>/dev/null)" ]; then
  echo "ERROR: ./app is not empty. Please clean it (even a single .gitignore will block create-project)."
  exit 1
fi

docker compose up -d
docker compose run --rm php composer create-project symfony/skeleton .
docker compose run --rm php composer config extra.symfony.docker false
docker compose run --rm \
  -e DATABASE_URL="$DB_URL" \
  php composer require symfony/orm-pack
docker compose run --rm php composer require --dev symfony/maker-bundle

if grep -q '^###> doctrine/doctrine-bundle ###' app/.env; then
  awk -v repl="###> doctrine/doctrine-bundle ###\nDATABASE_URL=\"${DB_URL}\"\n###< doctrine/doctrine-bundle ###" '
    /^###> doctrine\/doctrine-bundle ###/ {print repl; skip=1; next}
    skip && /^###< doctrine\/doctrine-bundle ###/ {skip=0; next}
    !skip {print}
  ' app/.env > app/.env.tmp && mv app/.env.tmp app/.env
else
  {
    echo '###> doctrine/doctrine-bundle ###'
    echo "DATABASE_URL=\"${DB_URL}\""
    echo '###< doctrine/doctrine-bundle ###'
  } >> app/.env
fi

mkdir -p app/config/packages
cat > app/config/packages/doctrine.yaml <<'YAML'
doctrine:
  dbal:
    url: '%env(resolve:DATABASE_URL)%'
    server_version: '8.4'
  orm:
    auto_generate_proxy_classes: true
    enable_lazy_ghost_objects: true
    mappings:
      App:
        is_bundle: false
        type: attribute
        dir: '%kernel.project_dir%/src/Entity'
        prefix: 'App\\Entity'
        alias: App
YAML

echo
echo "✔ Done. Symfony skeleton installed in ./app"
echo "   App runs at: http://localhost:8080"
echo "   DATABASE_URL used: $DB_URL"