AdditionalCams = {}
AdditionalCams.modDirectory = g_currentModDirectory

function AdditionalCams.prerequisitesPresent(specializations)
    return true
end

function AdditionalCams.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", AdditionalCams)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", AdditionalCams)
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", AdditionalCams)
	SpecializationUtil.registerEventListener(vehicleType, "onDraw", AdditionalCams)
	SpecializationUtil.registerEventListener(vehicleType, "onDelete", AdditionalCams)
end

function AdditionalCams.registerFunctions(vehicleType)
	SpecializationUtil.registerFunction(vehicleType, "addAdditionalCam", AdditionalCams.addAdditionalCam)
	SpecializationUtil.registerFunction(vehicleType, "removeAdditionalCam", AdditionalCams.removeAdditionalCam)
	SpecializationUtil.registerFunction(vehicleType, "getCameraAtPosition", AdditionalCams.getCameraAtPosition)
	SpecializationUtil.registerFunction(vehicleType, "changeCamera", AdditionalCams.changeCamera)
	SpecializationUtil.registerFunction(vehicleType, "createHUDElement", AdditionalCams.createHUDElement)
end

function AdditionalCams:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    if self.isClient then
        local spec = self.spec_additionalCams
		spec.actionEvents = {}
        self:clearActionEventsTable(spec.actionEvents)

        if self:getIsActiveForInput(true, true) then
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.ACToggleMouse, self, AdditionalCams.mouseActionEvent, false, true, false, true)
			local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.ACMouseClick, self, AdditionalCams.mouseActionEvent, false, true, false, true)
        end
    end
end

function AdditionalCams:onLoad(savegame)
	self.spec_additionalCams = {}
	local spec = self.spec_additionalCams
	spec.cams = {}
	spec.numCameras = 0
	spec.lastCam = 1
	spec.currentCam = 0
	spec.automaticCamSwitch = false
	spec.automaticCamChanged = 0
	local i = 0
	while true do
		local key = string.format("vehicle.additionalCams.cam(%d)", i)
		if not hasXMLProperty(self.xmlFile, key) then
			break
		end
		local camId = I3DUtil.indexToObject(self.components, getXMLString(self.xmlFile, key.."#node"), self.i3dMappings)
		local position = Utils.getNoNil(getXMLString(self.xmlFile, key.."#position"), "")
		if camId ~= nil then
			self:addAdditionalCam(camId, position)
		else
			print(string.format("AdditionalCams error: Invalid cam node '%d'", i))
		end
		i = i + 1
	end
	
	local image = AdditionalCams.modDirectory .. "cam_hud.dds"
	spec.hud = {}
	spec.hud.bg = Overlay:new(image, 0.831, 0.866, 0.166, 0.03) --self:createHUDElement(image, 0.831, 0.866, hudScale*uiScale, { 992, 100, 32, 32 }, Overlay.ALIGN_VERTICAL_BOTTOM)
	spec.hud.bg:setUVs(getNormalizedUVs({ 1, 0, 62, 128 }, { 1024, 128 }))
	spec.hud.bgCam = Overlay:new(image, 0.831, 0.7, 0.166, 0.166) --self:createHUDElement(image, 0.831, 0.866, hudScale*uiScale, { 992, 100, 32, 32 }, Overlay.ALIGN_VERTICAL_BOTTOM)
	spec.hud.bgCam:setUVs(getNormalizedUVs({ 1, 0, 62, 128 }, { 1024, 128 }))
	spec.hud.buttons = {}
	for i=1, 6 do
		spec.hud.buttons[i] = self:createHUDElement(image, 0.846+i%6*0.022, 0.869, { 89+math.floor(i%6*133.5), 0, 130, 128 }, Overlay.ALIGN_VERTICAL_BOTTOM, AdditionalCams.changeCamera, i%6)
	end
	spec.hud.buttons[7] = self:createHUDElement(image, 0.846+6*0.022, 0.869, { 890, 0, 130, 128 }, Overlay.ALIGN_VERTICAL_BOTTOM, AdditionalCams.changeAutomaticMode)
