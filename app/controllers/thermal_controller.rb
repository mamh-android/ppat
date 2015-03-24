class ThermalController < ApplicationController
	def index
		@thermal = ThermalRecord.all
  		render :layout=>"ppat"
	end
end