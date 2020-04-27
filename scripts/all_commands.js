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
  robot.respond(/hc:autoclose-toggl/i, response => {
    response.send('HC autoclose toggl: start...');
    build = spawn('bundle', ['exec', 'ruby', 'scripts/autoclose_toggl.rb']);

    build.stdout.on('close', () => response.send('HC autoclose toggl: done'));
    build.stdout.on('data', data => response.send(data.toString()));
    build.stderr.on('data', data => response.send(data.toString()));
    build.stdout.on('data', data => robot.messageRoom('#bot-log', data.toString()));
    build.stderr.on('data', data => robot.messageRoom('#bot-log', data.toString()));
  });
};
