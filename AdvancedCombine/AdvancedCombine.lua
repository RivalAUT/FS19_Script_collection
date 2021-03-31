--
-- advancedCombine Specialization for Vehicles
-- V 19.0
-- @author Rival
-- @date 06/2020

advancedCombine = {}
advancedCombine.modName = g_currentModName
local modDirectory  = g_currentModDirectory

function advancedCombine.prerequisitesPresent(specializations)
    return true
end

function advancedCombine.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", advancedCombine)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", advancedCombine)
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", advancedCombine)
	SpecializationUtil.registerEventListener(vehicleType, "onDraw", advancedCombine)
	SpecializationUtil.registerEventListener(vehicleType, "onDelete", advancedCombine)
	
	advancedCombine.ModifierType = g_soundManager:registerModifierType("ROTOR_RPM", advancedCombine.getRotorRpm, advancedCombine.getMinRotorRpm, advancedCombine.getMaxRotorRpm)
	advancedCombine.ModifierType2 = g_soundManager:registerModifierType("CAMERA_ROTATION", advancedCombine.getCameraRot, advancedCombine.getMinCamRot, advancedCombine.getMaxCamRot)
	advancedCombine.ModifierType3 = g_soundManager:registerModifierType("CHOPPER_VOLUME", advancedCombine.getChopperVolume, advancedCombine.getMinChopperVolume, advancedCombine.getMaxChopperVolume)
end

function advancedCombine.registerFunctions(vehicleType)
	SpecializationUtil.registerFunction(vehicleType, "calculateSpill", advancedCombine.calculateSpill)
	SpecializationUtil.registerFunction(vehicleType, "getCorrectGrainTypeSelection", advancedCombine.getCorrectGrainTypeSelection)
end

--function advancedCombine.registerOverwrittenFunctions(vehicleType)
--	SpecializationUtil.registerOverwrittenFunction(vehicleType, "getPtoRpm", advancedCombine.getPtoRpm)
--end

function advancedCombine:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    if self.isClient then
        local spec = self.spec_advancedCombine
		spec.actionEvents = {}
        self:clearActionEventsTable(spec.actionEvents)

        if self:getIsActiveForInput(true, true) then														--- triggerUp, triggerDown, triggerAlways, startActive, callbackState
            local _, actionShowHUDEventId = self:addActionEvent(spec.actionEvents, InputAction.SHOW_SPILL_HUD, self, advancedCombine.processActionEvent, false, true, false, true)
            local _, actionToggleDisplayModeEventId = self:addActionEvent(spec.actionEvents, InputAction.TOGGLE_DISPLAY_MODE, self, advancedCombine.processActionEvent, false, true, false, true)
			local _, actionChangeThresherRPMEventId = self:addActionEvent(spec.actionEvents, InputAction.AXIS_THRESHER_RPM, self, advancedCombine.actionEventThresherRPM, false, true, true, true)
			local _, actionChangeConcaveEventId = self:addActionEvent(spec.actionEvents, InputAction.AXIS_CONCAVE, self, advancedCombine.actionEventConcave, false, true, false, true)
			local _, actionChangeWindRPMEventId = self:addActionEvent(spec.actionEvents, InputAction.AXIS_WIND_RPM, self, advancedCombine.actionEventWindRPM, false, true, false, true)
			local _, actionChangeSieveEventId = self:addActionEvent(spec.actionEvents, InputAction.AXIS_SIEVE, self, advancedCombine.actionEventSieve, false, true, false, true)
			
			spec.actionEventIds = {actionChangeThresherRPMEventId, actionChangeConcaveEventId, actionChangeWindRPMEventId, actionChangeSieveEventId}

            g_inputBinding:setActionEventTextPriority(actionShowHUDEventId, GS_PRIO_HIGH)
			g_inputBinding:setActionEventTextVisibility(actionShowHUDEventId, true)
			
			g_inputBinding:setActionEventText(actionChangeThresherRPMEventId, g_i18n:getText("action_CHANGE_THRESHER_RPM"))
			g_inputBinding:setActionEventText(actionChangeConcaveEventId, g_i18n:getText("action_CHANGE_CONCAVE"))
			g_inputBinding:setActionEventText(actionChangeWindRPMEventId, g_i18n:getText("action_CHANGE_WIND_RPM"))
			g_inputBinding:setActionEventText(actionChangeSieveEventId, g_i18n:getText("action_CHANGE_SIEVE"))
            g_inputBinding:setActionEventTextPriority(actionChangeThresherRPMEventId, GS_PRIO_HIGH)
            g_inputBinding:setActionEventTextPriority(actionChangeConcaveEventId, GS_PRIO_HIGH)
            g_inputBinding:setActionEventTextPriority(actionChangeWindRPMEventId, GS_PRIO_HIGH)
            g_inputBinding:setActionEventTextPriority(actionChangeSieveEventId, GS_PRIO_HIGH)
			
			for k,eventId in pairs(spec.actionEventIds) do
				g_inputBinding:setActionEventTextVisibility(eventId, false)
			end
        end
    end
