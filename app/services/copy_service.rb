class CopyService

    API_KEY = ENV["AIRTABLE_API_KEY"]
    APP_KEY = ENV["AIRTABLE_APP_KEY"]
    ENTITY_NAME = ENV["AIRTABLE_ENTITY_NAME"]
    JSON_FILE = ENV["JSON_FILE"]

    def initialize
        Airrecord.api_key = API_KEY
        @copy_table = Airrecord.table(API_KEY, APP_KEY, ENTITY_NAME)
        data = JSON.load(File.open JSON_FILE) if File.exists? JSON_FILE
        @json_data = data ? data["records"] : []
    end

    def fetch_data
        copy_arr = []
        @copy_table.all.each do |item|
            record = @json_data.find { |copy| copy["key"] == item.fields["Key"] }
            if record.nil?
                record = {
                    :key => item.fields["Key"],
                    :copy => item.fields["Copy"],
                    :last_updated => Time.now.to_i
                }
            else
                record[:copy] = item.fields["Copy"]
                record[:last_updated] = Time.now.to_i if item.fields["Copy"] != record["copy"]
            end
            copy_arr << record
        end
        copy_json = {
            records: copy_arr
        }
        write_json_to_file(copy_json)
    end

    def fetch_data_by_key(copy_params = {})
        json_data_keys = @json_data.map {|copy| copy["key"]}
        filtered_copy_data = @json_data.find { |item| item["key"] == copy_params[:key] }
        copy_param_keys = copy_params.keys
        copy_param_keys.delete("key")
        copy_data = filtered_copy_data["copy"] if filtered_copy_data
        
        for key in json_data_keys
            if copy_data.include? key
                filtered_copy_data = @json_data.find { |item| item["key"] == key }
                copy_data.sub!("{#{key}}", filtered_copy_data["copy"])
            end
        end

        for param in copy_param_keys
            if copy_data.include? param
                if ["created_at", "updated_at"].include? param
                    copy_data.sub!("{#{param}, datetime}", copy_params[param])
                end
                copy_data.sub!("{#{param}}", copy_params[param])
            end
        end
        copy_data
    end

    def fetch_data_by_date(since)
        records = since ? @json_data.filter { |item| item["last_updated"] >= since }  : @json_data
        records.map {|item| {:key => item["key"], :copy => item["copy"]}}
    end

    private

    def write_json_to_file(json)
        File.open(JSON_FILE,"w") do |f|
            f.write(json.to_json)
        end
    end
end
