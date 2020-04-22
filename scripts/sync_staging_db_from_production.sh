STAGING='hichee-staging'
PRODUCTION='hichee-production'

heroku maintenance:on --app $STAGING
heroku pg:copy $PRODUCTION::DATABASE DATABASE --confirm $STAGING --app $STAGING
heroku run rails db:migrate --app $STAGING
heroku run rails runner Rails.cache.clear --app $STAGING
heroku run 'rails runner "Sidekiq.redis(&:flushdb)"' --app $STAGING
heroku run rake stripe_sync:validate_stripe_data --app $STAGING
aws s3 sync --delete s3://hc-activestorage-prod s3://hc-activestorage-staging
heroku maintenance:off --app $STAGING