end

function advancedCombine:onLoad(savegame)
	self.spec_advancedCombine = {}
	local spec = self.spec_advancedCombine
	
	
	spec.grainTypeSwitch = I3DUtil.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.advancedCombine.grainTypeSwitch#node"), self.i3dMappings)
	spec.grainTypeSwitchRotation = {}
	if spec.grainTypeSwitch ~= nil then
		spec.grainTypeSwitchRotation[1], spec.grainTypeSwitchRotation[2], spec.grainTypeSwitchRotation[3] = getRotation(spec.grainTypeSwitch)
	end
	
	spec.grainTypes = {}
	spec.combineSettings = {}
	spec.combineSettings.baseInfos = {}
	
	local settingsKey = "vehicle.advancedCombine.combineSettings"
	local concaveMin = getXMLInt(self.xmlFile, settingsKey..".concave#min")
	local concaveMax = getXMLInt(self.xmlFile, settingsKey..".concave#max")
	local concaveChangeStep = Utils.getNoNil(getXMLInt(self.xmlFile, settingsKey..".concave#changeStep"), 1)
	spec.combineSettings.baseInfos.concave = {min=concaveMin, max=concaveMax, changeStep=concaveChangeStep}
	
	local windMin = getXMLInt(self.xmlFile, settingsKey..".wind#min")
	local windMax = getXMLInt(self.xmlFile, settingsKey..".wind#max")
	local windChangeStep = Utils.getNoNil(getXMLInt(self.xmlFile, settingsKey..".wind#changeStep"), 1)
	spec.combineSettings.baseInfos.wind = {min=windMin, max=windMax, changeStep=windChangeStep}
	
	local sieveMin = getXMLInt(self.xmlFile, settingsKey..".sieve#min")
	local sieveMax = getXMLInt(self.xmlFile, settingsKey..".sieve#max")
	local sieveChangeStep = Utils.getNoNil(getXMLInt(self.xmlFile, settingsKey..".sieve#changeStep"), 1)
	spec.combineSettings.baseInfos.sieve = {min=sieveMin, max=sieveMax, changeStep=sieveChangeStep}
	
	local drumMin = getXMLInt(self.xmlFile, settingsKey..".threshingDrum#min")
	local drumMax = getXMLInt(self.xmlFile, settingsKey..".threshingDrum#max")
	local drumChangeSpeed = Utils.getNoNil(getXMLInt(self.xmlFile, settingsKey..".threshingDrum#changeSpeed"), 1)
	spec.combineSettings.baseInfos.threshingDrum = {min=drumMin, max=drumMax, changeSpeed=drumChangeSpeed}
	
	local i = 0
	while true do
		local key = string.format("vehicle.advancedCombine.grainTypes.grainType(%d)", i)
		if not hasXMLProperty(self.xmlFile, key) then
			break
		end
		i = i + 1
		spec.grainTypes[i] = {}
		spec.grainTypes[i].threshingDrumSpeed = math.min(math.max(getXMLInt(self.xmlFile, key.."#threshingDrumSpeed"), spec.combineSettings.baseInfos.threshingDrum.min), spec.combineSettings.baseInfos.threshingDrum.max)
		spec.grainTypes[i].concave = math.min(math.max(getXMLInt(self.xmlFile, key.."#concave"), spec.combineSettings.baseInfos.concave.min), spec.combineSettings.baseInfos.concave.max)
		spec.grainTypes[i].wind = math.min(math.max(getXMLInt(self.xmlFile, key.."#wind"), spec.combineSettings.baseInfos.wind.min), spec.combineSettings.baseInfos.wind.max)
		spec.grainTypes[i].sieve = math.min(math.max(getXMLInt(self.xmlFile, key.."#sieve"), spec.combineSettings.baseInfos.sieve.min), spec.combineSettings.baseInfos.sieve.max)
		spec.grainTypes[i].fruitTypes = {}
        local types = StringUtil.splitString(" ", StringUtil.trim(getXMLString(self.xmlFile, key.."#fruitTypes")))
        for k,v in pairs(types) do
            local desc = g_fruitTypeManager:getFruitTypeByName(v)
            if desc ~= nil then
                spec.grainTypes[i].fruitTypes[desc.index] = desc.name
            end
        end
	end
	
	--spec.augerOnLight = I3DUtil.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.advancedCombine.augerOnLight#node"), self.i3dMappings)
	--spec.isUnloading = false
	
	local rotationPartNodeSpillnadel = I3DUtil.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.advancedCombine.rotationPartSpillnadel#node"), self.i3dMappings)
    if rotationPartNodeSpillnadel ~= nil then
        spec.rotationPartSpillnadel = {}
        spec.rotationPartSpillnadel.node = rotationPartNodeSpillnadel

        local x, y, z = StringUtil.getVectorFromString(getXMLString(self.xmlFile, "vehicle.advancedCombine.rotationPartSpillnadel#minRot"))
        spec.rotationPartSpillnadel.minRot = {}
        spec.rotationPartSpillnadel.minRot[1] = MathUtil.degToRad(Utils.getNoNil(x, 0))
        spec.rotationPartSpillnadel.minRot[2] = MathUtil.degToRad(Utils.getNoNil(y, 0))
        spec.rotationPartSpillnadel.minRot[3] = MathUtil.degToRad(Utils.getNoNil(z, 0))

        x, y, z = StringUtil.getVectorFromString(getXMLString(self.xmlFile, "vehicle.advancedCombine.rotationPartSpillnadel#maxRot"))
        spec.rotationPartSpillnadel.maxRot = {}
        spec.rotationPartSpillnadel.maxRot[1] = MathUtil.degToRad(Utils.getNoNil(x, 0))
        spec.rotationPartSpillnadel.maxRot[2] = MathUtil.degToRad(Utils.getNoNil(y, 0))
        spec.rotationPartSpillnadel.maxRot[3] = MathUtil.degToRad(Utils.getNoNil(z, 90))
    end
	
	spec.spillValue = 0
	spec.lastSpill = 0
	spec.rawSpillValue = 0
	
	if self.loadDashboardsFromXML ~= nil then
		self:loadDashboardsFromXML(self.xmlFile, "vehicle.advancedCombine.dashboards", {valueTypeToLoad = "speedRotorRPM", valueObject = spec, valueFunc = "speedDisplayLastValue", minFunc = 0, maxFunc = 2500})
	end
	spec.actualRotorSpeedValue = 0
	spec.actualWindSpeedValue = 0
	spec.rotorSpeedAdjustment = 0
	spec.displayModeSpeed = true
	
	local curConcaveSetting = spec.combineSettings.baseInfos.concave.min
	local curWindSetting = spec.combineSettings.baseInfos.wind.min
	local curSieveSetting = spec.combineSettings.baseInfos.sieve.min
	local curThreshingDrumSpeed = spec.combineSettings.baseInfos.threshingDrum.min
	if savegame ~= nil then
		--[[spec.rotorSpeedValue = Utils.getNoNil(getXMLFloat(savegame.xmlFile, string.format("%s.%s.advancedCombine#rotorSpeed", savegame.key, modName)), spec.rotorSpeedValue)
		curConcaveSetting = Utils.getNoNil(getXMLInt(savegame.xmlFile, string.format("%s.%s.advancedCombine#concave", savegame.key, modName)), curConcaveSetting)
		curWindSetting = Utils.getNoNil(getXMLInt(savegame.xmlFile, string.format("%s.%s.advancedCombine#wind", savegame.key, modName)), curWindSetting)
		curSieveSetting = Utils.getNoNil(getXMLInt(savegame.xmlFile, string.format("%s.%s.advancedCombine#sieve", savegame.key, modName)), curSieveSetting)]]
		curThreshingDrumSpeed = Utils.getNoNil(getXMLFloat(savegame.xmlFile, string.format("%s.%s.advancedCombine#threshingDrum", savegame.key, advancedCombine.modName)), curThreshingDrumSpeed)
		curConcaveSetting = Utils.getNoNil(getXMLInt(savegame.xmlFile, string.format("%s.%s.advancedCombine#concave", savegame.key, advancedCombine.modName)), curConcaveSetting)
		curWindSetting = Utils.getNoNil(getXMLInt(savegame.xmlFile, string.format("%s.%s.advancedCombine#wind", savegame.key, advancedCombine.modName)), curWindSetting)
		curSieveSetting = Utils.getNoNil(getXMLInt(savegame.xmlFile, string.format("%s.%s.advancedCombine#sieve", savegame.key, advancedCombine.modName)), curSieveSetting)
	end
	spec.combineSettings.currentSetting = {concave=curConcaveSetting, wind=curWindSetting, sieve=curSieveSetting, threshingDrum=curThreshingDrumSpeed}
	
	--if spec.grainTypeSwitch ~= nil then
	--	setRotation(spec.grainTypeSwitch, spec.grainTypeSwitchRotation[1], spec.grainTypes[spec.threasherGrainTypeSelection].switchRotation, spec.grainTypeSwitchRotation[3])
	--end
	--setVisibility(spec.augerOnLight, false)
	spec.speedDisplayDot = I3DUtil.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.advancedCombine.speedDisplayDot#node"), self.i3dMappings)
	if spec.speedDisplayDot ~= nil then
		setVisibility(spec.speedDisplayDot, spec.displayModeSpeed)
	end
	
	spec.speedDisplayTimeout = 0
	spec.speedDisplayLastValue = 0
	
	spec.engineRpm = 212.5
	spec.engineSpeedAdjustment = 0
	
	spec.showHud = false
	
	spec.thresherSoundSample = g_soundManager:loadSampleFromXML(self.xmlFile, "vehicle.advancedCombine", "thresherSound", self.baseDirectory, self.components[1].node, 1, AudioGroup.VEHICLE, nil, self)
	spec.chopperSoundSample = g_soundManager:loadSampleFromXML(self.xmlFile, "vehicle.advancedCombine", "chopperSound", self.baseDirectory, self.components[1].node, 1, AudioGroup.VEHICLE, nil, self)
	spec.chopperSoundVolumeCoeff = 0
	
	spec.hud = {}
	local uiScale = g_gameSettings.uiScale
	local w, h = getNormalizedScreenValues(400 * uiScale, 200 * uiScale)
	local w2, h2 = getNormalizedScreenValues(25 * uiScale, 25 * uiScale)
	local baseX = 1-(g_safeFrameOffsetX/2)-w
	local baseY = 0.6
	spec.hud.main = Overlay:new(modDirectory .. "achud.dds", baseX, baseY, w, h)
	local imagePath = modDirectory .. "acicons.dds"
	spec.hud.icon1 = Overlay:new(imagePath, baseX, baseY-0.04, w2, h2) --drum
    spec.hud.icon1:setUVs(getNormalizedUVs({0,0,64,64}, {256,64}))
	spec.hud.icon2 = Overlay:new(imagePath, baseX+w2, baseY-0.04, w2, h2) --concave
    spec.hud.icon2:setUVs(getNormalizedUVs({64,0,64,64}, {256,64}))
	spec.hud.icon3 = Overlay:new(imagePath, baseX+w2*2, baseY-0.04, w2, h2) --wind
    spec.hud.icon3:setUVs(getNormalizedUVs({128,0,64,64}, {256,64}))
	spec.hud.icon4 = Overlay:new(imagePath, baseX+w2*3, baseY-0.04, w2, h2) --sieve
    spec.hud.icon4:setUVs(getNormalizedUVs({192,0,64,64}, {256,64}))
	
    spec.hud.bg = Overlay:new(modDirectory .. "achud.dds", baseX, baseY, w, h)
    spec.hud.bg:setUVs(getNormalizedUVs({420,80,128,128}, {1024,512}))
	spec.hud.bg:setAlignment(Overlay.ALIGN_VERTICAL_BOTTOM, Overlay.ALIGN_HORIZONTAL_RIGHT)
    spec.hud.bg:setColor(0.015, 0.015, 0.015, 0.7)
