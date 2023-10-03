# process_markdown.rb
require 'kramdown'

markdown_file = ARGV[0]

if File.basename(markdown_file).casecmp("index.md").zero?
  puts "The file 'index.md' will not be processed."
  exit
end

html_file = markdown_file.gsub('markdown_files', 'public').gsub('.md', '.html')

markdown_content = File.read(markdown_file)
html_content = Kramdown::Document.new(markdown_content).to_html

File.write(html_file, html_content)