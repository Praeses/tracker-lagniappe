require 'sinatra'
require 'active_resource'
require 'erb'

configure :production do
  require 'newrelic_rpm'
end

class Iteration < ActiveResource::Base
  self.site = "http://www.pivotaltracker.com/services/v3/projects/:project_id"
end


get '/:api_token/:project_id' do
  Iteration.headers['X-TrackerToken'] = params[:api_token]
  current_iteration = Iteration.find(:all, :params => {:project_id => params[:project_id], :group => "current"})
  iterations_backlog = Iteration.find(:all, :params => {:project_id => params[:project_id], :group => "backlog"})
  @iterations = current_iteration + iterations_backlog

  erb :milestones
end

__END__

@@ milestones
<html>
<body>
  <% @iterations.each do |iteration| %>
    <h2 id='Sprint_<%= iteration.number %>' style='display:inline'>Sprint <%= iteration.number %></h2><i> - ends <%= iteration.finish.strftime("%Y-%m-%d") %></i><a href='#Sprint_<%= iteration.number %>' class='anchor'>&nbsp;&para;</a>
    <ul>
    <% iteration.stories.each do |story| %>
      <li class='story'><h3 style='displayay:inline'><i>Story <%= story.id %> (<%= story.current_state %>)</i></h3>
      <small class='taskCount'><i><%= " - #{story.tasks.size} tasks defined" if story.respond_to?(:tasks) %></i></small>
        <p class='storyDescription'><span class="storyIngress"><%= story.name%></span><br><span class="storyRest" style="color:grey"></span></p>
      <% end %>
    </ul>
  <% end %>
</body>
</html>
