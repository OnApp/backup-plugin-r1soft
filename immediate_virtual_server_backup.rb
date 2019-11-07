Backups::Plugin.hook helpers: %i[policy_client_helper task_history_client_helper task_helper] do
  def call(virtual_server)
    task_id = schedule_backup(virtual_server.metadata[:disk_safe_id])

    wait_for_task!(task_id)
  end

  private

  def policy_id_of_disk_safe(disk_safe_id)
    policy_client.call(:get_policy_by_disk_safe_id, message: {
                         id: disk_safe_id
                       }).body[:get_policy_by_disk_safe_id_response][:return][:id]
  end

  def schedule_backup(disk_safe_id)
    policy_client.call(:run_policy_by_id, message: {
                         policyID: policy_id_of_disk_safe(disk_safe_id)
                       }).body[:run_policy_by_id_response][:return][:id]
  end
end