end

function advancedCombine:onDelete()
	--g_soundManager:stopSample(self.thresherSoundSample)
	g_soundManager:deleteSample(self.spec_advancedCombine.thresherSoundSample)
	--g_soundManager:stopSample(spec.chopperSoundSample)
	g_soundManager:deleteSample(self.spec_advancedCombine.chopperSoundSample)
end

function advancedCombine:saveToXMLFile(xmlFile, key, usedModNames)
    local spec = self.spec_advancedCombine
	setXMLInt(xmlFile, key.."#threshingDrum", spec.combineSettings.currentSetting.threshingDrum)
	setXMLInt(xmlFile, key.."#concave", spec.combineSettings.currentSetting.concave)
	setXMLInt(xmlFile, key.."#wind", spec.combineSettings.currentSetting.wind)
	setXMLInt(xmlFile, key.."#sieve", spec.combineSettings.currentSetting.sieve)
end

function advancedCombine:onUpdate(dt)
	local spec = self.spec_advancedCombine
	
	if self:getIsEntered() then
		if spec.displayModeSpeed then
			spec.speedDisplayLastValue = self:getLastSpeed() * 100
		else
			spec.speedDisplayLastValue = spec.actualRotorSpeedValue
		end
	end
	
	if spec.rotorSpeedAdjustment == 1 then
		if spec.combineSettings.currentSetting.threshingDrum < spec.combineSettings.baseInfos.threshingDrum.max then
			spec.combineSettings.currentSetting.threshingDrum = math.min(spec.combineSettings.currentSetting.threshingDrum + 0.03 * dt * spec.combineSettings.baseInfos.threshingDrum.changeSpeed, spec.combineSettings.baseInfos.threshingDrum.max)
		end
		spec.rotorSpeedAdjustment = 0
	elseif spec.rotorSpeedAdjustment == -1 then
		if spec.combineSettings.currentSetting.threshingDrum > spec.combineSettings.baseInfos.threshingDrum.min then
			spec.combineSettings.currentSetting.threshingDrum = math.max(spec.combineSettings.currentSetting.threshingDrum - 0.03 * dt * spec.combineSettings.baseInfos.threshingDrum.changeSpeed, spec.combineSettings.baseInfos.threshingDrum.min)
		end
		spec.rotorSpeedAdjustment = 0
	end
	
	if spec.engineSpeedAdjustment == 1 then
		if spec.engineRpm < 550 then
			spec.engineRpm = math.min(spec.engineRpm + 0.15 * dt, 550)
		end
	elseif spec.engineSpeedAdjustment == -1 then
		if spec.engineRpm > 212.5 then
			spec.engineRpm = math.max(spec.engineRpm - 0.15 * dt, 212.5)
		end
	end

	if self:getIsTurnedOn() then
		if spec.actualRotorSpeedValue < spec.combineSettings.currentSetting.threshingDrum then
			spec.actualRotorSpeedValue = math.min(spec.actualRotorSpeedValue + 0.5*dt, spec.combineSettings.currentSetting.threshingDrum)
		elseif spec.actualRotorSpeedValue > spec.combineSettings.currentSetting.threshingDrum then
			spec.actualRotorSpeedValue = math.max(spec.actualRotorSpeedValue - 0.5*dt, spec.combineSettings.currentSetting.threshingDrum)
		end
		local windTarget = math.floor((spec.actualRotorSpeedValue/spec.combineSettings.currentSetting.threshingDrum)*spec.combineSettings.currentSetting.wind)
		if spec.actualWindSpeedValue < windTarget then
			spec.actualWindSpeedValue = math.min(spec.actualWindSpeedValue + 0.4*dt, windTarget)
		elseif spec.actualWindSpeedValue > windTarget then
			spec.actualWindSpeedValue = math.max(spec.actualWindSpeedValue - 0.4*dt, windTarget)
		end
	else
		if spec.actualRotorSpeedValue > 0 then
			spec.actualRotorSpeedValue = math.max(spec.actualRotorSpeedValue - 0.15 * dt, 0)
		end
		if spec.actualWindSpeedValue > 0 then
			local windTarget = math.floor((spec.actualRotorSpeedValue/spec.combineSettings.currentSetting.threshingDrum)*spec.combineSettings.currentSetting.wind)
			spec.actualWindSpeedValue = math.max(spec.actualWindSpeedValue - 0.15 * dt, 0, windTarget)
		end
	end
	if spec.actualRotorSpeedValue > 200 then
		if not g_soundManager:getIsSamplePlaying(spec.thresherSoundSample) then
			g_soundManager:playSample(spec.thresherSoundSample, 0)
		end
	else
		if g_soundManager:getIsSamplePlaying(spec.thresherSoundSample) then
			g_soundManager:stopSample(spec.thresherSoundSample)
		end
	end
	
	if self.spec_combine.chopperPSenabled then
		if not g_soundManager:getIsSamplePlaying(spec.chopperSoundSample) then
			g_soundManager:playSample(spec.chopperSoundSample, 0)
		end
		if spec.chopperSoundVolumeCoeff < 1 then
			spec.chopperSoundVolumeCoeff = math.min(spec.chopperSoundVolumeCoeff + dt/900, 1)
		end
	else
		if spec.chopperSoundVolumeCoeff > 0 then
			spec.chopperSoundVolumeCoeff = math.max(spec.chopperSoundVolumeCoeff - dt/400, 0)
		end
		if spec.chopperSoundVolumeCoeff == 0 and g_soundManager:getIsSamplePlaying(spec.chopperSoundSample) then
			g_soundManager:stopSample(spec.chopperSoundSample)
		end
	end
	
	self:calculateSpill(dt)
	
	--Adjust the harvest outcome based on spill
	self.spec_combine.threshingScale = (100 - math.max(spec.rawSpillValue, 0)) * 0.01
	
	--[[if self.isClient then
		local isUnloading = self:getDischargeState() ~= Dischargeable.DISCHARGE_STATE_OFF
		if g_manualDischargeUtil ~= nil then
			local specManualDischarge = g_manualDischargeUtil.getSpecByName(self, "manualDischarge")
			isUnloading = specManualDischarge.allowDischarge and self:getDischargeState() ~= Dischargeable.DISCHARGE_STATE_OFF
		end
		if isUnloading and not spec.isUnloading then
			setVisibility(self.spec_advancedCombine.augerOnLight, true)
			spec.isUnloading = true
		elseif not isUnloading and spec.isUnloading then
			setVisibility(self.spec_advancedCombine.augerOnLight, false)
			spec.isUnloading = false
		end
	end]]
