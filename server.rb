require 'sinatra'
require 'active_resource'

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

- @iterations.each do |iteration|
  %h2{ :id => "Sprint_#{ iteration.number }", :style => 'display:inline' }
    == Sprint #{ iteration.number }
  %i== - ends #{ iteration.finish.strftime("%Y-%m-%d") }
  %a{ :href => "#Sprint_#{iteration.number}", :class => 'anchor'} &nbsp;&para;

  %ul
    - iteration.stories.each do |story|
      %li{ :class => 'story' }
        %h3{ :style => 'display:inline' }
          %i== Story #{story.id} (#{story.current_state})

        %br
        - if story.respond_to?( :tasks )
          %small{ :class => 'taskCount'}
          %i== - #{story.tasks.size} tasks defined

        %p{ :class => 'storyDescription' }
          %span{ :class => 'storyInprogress' }= story.name



