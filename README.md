# shakabot

shakabot is a chat bot built on the [Hubot][hubot] framework. It was
initially generated by [generator-hubot][generator-hubot], and configured to be
deployed on [Heroku][heroku] to get you up and running as quick as possible.

This README is intended to help get you started. Definitely update and improve
to talk about your own instance, how to use and deploy, what functionality is
available, etc!

[heroku]: http://www.heroku.com
[hubot]: http://hubot.github.com
[generator-hubot]: https://github.com/github/generator-hubot

## Running shakabot Locally

You can test your hubot by running the following, however some plugins will not
behave as expected unless the [environment variables](#configuration) they rely
upon have been set.

You can start shakabot locally by running:

    % bin/hubot

You'll see some start up output and a prompt:

    [Sat Feb 28 2015 12:38:27 GMT+0000 (GMT)] INFO Using default redis on localhost:6379
    shakabot>

Then you can interact with shakabot by typing `shakabot help`.

    shakabot> shakabot help
    shakabot animate me <query> - The same thing as `image me`, except adds [snip]
    shakabot help - Displays all of the help commands that shakabot knows about.
    ...

### Running in Slack

If you want to test locally with slack:

    % HUBOT_SLACK_TOKEN=xoxb-SLACK-TOCKEN ./bin/hubot --adapter slack

## Persistence

If you are going to use the `hubot-redis-brain` package (strongly suggested),
you will need to add the Redis to Go addon on Heroku which requires a verified
account or you can create an account at [Redis to Go][redistogo] and manually
set the `REDISTOGO_URL` variable.

    % heroku config:add REDISTOGO_URL="..."

If you don't need any persistence feel free to remove the `hubot-redis-brain`
from `external-scripts.json` and you don't need to worry about redis at all.

[redistogo]: https://redistogo.com/

## Running Heroku commands

For running Heroku commands within a shell script we use the following buildpack: https://github.com/heroku/heroku-buildpack-cli

## Running AWS commands

For running AWS commands within a shell script we use the following buildpack: https://github.com/heroku/heroku-buildpack-awscli

## Uptime activity

The bot works in a free dyno. It will be awake for 18 hours thanks to: https://github.com/hubot-scripts/hubot-heroku-keepalive

We need to make sure when to awake the bot: https://github.com/hubot-scripts/hubot-heroku-keepalive#waking-hubot-up

## Restart the bot

You may want to get comfortable with `heroku logs` and `heroku restart` if
you're having issues.