end

function advancedCombine:onDraw()
	if self:getIsEntered() then
		local spec = self.spec_advancedCombine
		if spec.showHud then
			setTextAlignment(RenderText.ALIGN_RIGHT)
			local uiScale = g_gameSettings.uiScale
			
			local fontSize = 0.015 * uiScale
			local baseX = 1 - g_safeFrameOffsetX - fontSize
			local baseY = g_safeFrameOffsetY + g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY * 3
			local textoffset = fontSize*1.3
			
			setTextBold(false)
			local s1, n1, n2, n3, n4 = advancedCombine.getMaxTextLength(self)
			local col4 = baseX-n4-0.002
			local col3 = col4-n3-0.007
			local col2 = col3-n2-0.007
			local col1 = col2-n1-s1*1.2-0.007
			
			for i,grainType in ipairs(spec.grainTypes) do
				for k,fruitType in pairs(grainType.fruitTypes) do
					local filltypeindex = g_fruitTypeManager:getFillTypeIndexByFruitTypeIndex(k)
					local filltypename = g_fillTypeManager:getFillTypeByIndex(filltypeindex).title
					if self:getFillUnitFillType(1) == filltypeindex then
						setTextColor(0.25, 1, 0.25, 1)
					else
						setTextColor(1, 1, 1, 1)
					end
					setTextAlignment(RenderText.ALIGN_RIGHT)
					renderText(baseX, baseY+textoffset, fontSize, string.format("%d", grainType.sieve))
					renderText(col4, baseY+textoffset, fontSize, string.format("%d |", grainType.wind))
					renderText(col3, baseY+textoffset, fontSize, string.format("%d |", grainType.concave))
					renderText(col2, baseY+textoffset, fontSize, string.format("%d |", grainType.threshingDrumSpeed))
					setTextAlignment(RenderText.ALIGN_LEFT)
					renderText(col1, baseY+textoffset, fontSize, string.format("%s", filltypename..":"))
					textoffset = textoffset+fontSize*1.1
				end
			end
			setTextAlignment(RenderText.ALIGN_RIGHT)
			setTextBold(true)
			local w = spec.hud.icon1.width
			spec.hud.bg:setPosition(baseX+fontSize,baseY)
			spec.hud.bg:setDimension(baseX-col1+fontSize*2, textoffset+fontSize*4)
			spec.hud.bg:render()
			spec.hud.main:setPosition(spec.hud.main.x, baseY+textoffset+fontSize*5)
			spec.hud.main:render()
			spec.hud.icon1:setPosition(col2-w-n1/2, baseY+textoffset) --drum
			spec.hud.icon1:render()
			spec.hud.icon2:setPosition(col3-w-n2/2, baseY+textoffset) --concave
			spec.hud.icon2:render()
			spec.hud.icon3:setPosition(col4-w-n3/2, baseY+textoffset) --wind
			spec.hud.icon3:render()
			spec.hud.icon4:setPosition(baseX-w, baseY+textoffset) --sieve
			spec.hud.icon4:render()
			local w, h = spec.hud.main.width, spec.hud.main.height
			local spillcolor = 1 - math.min(spec.rawSpillValue/10, 1)
			setTextColor(1, spillcolor, spillcolor, 1)
			renderText(spec.hud.main.x+w*0.92, spec.hud.main.y+h*0.085, h/10, string.format("%d %%", spec.rawSpillValue)) -- spill display in HUD
			setTextColor(1, 1, 1, 1)
			renderText(spec.hud.main.x+w*0.76, spec.hud.main.y+h*0.395, h/10, string.format("%d", spec.combineSettings.currentSetting.sieve)) -- sieve display in HUD
			renderText(spec.hud.main.x+w*0.51, spec.hud.main.y+h*0.24, h/10, string.format("%d", spec.actualWindSpeedValue)) -- wind display in HUD
			renderText(spec.hud.main.x+w*0.307, spec.hud.main.y+h*0.285, h/10, string.format("%d", spec.combineSettings.currentSetting.concave)) -- concave display in HUD
			renderText(spec.hud.main.x+w*0.373, spec.hud.main.y+h*0.41, h/10, string.format("%d", spec.actualRotorSpeedValue)) -- concave display in HUD
			textoffset = textoffset+fontSize*2
			setTextAlignment(RenderText.ALIGN_LEFT)
			renderText(col1, baseY+textoffset, fontSize*1.2, g_i18n:getText("HUD_HARVESTER_SETTINGS"))
			setTextBold(false)
		end
	end
