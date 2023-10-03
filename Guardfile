guard :shell do
  watch(%r{^markdown_files/(.+)\.md$}) do |m|
    system("ruby process_markdown.rb #{m[0]}")
  end
end