--[[spec.hud.buttons[1] = self:createHUDElement(image, 0.831+2*0.022, 0.869, { 222, 0, 130, 128 }, Overlay.ALIGN_VERTICAL_BOTTOM, AdditionalCams.changeCamera, 1)
	spec.hud.buttons[2] = self:createHUDElement(image, 0.831+3*0.022, 0.869, { 355, 0, 130, 128 }, Overlay.ALIGN_VERTICAL_BOTTOM, AdditionalCams.changeCamera, 2)
	spec.hud.buttons[3] = self:createHUDElement(image, 0.831+4*0.022, 0.869, { 489, 0, 130, 128 }, Overlay.ALIGN_VERTICAL_BOTTOM, AdditionalCams.changeCamera, 3)
	spec.hud.buttons[4] = self:createHUDElement(image, 0.831+5*0.022, 0.869, { 623, 0, 130, 128 }, Overlay.ALIGN_VERTICAL_BOTTOM, AdditionalCams.changeCamera, 4)
	spec.hud.buttons[5] = self:createHUDElement(image, 0.831+6*0.022, 0.869, { 755, 0, 130, 128 }, Overlay.ALIGN_VERTICAL_BOTTOM, AdditionalCams.changeCamera, 5)
	spec.hud.buttons[6] = self:createHUDElement(image, 0.831+1*0.022, 0.869, {  89, 0, 130, 128 }, Overlay.ALIGN_VERTICAL_BOTTOM, AdditionalCams.changeCamera, 0)]]
end

function AdditionalCams:createHUDElement(image, x, y, uvs, alignment, onClickCallback, camId)
	local w,h = getNormalizedScreenValues(uvs[3]/5, uvs[4]/5)
	local overlay = Overlay:new(image, x, y, w*1.17, h)
	overlay:setUVs(getNormalizedUVs(uvs, { 1024, 128 }))
	overlay:setAlignment(alignment, Overlay.ALIGN_HORIZONTAL_CENTER)
	if onClickCallback ~= nil then
		overlay.onClickCallback = onClickCallback
		if camId ~= nil then
			overlay.camId = camId
		end
		overlay:setColor(0.5, 0.5, 0.5, 1)
	end
	return overlay, w, h
end

function AdditionalCams:addAdditionalCam(camId, position)
	local spec = self.spec_additionalCams
	if spec.numCameras < 5 then
		spec.numCameras = spec.numCameras + 1
		local overlayId = createRenderOverlay(camId, getScreenAspectRatio(), 512, 512, true, 255, 16711680)
		local cam = {camId=camId, overlayId=overlayId, position=position}
		table.insert(spec.cams, cam)
	else
		print("AdditionalCams: Maximum camera count reached!")
	end
end

function AdditionalCams:removeAdditionalCam(camId)
	local spec = self.spec_additionalCams
	for i,cam in ipairs(spec.cams) do
		if cam.camId == camId then
			if spec.currentCam == i then
				spec.currentCam = 0
			end
			spec.numCameras = math.max(spec.numCameras - 1, 0)
			table.remove(spec.cams, i)
			break
		end
	end
end

function AdditionalCams:changeAutomaticMode()
	local spec = self.spec_additionalCams
	spec.automaticCamSwitch = not spec.automaticCamSwitch
	if spec.automaticCamSwitch then
		spec.hud.buttons[7]:setColor(1, 1, 1, 1)
	else
		spec.hud.buttons[7]:setColor(0.5, 0.5, 0.5, 1)
	end
end

function AdditionalCams:getCameraAtPosition(requiredPosition)
	local spec = self.spec_additionalCams
	for i,cam in ipairs(spec.cams) do
		if cam.position == requiredPosition then
			return i
		end
	end
	return nil
end

