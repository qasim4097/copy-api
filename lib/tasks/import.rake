desc "import data from airtable"
task :import do
    require_relative '../../app/services/copy_service'
    CopyService.new.load_data
end
