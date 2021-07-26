AdditionalCutterCams = {}

function AdditionalCutterCams.prerequisitesPresent(specializations)
    return true
end

function AdditionalCutterCams.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", AdditionalCutterCams)
	SpecializationUtil.registerEventListener(vehicleType, "onPostAttach", AdditionalCutterCams)
	SpecializationUtil.registerEventListener(vehicleType, "onPreDetach", AdditionalCutterCams)
end

function AdditionalCutterCams:onLoad(savegame)
	self.spec_additionalCutterCams = {}
	local spec = self.spec_additionalCutterCams
	spec.cams = {}
	local i = 0
	while true do
		local key = string.format("vehicle.additionalCutterCams.cam(%d)", i)
		if not hasXMLProperty(self.xmlFile, key) then
			break
		end
		local camId = I3DUtil.indexToObject(self.components, getXMLString(self.xmlFile, key.."#node"), self.i3dMappings)
		local position = Utils.getNoNil(getXMLBool(self.xmlFile, key.."#position"), "")
		if camId ~= nil then
			table.insert(spec.cams, {camId, position})
		else
			print(string.format("AdditionalCutterCams error: Invalid cam node '%d'", i))
		end
		i = i + 1
	end
	spec.currentCam = 0
end

function AdditionalCutterCams:onPostAttach(attacherVehicle)
	local spec = self.spec_additionalCutterCams
	if attacherVehicle.addAdditionalCam ~= nil then
		for i,cam in ipairs(spec.cams) do
			attacherVehicle:addAdditionalCam(unpack(cam))
		end
	end
end

function AdditionalCutterCams:onPreDetach(attacherVehicle)
	local spec = self.spec_additionalCutterCams
	if attacherVehicle.removeAdditionalCam ~= nil then
		for i,cam in ipairs(spec.cams) do
			attacherVehicle:removeAdditionalCam(unpack(cam))
		end
	end
end
