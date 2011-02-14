require 'sinatra'
require 'active_resource'
require 'haml'

configure :production do
  require 'newrelic_rpm'
end

class Iteration < ActiveResource::Base
  self.site = "https://www.pivotaltracker.com/services/v3/projects/:project_id"
end

get '/' do
  haml :index
end

post '/release_plan' do
  api_token = params[:api_token]
  project_id = params[:project_id]

  Iteration.headers['X-TrackerToken'] = api_token

  begin
    current_iteration  = Iteration.find(:all, :params => {:project_id => project_id, :group => "current"})
    iterations_backlog = Iteration.find(:all, :params => {:project_id => project_id, :group => "backlog"})
	
    if !current_iteration.nil? & !iterations_backlog.nil?
      @iterations = current_iteration + iterations_backlog
      if !params[:cost].blank?
        @cost = Float(params[:cost])
      else
        @cost = 0
      end

      @total = @iterations.length * @cost
  
      #@total = number_to_currency(@iterations.length * @cost)

      haml :release_plan
    else
      haml :no_iterations
    end	
	
  rescue ActiveResource::UnauthorizedAccess
    haml :unauthorized
  end
end