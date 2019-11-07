Backups::Plugin.helper do
  def policy_client
    @policy_client ||= Savon.client(wsdl: "#{primary_host}/Policy2?wsdl",
                                    basic_auth: [username, password])
  end
end
