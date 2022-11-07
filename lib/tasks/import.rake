desc "import data from airtable"
task :import do
    require_relative '../../app/services/copy_service'
    CopyService.new.fetch_data
end
