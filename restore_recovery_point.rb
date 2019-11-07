Backups::Plugin.hook helpers: %i[agent_client_helper recovery_points_client_helper task_history_client_helper task_helper] do
  def call(recovery_point, virtual_server)
    ssh_caller.call('/etc/init.d/cdp-agent restart')

    sleep 30 # after /etc/init.d/cdp-agent restart the agent might still be unreachable

    devices = devices_on_agent(virtual_server.metadata[:agent_id])
    recovery_point_device_ids = recovery_point.metadata[:devices].map { |d| d[:unique_id] }

    devices_to_send = devices.each_with_object([]) do |d, result|
      if recovery_point_device_ids.include?(d[:content_id])
        result << { entry: { key: d[:content_id], value: d[:device_path] } }
      end
    end

    task_id = schedule_restore(recovery_point.metadata[:id], virtual_server.metadata[:disk_safe_id], devices_to_send)

    wait_for_task!(task_id)
  end

  private

  def devices_on_agent(agent_id)
    # devices save in recovery point metadata are not the same since vs is booted in recovery mode right now
    devices = agent_client.call(:get_all_devices_from_agent, message: {
                                  agent: {
                                    id: agent_id
                                  }
                                }).body[:get_all_devices_from_agent_response][:return] || []

    devices.is_a?(Array) ? devices : [devices]
  end

  def schedule_restore(recovery_point_id, disk_safe_id, devices)
    recovery_points_client.call(:do_bare_metal_restore, message: { bare_metal_restore_options: {
                                  diskSafeId: disk_safe_id,
                                  recoveryPointId: recovery_point_id,
                                  fileSystemMap: devices
                                } }).body[:do_bare_metal_restore_response][:return][:id]
  end
end
