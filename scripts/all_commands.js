// Commands:
//    shakabot hc:sync-staging-db-from-production
//    shakabot hc:autoclose-toggl

const { spawn } = require('child_process');

module.exports = robot => {
  robot.respond(/hc:sync-staging-db-from-production/i, response => {
    response.send('DB staging sync: start...');
    build = spawn('/bin/bash', ['./scripts/sync_staging_db_from_production.sh']);

    build.stdout.on('close', () => response.send('DB staging sync: done'));
    build.stdout.on('data', data => robot.messageRoom('#bot-log', data.toString()));
    build.stderr.on('data', data => robot.messageRoom('#bot-log', data.toString()));
  });
  robot.respond(/hc:old-sync-staging-db-from-production/i, response => {
    response.send('Old DB staging sync: start...');
    build = spawn('/bin/bash', ['./scripts/old_sync_staging_db_from_production.sh']);

    build.stdout.on('close', () => response.send('Old DB staging sync: done'));
    build.stdout.on('data', data => robot.messageRoom('#bot-log', data.toString()));
    build.stderr.on('data', data => robot.messageRoom('#bot-log', data.toString()));
  });
};