end

--[[function advancedCombine:getPtoRpm(superFunc)
	if self:getIsTurnedOn() then
		return 550
	else
		return superFunc(self)
	end
end]]

function advancedCombine:getRotorRpm()
	return self.spec_advancedCombine.actualRotorSpeedValue/self.spec_advancedCombine.combineSettings.baseInfos.threshingDrum.max
end
function advancedCombine:getMinRotorRpm()
	return 0
end
function advancedCombine:getMaxRotorRpm()
	return 1
end

function advancedCombine:getCameraRot()
	if self:getIsEntered() and not self.spec_enterable.activeCamera.isInside then
		local rotation = math.deg(self.spec_enterable.activeCamera.rotY % (2*math.pi))
		return rotation/360
	end
	return 0
end
function advancedCombine:getMinCamRot()
	return 0
end
function advancedCombine:getMaxCamRot()
	return 1
end

function advancedCombine:getChopperVolume()
	return self.spec_advancedCombine.chopperSoundVolumeCoeff
end
function advancedCombine:getMinChopperVolume()
	return 0
end
function advancedCombine:getMaxChopperVolume()
	return 1
end

function advancedCombine:getCorrectGrainTypeSelection(fruitType)
	for i,grainType in pairs(self.spec_advancedCombine.grainTypes) do
		for k,v in pairs(grainType.fruitTypes) do
			if fruitType == k then
				return i
			end
		end
	end
