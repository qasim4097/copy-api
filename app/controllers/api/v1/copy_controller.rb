class Api::V1::CopyController < ApplicationController

    def index
        since_param = copy_params[:since] ? copy_params[:since].to_i : nil
        records = CopyService.new.fetch_data_by_date(since_param)
        render :json => records
    end

    def find
        records = CopyService.new.fetch_data_by_key(copy_params)
        render :json => {value: records}
    end

    def refresh
        CopyService.new.fetch_data
        render :json => {value: "data updated successfully"}
    end

    private

    def copy_params
        params.permit(:name, :app, :key, :created_at, :since)
    end
end
