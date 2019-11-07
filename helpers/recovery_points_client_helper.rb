Backups::Plugin.helper do
  def recovery_points_client
    @recovery_points_client ||= Savon.client(wsdl: "#{primary_host}/RecoveryPoints2?wsdl",
                                             basic_auth: [username, password])
  end
end
