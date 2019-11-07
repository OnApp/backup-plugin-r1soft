# frozen_string_literal: true

Backups::Plugin.helper do
  STATUSES = {
    success: 'FINISHED',
    progress: 'RUNNING',
    failure: 'ERROR'
  }.freeze

  def wait_for_task!(task_id)
    poller.setup(interval: 10, statuses: STATUSES) do |p|
      p.handle_status(task_status(task_id))
    end.run
  end

  def task_status(task_id)
    task_history_client.call(:get_task_execution_context_by_id, message: {
                               taskExecutionContextID: task_id
                             }).body[:get_task_execution_context_by_id_response][:return][:task_state]
  rescue Savon::SOAPFault
    'UNKNOWN'
  end
end
