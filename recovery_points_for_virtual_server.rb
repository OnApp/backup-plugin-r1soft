Backups::Plugin.hook helpers: :recovery_points_client_helper do
  def call(virtual_server)
    recovery_points_on_disk_safe(virtual_server.metadata[:disk_safe_id]).map do |rc|
      devices = rc[:devices].is_a?(Array) ? rc[:devices] : [rc[:devices]]

      build_recovery_point(size: devices.sum { |d| d[:size].to_i },
                           created_at: Time.at(rc[:created_on_timestamp_in_millis].to_i / 1000),
                           updated_at: Time.at(rc[:created_on_timestamp_in_millis].to_i / 1000),
                           state: rc[:recovery_point_state].downcase).tap do |r|
        r.metadata[:id] = rc[:recovery_point_id]
        r.metadata[:devices] = devices.map { |device| { unique_id: device[:unique_id], device_path: device[:device_path] } }
      end
    end
  end

  private

  def recovery_points_on_disk_safe(disk_safe_id)
    res = recovery_points_client.call(:get_recovery_points, message: {
                                        diskSafeID: disk_safe_id,
                                        includeMerged: true
                                      }).body[:get_recovery_points_response][:return] || []

    res.is_a?(Array) ? res : [res]
  end
end
