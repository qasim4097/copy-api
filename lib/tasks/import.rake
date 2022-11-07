desc "import data from airtable"
task :import do
    require "app/service/copy_service.rb"
    CopyService.new.fetch_data
end
