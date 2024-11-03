self = false
include_files = { "./src/**/*.lua", "./test/**/*.lua" }
exclude_files = {
  "./test/**/failed_test.lua",
  "./src/laura/reporters/coverage/html/template.lua",
}
max_line_length = 80
