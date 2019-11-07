Backups::Plugin.hook helpers: :disk_safe_client_helper do
  def call(virtual_server)
    devices(virtual_server.metadata[:disk_safe_id]).sum { |d| d[:capacity].to_i }
  end

  private

  def devices(disk_safe_id)
    devices = disk_safe_client.call(:get_disk_safe_by_id, message: {
                                      id: disk_safe_id
                                    }).body[:get_disk_safe_by_id_response][:return][:device_list] || []

    devices.is_a?(Array) ? devices : [devices]
  end
end
