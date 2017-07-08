class AgentService < ApplicationRecord
  self.table_name = 'agents_services'

  belongs_to :service
  belongs_to :agent

  def deployable?
    false
  end
end
