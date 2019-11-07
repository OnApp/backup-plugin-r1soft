Backups::Plugin.hook helpers: %i[agent_client_helper disk_safe_client_helper] do
  PORT = 1167

  def call(virtual_server)
    virtual_server.metadata[:agent_id] = create_agent(virtual_server)[:id]
    virtual_server.metadata[:disk_safe_id] = create_disk_safe(virtual_server)[:id]

    success
  end

  private

  def create_agent(virtual_server)
    agent_client.call(:create_agent_with_object, message: {
                        agent: {
                          description: virtual_server.label,
                          hostname: virtual_server.ip_addresses.first.address,
                          portNumber: PORT
                        }
                      }).body[:create_agent_with_object_response][:return]
  end

  def create_disk_safe(virtual_server)
    disk_safe_client.call(:create_disk_safe_with_object, message: {
                            disksafe: {
                              description: virtual_server.label,
                              path: "/r1soft-backup/onapp-#{virtual_server.identifier}-#{virtual_server.ip_addresses.first&.address}",
                              deviceBackupType: 'AUTO_ADD_DEVICES',
                              backupPartitionTable: true,
                              backupUnmountedDevices: true,
                              agentID: virtual_server.metadata[:agent_id]
                            }
                          }).body[:create_disk_safe_with_object_response][:return]
  end
end
