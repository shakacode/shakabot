const { spawn } = require('child_process');

module.exports = robot => {
  robot.respond(/sync staging db from production/i, response => {
    response.send("Ok. Syncying staging DB...");
    build = spawn('/bin/bash', ['./scripts/test.sh']);

    build.stdout.on('data', (data) => robot.messageRoom('#bot-log', data.toString()));
    build.stderr.on('data', (data) => robot.messageRoom('#bot-log', data.toString()));
  });
};
