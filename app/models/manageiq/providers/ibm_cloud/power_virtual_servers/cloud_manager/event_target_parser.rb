class ManageIQ::Providers::IbmCloud::PowerVirtualServers::CloudManager::EventTargetParser
  attr_reader :ems_event

  def initialize(ems_event)
    @ems_event = ems_event
  end

  def parse
    targets = []

    case ems_event[:event_type]
    when /^network/
      network_manager = ManageIQ::Providers::IbmCloud::PowerVirtualServers::NetworkManager.find_by(:parent_ems_id => ems_event[:ems_id])
      targets << InventoryRefresh::Target.new(
        :association => :cloud_subnets,
        :manager_ref => {:ems_ref => ems_event[:vm_ems_ref]},
        :manager_id  => network_manager.id,
        :event_id    => ems_event.id
      )
    when /^pvm-instance\.create/
      targets << ems_event.ext_management_system
    when /^pvm-instance\.update/
      targets << ems_event.ext_management_system
    when /^pvm-instance/
      targets << InventoryRefresh::Target.new(
        :association => :vms,
        :manager_ref => {:ems_ref => ems_event[:vm_ems_ref]},
        :manager_id  => ems_event.ext_management_system.id,
        :event_id    => ems_event.id
      )
    when /^volume/
      storage_manager = ManageIQ::Providers::IbmCloud::PowerVirtualServers::StorageManager.find_by(:parent_ems_id => ems_event[:ems_id])
      targets << storage_manager
    end

    targets
  end
end
