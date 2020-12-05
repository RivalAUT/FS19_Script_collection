-- IncreaseHighBeamRange
--
-- # Author:  Rival
-- # date: 01.08.2020

IncreaseHighBeamRange = {}

function IncreaseHighBeamRange.prerequisitesPresent(specializations)
    return true
end

function IncreaseHighBeamRange.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", IncreaseHighBeamRange)
end

function IncreaseHighBeamRange:onPostLoad(savegame)
	local newHBRange = 70 -- change this for other range
	
	local spec = self.spec_lights
	local function getIsHighBeam(light)
		local isHighBeam = false
		for _, lightType in pairs(light.lightTypes) do
			if lightType == 3 then
				isHighBeam = true
				--break
			else
				isHighBeam = false
				break
			end
		end
		return isHighBeam
	end
	for _,light in pairs(spec.realLights.low.lightTypes) do -- adjust low profile lights
		if getIsHighBeam(light) then
			if getLightRange(light.node) < newHBRange then
				setLightRange(light.node, newHBRange)
			end
		end
	end
	for _,light in pairs(spec.realLights.high.lightTypes) do -- adjust high profile lights
		if getIsHighBeam(light) then
			if getLightRange(light.node) < newHBRange then
				setLightRange(light.node, newHBRange)
			end
			local childrenCount = getNumOfChildren(light.node)
			for i=0, childrenCount-1 do
				local child = getChildAt(light.node, i)
				if getHasClassId(child, ClassIds.LIGHT_SOURCE) then
					if getLightRange(child) < newHBRange then
						setLightRange(child, newHBRange)
					end
				end
			end
		end
	end
end