end

function advancedCombine:getMaxTextLength()
	local maxLengthFruit = 0
	local maxLengthDrum = 0
	local maxLengthConcave = 0
	local maxLengthWind = 0
	local maxLengthSieve = 0
	local uiScale = g_gameSettings.uiScale
	for i,grainType in pairs(self.spec_advancedCombine.grainTypes) do
		for k,fruitType in pairs(grainType.fruitTypes) do
			local filltypeindex = g_fruitTypeManager:getFillTypeIndexByFruitTypeIndex(k)
			local filltypename = g_fillTypeManager:getFillTypeByIndex(filltypeindex).title
			maxLengthFruit = math.max(maxLengthFruit, getTextWidth(0.015 * uiScale, filltypename))
			maxLengthDrum = math.max(maxLengthDrum, getTextWidth(0.015 * uiScale, tostring(grainType.threshingDrumSpeed)))
			maxLengthConcave = math.max(maxLengthConcave, getTextWidth(0.015 * uiScale, tostring(grainType.concave)))
			maxLengthWind = math.max(maxLengthWind, getTextWidth(0.015 * uiScale, tostring(grainType.wind)))
			maxLengthSieve = math.max(maxLengthSieve, getTextWidth(0.015 * uiScale, tostring(grainType.sieve)))
		end
	end
	return maxLengthFruit, maxLengthDrum, maxLengthConcave, maxLengthWind, maxLengthSieve
