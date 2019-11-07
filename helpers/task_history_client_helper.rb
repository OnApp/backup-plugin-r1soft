Backups::Plugin.helper do
  def task_history_client
    @task_history_client ||= Savon.client(wsdl: "#{primary_host}/TaskHistory?wsdl",
                                          basic_auth: [username, password])
  end
end
