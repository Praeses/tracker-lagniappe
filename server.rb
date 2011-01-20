require 'sinatra'
require 'active_resource'
require 'haml'

configure :production do
  require 'newrelic_rpm'
end

class Iteration < ActiveResource::Base
  self.site = "http://www.pivotaltracker.com/services/v3/projects/:project_id"
end


get '/:api_token/:project_id' do
  Iteration.headers['X-TrackerToken'] = params[:api_token]
  current_iteration  = Iteration.find(:all, :params => {:project_id => params[:project_id], :group => "current"})
  iterations_backlog = Iteration.find(:all, :params => {:project_id => params[:project_id], :group => "backlog"})
  @iterations = current_iteration + iterations_backlog

  haml :milestones
end

__END__

@@ layout
!!!
%body
  = yield

@@ milestones

%h1  Release Plan

- @iterations.each do |iteration|
  %h2{ :class => 'sprint' } Start #{ iteration.start.strftime("%Y-%m-%d") } - End #{ iteration.finish.strftime("%Y-%m-%d") }

  %ul
    - iteration.stories.each do |story|
      %li{ :class => 'story' } #{story.name}