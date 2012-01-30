require 'sinatra'
require 'active_resource'
require 'haml'

configure :production do
  require 'newrelic_rpm'
end

ActiveResource::Base.format = :xml

class Iteration < ActiveResource::Base
  self.site = "https://www.pivotaltracker.com/services/v3/projects/:project_id"
end

get '/' do
  @api_token = request.cookies["api_token"]
  @project_id = request.cookies["project_id"]
  @cost = request.cookies["cost"]
  @rememberme = request.cookies["rememberme"]

  haml :index
end

post '/release_plan' do
  @api_token = params[:api_token]
  @project_id = params[:project_id]
  @cost = params[:cost]
  @rememberme = params[:rememberme]
  @remember_time = Time.now + (60 * 60 * 24 * 14)

  if @rememberme
    response.set_cookie("api_token", :value => @api_token, :expires => @remember_time)
    response.set_cookie("project_id", :value => @project_id, :expires => @remember_time)
    response.set_cookie("cost", :value => @cost, :expires => @remember_time)
    response.set_cookie("rememberme", :value => @rememberme, :expires => @remember_time)
  else
    response.set_cookie("api_token", :expires => Time.now)
    response.set_cookie("project_id", :expires => Time.now)
    response.set_cookie("cost", :expires => Time.now)
    response.set_cookie("rememberme", :expires => Time.now)
  end

  Iteration.headers['X-TrackerToken'] = @api_token

  begin
    current_iteration  = Iteration.find(:all, :params => {:project_id => @project_id, :group => "current"})
    iterations_backlog = Iteration.find(:all, :params => {:project_id => @project_id, :group => "backlog"})
	
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
