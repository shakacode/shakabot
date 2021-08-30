# enable raise on any error
set -e

# set timestamps for tracking
PS4='\n+\t '

# enable per line tracking
set -x

STAGING='hichee-staging'
PRODUCTION='hichee-production'

heroku addons:create heroku-postgresql:standard-2 --as NEW_DATABASE --fork $PRODUCTION::DATABASE_URL --app $STAGING --fast
heroku pg:wait --app $STAGING
heroku ps:wait --app $STAGING

set +x
ADDONS=$(heroku addons --json --app $STAGING)
NEW_DB=$(echo $ADDONS | ruby ./scripts/addon_from_attachment.rb NEW_DATABASE)
OLD_DB=$(echo $ADDONS | ruby ./scripts/addon_from_attachment.rb DATABASE)
NEW_DB_NAME=$(heroku config:get NEW_DATABASE_URL --app $STAGING | awk -F '/' '{print $NF}')
set -x

heroku pg:psql --app $STAGING NEW_DATABASE --command "ALTER DATABASE ${NEW_DB_NAME} SET jit=off;"
heroku pg:psql --app $STAGING NEW_DATABASE --command 'ANALYZE VERBOSE;'

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