end

function advancedCombine:calculateSpill(dt)
	local spec = self.spec_advancedCombine
	local spill = 0
	
	if self.spec_combine.lastAreaZeroTime < 250 then --self.spec_combine.lastArea > 0 then
		local currentGrainTankFruitType = g_fruitTypeManager:getFruitTypeByFillTypeIndex(self:getFillUnitFillType(self.spec_combine.fillUnitIndex))
		if currentGrainTankFruitType ~= nil then
			local spillDrum = 0
			local spillConcave = 0
			local spillWind = 0
			local spillSieve = 0
			
			for i,grainType in pairs(spec.grainTypes) do
				for k,fruitType in pairs(grainType.fruitTypes) do
					if currentGrainTankFruitType.index == k then
						local correctGT = self:getCorrectGrainTypeSelection(currentGrainTankFruitType.index)
						local drum = spec.grainTypes[correctGT].threshingDrumSpeed
						local concave = spec.grainTypes[correctGT].concave
						local wind = spec.grainTypes[correctGT].wind
						local sieve = spec.grainTypes[correctGT].sieve
						
						spillDrum = math.abs(math.floor(spec.actualRotorSpeedValue) - drum) * 0.12
						spillConcave = (spec.combineSettings.currentSetting.concave - concave) * 2
						if spillConcave < 0 then
							spillConcave = spillConcave * -0.75
						end
						spillWind = (spec.combineSettings.currentSetting.wind - wind) * 0.1
						if spillWind < 0 then
							spillWind = spillWind * -0.6
						end
						spillSieve = (spec.combineSettings.currentSetting.sieve - sieve)
						if spillSieve < 0 then
							spillSieve = spillSieve * -1.5
						end
						break
					end
				end
			end
			spill = spillDrum + spillConcave + spillWind + spillSieve
		end
	else
		spill = 0
	end
	
	if spill > 99 then
		spill = 99
	end
	
	spec.rawSpillValue = spill
	
	local adjustedSpill = 0
	if self.spec_combine.lastAreaZeroTime < 1000 then
		adjustedSpill = spill/1.05 + 5
	end
	
	if spec.lastSpill < adjustedSpill then
		spec.spillValue = math.min(spec.lastSpill + 0.1 * dt, adjustedSpill)
	elseif spec.lastSpill > adjustedSpill then
		spec.spillValue = math.max(spec.lastSpill - 0.1 * dt, adjustedSpill)
	elseif adjustedSpill == 0 then
		spec.spillValue = 0
	end
	
	spec.lastSpill = spec.spillValue
	if spec.rotationPartSpillnadel ~= nil then
		local x, y, z = getRotation(spec.rotationPartSpillnadel.node)
		z = ((spec.rotationPartSpillnadel.maxRot[3] - spec.rotationPartSpillnadel.minRot[3]) / 100) * spec.spillValue + spec.rotationPartSpillnadel.minRot[3]
		setRotation(spec.rotationPartSpillnadel.node, x, y ,z)
	end