function AdditionalCams:changeCamera(camId)
	local spec = self.spec_additionalCams
	--[[if spec.currentCam ~= camId then
		if spec.currentCam ~= 0 then spec.hud.buttons[spec.currentCam]:setColor(0.5, 0.5, 0.5, 1) end
		if camId ~= 0 then spec.hud.buttons[camId]:setColor(1, 1, 1, 1) end
		spec.currentCam = camId
	end]]
	if camId ~= 0 then
		if spec.cams[camId] ~= nil and camId ~= spec.currentCam then
			if spec.currentCam ~= 0 then spec.hud.buttons[spec.currentCam]:setColor(0.5, 0.5, 0.5, 1) end
			spec.hud.buttons[camId]:setColor(1, 1, 1, 1)
			spec.hud.buttons[6]:setColor(1, 1, 1, 1)
			spec.lastCam = spec.currentCam
			spec.currentCam = camId
		end
	else
		if spec.currentCam == 0 then
			self:changeCamera(spec.lastCam)
		else
			spec.hud.buttons[spec.currentCam]:setColor(0.5, 0.5, 0.5, 1)
			spec.hud.buttons[6]:setColor(0.5, 0.5, 0.5, 1)
			spec.lastCam = spec.currentCam
			spec.currentCam = camId
		end
	end
end

function AdditionalCams:onUpdate(dt)
	local spec = self.spec_additionalCams
	if spec.currentCam ~= 0 and spec.cams[spec.currentCam] ~= nil then
		updateRenderOverlay(spec.cams[spec.currentCam].overlayId)
	end
	if spec.automaticCamSwitch then
		if self.spec_pipe ~= nil then
			if self.spec_pipe.unloadingStates[self.spec_pipe.targetState] == true then
				local nextCam = self:getCameraAtPosition("pipe")
				if nextCam ~= nil and nextCam ~= spec.currentCam and spec.automaticCamChanged == 0 then
					self:changeCamera(nextCam)
					spec.automaticCamChanged = 1
				end
			else
				if spec.automaticCamChanged == 1 then
					if spec.currentCam == self:getCameraAtPosition("pipe") then
						self:changeCamera(spec.lastCam)
					end
					spec.automaticCamChanged = 0
				end
			end
			if self.movingDirection == -1 and self:getLastSpeed() > 1 and not self.spec_pipe.unloadingStates[self.spec_pipe.targetState] then
				local nextCam = self:getCameraAtPosition("reverse")
				if nextCam ~= nil and nextCam ~= spec.currentCam and spec.automaticCamChanged == 0 then
					self:changeCamera(nextCam)
					spec.automaticCamChanged = 2
				end
			else
				if spec.automaticCamChanged == 2 then
					if spec.currentCam == self:getCameraAtPosition("reverse") then
						self:changeCamera(spec.lastCam)
					end
					spec.automaticCamChanged = 0
				end
			end
		end
	end
end

function AdditionalCams:onDraw(dt)
	local spec = self.spec_additionalCams
	if spec.currentCam ~= 0 then
		spec.hud.bgCam:render()
		renderOverlay(spec.cams[spec.currentCam].overlayId, 0.831, 0.7, 0.166, 0.166)
	end
	spec.hud.bg:render()
	for i,button in ipairs(spec.hud.buttons) do
		button:render()
	end
end

function AdditionalCams:onDelete()
	local spec = self.spec_additionalCams
	for i,cam in ipairs(spec.cams) do
		delete(cam.overlayId)
	end
end

function AdditionalCams.mouseActionEvent(self, actionName, inputValue, callbackState, isAnalog)
	if actionName == "ACToggleMouse" then
		g_inputBinding:setShowMouseCursor(not g_inputBinding:getShowMouseCursor())
		if g_inputBinding:getShowMouseCursor() then
			if self.spec_enterable ~= nil and self.spec_enterable.cameras ~= nil then
				for _, camera in pairs(self.spec_enterable.cameras) do
					camera.allowTranslation = false
					camera.isRotatable = false
				end
			end
		else
			if self.spec_enterable ~= nil and self.spec_enterable.cameras ~= nil then
				for _, camera in pairs(self.spec_enterable.cameras) do
					camera.allowTranslation = true
					camera.isRotatable = true
				end
			end
		end
	end
	if actionName == "ACMouseClick" then
		local posX, posY = g_inputBinding:getMousePosition()
		
		if g_inputBinding:getShowMouseCursor() and g_gui.currentGui == nil then
			for i,button in ipairs(self.spec_additionalCams.hud.buttons) do
				local x, y = button:getPosition()
				local cursorInElement = GuiUtils.checkOverlayOverlap(posX, posY, x+button.offsetX, y+button.offsetY, button.width, button.height)
				if cursorInElement then
					button.onClickCallback(self, button.camId)
				end
			end
		end
	end
end
