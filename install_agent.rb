Backups::Plugin.hook helpers: %i[agent_client_helper task_history_client_helper task_helper] do
  def call(virtual_server)
    return success if virtual_server.windows? # agent should be installed manually on windows

    task_id = agent_client.call(:deploy_agent, message: {
                                  deployAgentObject: {
                                    hostname: virtual_server.ip_addresses.first.address,
                                    password: virtual_server.initial_root_password,
                                    rebootAfterInstallation: virtual_server.windows?,
                                    username: virtual_server.username
                                  }
                                }).body[:deploy_agent_response][:return][:id]

    wait_for_task!(task_id)
  end
end
