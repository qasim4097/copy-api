class Api::V1::CopyController < ApplicationController

    def index
        records = CopyService.new(params: copy_params).fetch_data_by_date
        render :json => records
    end

    def find
        record = CopyService.new(params: copy_params).fetch_data_by_key
        render json: record
    end

    def refresh
        CopyService.new.fetch_data
        render json: {value: "data updated successfully"}
    end

    private

    def copy_params
        params.permit(:name, :app, :key, :created_at, :since)
    end
end