end

function advancedCombine.processActionEvent(self, actionName, inputValue, callbackState, isAnalog)
	local spec = self.spec_advancedCombine
	
	if actionName == "TOGGLE_DISPLAY_MODE" then
		spec.displayModeSpeed = not spec.displayModeSpeed
		if spec.speedDisplayDot ~= nil then
			setVisibility(spec.speedDisplayDot, spec.displayModeSpeed)
		end
	end
	if actionName == "SHOW_SPILL_HUD" then
		spec.showHud = not spec.showHud
		for k,eventId in pairs(spec.actionEventIds) do
			g_inputBinding:setActionEventTextVisibility(eventId, spec.showHud)
		end
	end
end

function advancedCombine.actionEventThresherRPM(self, actionName, inputValue, callbackState, isAnalog)
	self.spec_advancedCombine.rotorSpeedAdjustment = MathUtil.sign(inputValue)
end

function advancedCombine.actionEventConcave(self, actionName, inputValue, callbackState, isAnalog)
	local spec = self.spec_advancedCombine
	local dir = MathUtil.sign(inputValue)
	spec.combineSettings.currentSetting.concave = math.min(math.max(spec.combineSettings.currentSetting.concave + (spec.combineSettings.baseInfos.concave.changeStep * dir), spec.combineSettings.baseInfos.concave.min), spec.combineSettings.baseInfos.concave.max)
end

function advancedCombine.actionEventWindRPM(self, actionName, inputValue, callbackState, isAnalog)
	local spec = self.spec_advancedCombine
	local dir = MathUtil.sign(inputValue)
	spec.combineSettings.currentSetting.wind = math.min(math.max(spec.combineSettings.currentSetting.wind + (spec.combineSettings.baseInfos.wind.changeStep * dir), spec.combineSettings.baseInfos.wind.min), spec.combineSettings.baseInfos.wind.max)
end

function advancedCombine.actionEventSieve(self, actionName, inputValue, callbackState, isAnalog)
	local spec = self.spec_advancedCombine
	local dir = MathUtil.sign(inputValue)
	spec.combineSettings.currentSetting.sieve = math.min(math.max(spec.combineSettings.currentSetting.sieve + (spec.combineSettings.baseInfos.sieve.changeStep * dir), spec.combineSettings.baseInfos.sieve.min), spec.combineSettings.baseInfos.sieve.max)
end
