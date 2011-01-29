require 'sinatra'
require 'active_resource'
require 'haml'

configure :production do
  require 'newrelic_rpm'
end

get '/' do
  haml :index
end

class Iteration < ActiveResource::Base
  self.site = "http://www.pivotaltracker.com/services/v3/projects/:project_id"
end

get '/releaseplan' do
  api_token = params[:api_token]
  project_id = params[:project_id]
  
  Iteration.headers['X-TrackerToken'] = api_token
  current_iteration  = Iteration.find(:all, :params => {:project_id => project_id, :group => "current"})
  iterations_backlog = Iteration.find(:all, :params => {:project_id => project_id, :group => "backlog"})
  @iterations = current_iteration + iterations_backlog

  haml :releaseplan
end