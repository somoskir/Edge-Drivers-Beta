local zcl_clusters = require "st.zigbee.zcl.clusters"
local tempMeasurement = zcl_clusters.TemperatureMeasurement
local device_management = require "st.zigbee.device_management"
local tempMeasurement_defaults = require "st.zigbee.defaults.temperatureMeasurement_defaults"

local can_handle = function(opts, driver, device)
  if device:get_manufacturer() == "Samjin" then
    return device:get_manufacturer() == "Samjin"
  elseif device:get_manufacturer() == "HiveHome.com" then
    return device:get_manufacturer() == "HiveHome.com"
  end
end

local function do_configure(self,device)
  print ("subdriver do_configure")
  local maxTime = device.preferences.maxTime * 60
  local changeRep = device.preferences.changeRep
  print ("maxTime y changeRep: ",maxTime, changeRep )
    device:send(device_management.build_bind_request(device, tempMeasurement.ID, self.environment_info.hub_zigbee_eui))
    device:send(tempMeasurement.attributes.MeasuredValue:configure_reporting(device, 30, maxTime, changeRep))
    device:configure()
end

---- Temperature mesure handler
local function temp_attr_handler(self, device, tempvalue, zb_rx)
    tempMeasurement_defaults.temp_attr_handler(self, device, tempvalue, zb_rx)
end

local samjin_sensor = {
    NAME = "MultiSensor",
    lifecycle_handlers = {
      doConfigure = do_configure
    },
    zigbee_handlers = {
      attr = {
        [tempMeasurement.ID] = {
            [tempMeasurement.attributes.MeasuredValue.ID] = temp_attr_handler
        }
      }
    },
    can_handle = can_handle
  }
  
  return samjin_sensor