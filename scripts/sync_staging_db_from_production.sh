# set timestamps for tracking
PS4='\n+\t '

STAGING='hichee-staging'
PRODUCTION='hichee-production'

# delete database if it somehow exists
ADDONS=$(heroku addons --json --app $STAGING)
NEW_DB=$(echo $ADDONS | ruby ./scripts/addon_from_attachment.rb NEW_DATABASE)
if [ "$NEW_DB" != ''  ]
then
  heroku addons:destroy $NEW_DB --confirm $STAGING --app $STAGING
  sleep 5
done

# enable per line tracking
set -x

heroku addons:create heroku-postgresql:standard-2 --as NEW_DATABASE --fork $PRODUCTION::DATABASE_URL --app $STAGING --fast
heroku pg:wait --app $STAGING

# enable raise on any error (only after pg:wait as it)
set -e

set +x

while [ "$(heroku config:get NEW_DATABASE_URL -a hichee-staging)" == ''  ]; do
  echo "Wating for NEW_DATABASE_URL"
  sleep 5
done

ADDONS=$(heroku addons --json --app $STAGING)
NEW_DB=$(echo $ADDONS | ruby ./scripts/addon_from_attachment.rb NEW_DATABASE)
OLD_DB=$(echo $ADDONS | ruby ./scripts/addon_from_attachment.rb DATABASE)
NEW_DB_URL=$(heroku config:get NEW_DATABASE_URL --app $STAGING)
NEW_DB_NAME=$(echo $NEW_DB_URL | awk -F '/' '{print $NF}')

set -x

heroku pg:psql --app $STAGING NEW_DATABASE --command "ALTER DATABASE ${NEW_DB_NAME} SET jit=off;"
heroku pg:psql --app $STAGING NEW_DATABASE --command 'ANALYZE VERBOSE;'

# run migrations over new forked database
heroku run --env DATABASE_URL=$NEW_DB_URL rails db:migrate --app $STAGING

heroku maintenance:on --app $STAGING
heroku ps:scale web=0 worker=0 --app $STAGING

heroku pg:promote $NEW_DB --app $STAGING

heroku addons:destroy $OLD_DB --confirm $STAGING --app $STAGING

heroku addons:attach $NEW_DB --as READONLY --credential readonly --app $STAGING --confirm $STAGING
heroku addons:attach $NEW_DB --as DATABASE_READONLY --credential readonly --app $STAGING --confirm $STAGING
heroku addons:detach NEW_DATABASE --app $STAGING

heroku pg:psql --app $STAGING --command 'GRANT USAGE ON SCHEMA PUBLIC TO readonly;'
heroku pg:psql --app $STAGING --command 'GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO readonly;'
heroku pg:psql --app $STAGING --command 'ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly;'

heroku run rails db:migrate --app $STAGING
heroku run rails runner Rails.cache.clear --app $STAGING
heroku run 'rails runner "Sidekiq.redis(&:flushdb)"' --app $STAGING
heroku run rake stripe_sync:validate_stripe_data --app $STAGING
aws s3 sync --delete s3://hc-activestorage-prod s3://hc-activestorage-staging

heroku ps:scale web=1 worker=1 --app $STAGING
heroku ps:wait --app $STAGING

heroku maintenance:off --app $STAGING
