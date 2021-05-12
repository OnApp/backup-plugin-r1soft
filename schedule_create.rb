Backups::Plugin.hook helpers: %i[policy_client_helper] do
  def call(schedule, virtual_server)
    policy_client.call(:create_policy, message: {
                         policy: {
                           enabled: true,
                           name: schedule.id,
                           description: schedule.period,
                           diskSafeID: virtual_server.metadata[:disk_safe_id],
                           replicationScheduleFrequencyType: schedule.period.upcase,
                           replicationScheduleFrequencyValues: {
                             daysOfMonth: -1,
                             hoursOfDay: (0..23).to_a,
                             startingHour: 1,
                             startingMinute: 0
                           },
                           mergeScheduleFrequencyValues: {
                             daysOfMonth: -1,
                             hoursOfDay: 2,
                             startingHour: 1,
                             startingMinute: 0
                           },
                           mergeScheduleFrequencyType: 'DAILY',
                           recoveryPointLimit: 10,
                           forceFullBlockScan: false,
                           multiVolumeSnapshot: true,
                           diskSafeVerificationScheduleFrequencyType: 'DAILY',
                           diskSafeVerificationScheduleFrequencyValues: {
                             daysOfMonth: -1,
                             hoursOfDay: 3,
                             startingHour: 1,
                             startingMinute: 15
                           }
                         }
                       })

    # policy_id = res.body[:create_policy_response][:return][:id]

    success
  end
end
