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
  @cost = Float(params[:cost])

  Iteration.headers['X-TrackerToken'] = api_token
  current_iteration  = Iteration.find(:all, :params => {:project_id => project_id, :group => "current"})
  iterations_backlog = Iteration.find(:all, :params => {:project_id => project_id, :group => "backlog"})
  @iterations = current_iteration + iterations_backlog
  
  @total = @iterations.length * @cost
  
  #@total = number_to_currency(@iterations.length * @cost)

  haml :release_plan
end