puts "ruby started"
Bundler.require

CLUBHOUSE_TOKEN = ENV["CLUBHOUSE_TOKEN"].presence || raise("no env var CLUBHOUSE_TOKEN")
TOGGL_TOKEN= ENV["TOGGL_TOKEN"].presence || raise("no env var TOGGL_TOKEN")

# ShakaCode Workspace
TOGGL_WORKSPACE_ID = ENV["HC_TOGGL_WORKSPACE_ID"].presence || raise("no env var HC_TOGGL_WORKSPACE_ID")
# HC:Dev
TOGGL_PROJECT_ID = ENV["HC_TOGGL_PROJECT_ID"].presence || raise("no env var HC_TOGGL_PROJECT_ID")

toggl = TogglV8::API.new(TOGGL_TOKEN)
clubhouse = Clubhouse::Client.new(api_key: CLUBHOUSE_TOKEN)

toggl_tasks = toggl.tasks(TOGGL_WORKSPACE_ID, active: true).select { |t| t["pid"] == TOGGL_PROJECT_ID }
puts "found #{toggl_tasks.size} active toggl tasks"

toggl_tasks.each do |task|
  ch_id = task["name"].scan(/CH(\d+)/).first&.first&.to_i
  next if ch_id.nil?

  ch_story = clubhouse.story(id: ch_id)
  next puts "Wrong story id !!! #{ch_id}" if ch_story.nil? # e.g. Epics
  next unless ch_story.completed

  toggl.update_task(task["id"], { active: false} )
  puts "Closed #{task["name"]}"
end

puts "ruby finished"
