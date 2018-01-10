class VerifyAgentController < ApplicationController

  require 'net/http'

  set_access_control "update_agent_record" => [:verify]

  def verify
    url = "#{params[:uri]}/verify"
    json = JSONModel::HTTP::get_json(url)
    message = "#{json['status']} (#{json['uri']})"
    if json['status'] == "OK"
      flash[:success] = message
    else
      flash[:error] = message
    end
    redirect_to request.referer
  end

end
