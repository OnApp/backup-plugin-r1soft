Backups::Plugin.hook helpers: %i[disk_safe_client_helper policy_client_helper agent_client_helper] do
  def call(virtual_server)
    # http://wiki.r1soft.com/display/CDP/API+-+Deleting+a+Managed+Agent+and+its+Associations

    disk_safe_ids = disk_safe_ids_by_agent(virtual_server.metadata[:agent_id])
    policy_ids = policy_ids_by_disk_safes(disk_safe_ids)

    policy_ids.each { |id| delete_policy!(id) }
    disk_safe_ids.each { |id| delete_disk_safe!(id) }
    delete_agent!(virtual_server.metadata[:agent_id])
  end

  private

  def disk_safe_ids_by_agent(agent_id)
    res = disk_safe_client.call(:get_disk_safes_for_agent, message: {
                                  agent: {
                                    id: agent_id
                                  }
                                }).body[:get_disk_safes_for_agent_response][:return] || []

    res = [res] unless res.is_a?(Array)
    res.map { |ds| ds[:id] }
  end

  def policy_ids_by_disk_safes(disk_safe_ids)
    res = policy_client.call(:get_policies).body[:get_policies_response][:return] || []
    res = [res] unless res.is_a?(Array)

    res.each_with_object([]) do |policy, ids|
      ids << policy[:id] if disk_safe_ids.include?(policy[:disk_safe_id])
    end
  end

  def delete_policy!(id)
    policy_client.call(:delete_policy, message: {
                         policy: {
                           id: id
                         }
                       })
  end

  def delete_disk_safe!(id)
    disk_safe_client.call(:delete_disk_safe, message: {
                            disk_safe: {
                              id: id
                            }
                          })
  end

  def delete_agent!(id)
    agent_client.call(:delete_agent, message: {
                        agent: {
                          id: id
                        }
                      })
  end
end
