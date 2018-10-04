// Commands:
//    shakabot hc:sync-staging-db-from-production

const { spawn } = require('child_process');

module.exports = robot => {
  robot.respond(/hc:sync-staging-db-from-production/i, response => {
    response.send('DB staging sync: start...');
    build = spawn('/bin/bash', ['./scripts/sync_staging_db_from_production.sh']);

    build.stdout.on('close', () => response.send('DB staging sync: done'));
    build.stderr.on('data', data => robot.messageRoom('#bot-log', data.toString()));
  });
};
