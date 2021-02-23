-- IncreaseHighBeamRange
--
-- # Author:  Rival
-- # date: 01.08.2020
-- # update to 1.1 @ 23.02.2021

IncreaseHighBeamRange = {}

function IncreaseHighBeamRange.prerequisitesPresent(specializations)
    return true
end

function IncreaseHighBeamRange.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", IncreaseHighBeamRange)
end

function IncreaseHighBeamRange:onPostLoad(savegame)
	local newHBRange = 80 -- change this for other range
	
	local spec = self.spec_lights
	local function getIsHighBeam(light)
		local isHighBeam = false
		for _, lightType in pairs(light.lightTypes) do
			if lightType == 3 then
				isHighBeam = true
			else
				isHighBeam = false
				break
			end
		end
		return isHighBeam
	end
	local function getIsWorklight(light)
		local isWorklight = false
		for _, lightType in pairs(light.lightTypes) do
			if lightType == 1 or lightType == 2 then
				isWorklight = true
			else
				isWorklight = false
				break
			end
		end
		return isWorklight
	end
	for _,light in pairs(spec.realLights.low.lightTypes) do -- adjust low profile lights
		if getIsHighBeam(light) then
			if not MathUtil.getIsOutOfBounds(getLightRange(light.node), 10, newHBRange) then
				setLightRange(light.node, newHBRange)
			end
		end
		if getIsWorklight(light) then
			if not MathUtil.getIsOutOfBounds(getLightRange(light.node), 10, newHBRange*0.75) then
				setLightRange(light.node, newHBRange*0.75)
			end
		end
	end
	for _,light in pairs(spec.realLights.high.lightTypes) do -- adjust high profile lights
		if getIsHighBeam(light) then
			if not MathUtil.getIsOutOfBounds(getLightRange(light.node), 10, newHBRange) then
				setLightRange(light.node, newHBRange)
			end
			local childrenCount = getNumOfChildren(light.node)
			for i=0, childrenCount-1 do
				local child = getChildAt(light.node, i)
				if getHasClassId(child, ClassIds.LIGHT_SOURCE) then
					if not MathUtil.getIsOutOfBounds(getLightRange(child), 10, newHBRange) then
						setLightRange(child, newHBRange)
					end
				end
			end
		end
		if getIsWorklight(light) then
			if not MathUtil.getIsOutOfBounds(getLightRange(light.node), 10, newHBRange*0.75) then
				setLightRange(light.node, newHBRange*0.75)
			end
			local childrenCount = getNumOfChildren(light.node)
			for i=0, childrenCount-1 do
				local child = getChildAt(light.node, i)
				if getHasClassId(child, ClassIds.LIGHT_SOURCE) then
					if not MathUtil.getIsOutOfBounds(getLightRange(child), 10, newHBRange*0.75) then
						setLightRange(child, newHBRange*0.75)
					end
				end
			end
		end
	end
end
