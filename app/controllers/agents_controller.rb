class AgentsController < ApplicationController
  def new
    @agent = Agent.create
  end
end
