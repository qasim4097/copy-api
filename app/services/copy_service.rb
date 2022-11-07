class CopyService

    API_KEY = ENV["AIRTABLE_API_KEY"]
    APP_KEY = ENV["AIRTABLE_APP_KEY"]
    ENTITY_NAME = ENV["AIRTABLE_ENTITY_NAME"]
    JSON_FILE = ENV["JSON_FILE"]

    def initialize(params: nil)
        Airrecord.api_key = API_KEY
        @copy_table = Airrecord.table(API_KEY, APP_KEY, ENTITY_NAME)
        data = JSON.load(File.open JSON_FILE) if File.exists? JSON_FILE
        @json_data = data ? data["records"] : []
        @params = params
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

    def fetch_data_by_key
        json_data_keys = @json_data.map {|copy| copy["key"]}
        record = @json_data.find { |item| item["key"] == @params[:key] }
        return {error: "key not found"} unless record.present?
        copy_param_keys = @params.except(:key).keys
        copy_str = record["copy"]
        
        for key in json_data_keys
            if copy_str.include? key
                record = @json_data.find { |item| item["key"] == key }
                copy_str.sub!("{#{key}}", record["copy"])
            end
        end

        for param in copy_param_keys
            if copy_str.include? param
                if ["created_at", "updated_at"].include? param
                    copy_str.sub!("{#{param}, datetime}", @params[param])
                end
                copy_str.sub!("{#{param}}", @params[param])
            end
        end
        {value: copy_str}
    end

    def fetch_data_by_date
        since = @params[:since].to_i if @params[:since].present?
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
