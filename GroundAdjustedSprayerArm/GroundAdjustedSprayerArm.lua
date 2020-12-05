----------------------------------------------------------------------------------------------------
-- GroundAdjustedSprayerArm
--
-- Copyright (c) Rival, 2020
----------------------------------------------------------------------------------------------------


GroundAdjustedSprayerArm = {}

function GroundAdjustedSprayerArm.prerequisitesPresent(specializations)
    return true
end

function GroundAdjustedSprayerArm.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", GroundAdjustedSprayerArm)
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", GroundAdjustedSprayerArm)
end

function GroundAdjustedSprayerArm.registerFunctions(vehicleType)
	SpecializationUtil.registerFunction(vehicleType, "groundAdjustRaycastCallback1", GroundAdjustedSprayerArm.groundAdjustRaycastCallback1)
	SpecializationUtil.registerFunction(vehicleType, "groundAdjustRaycastCallback2", GroundAdjustedSprayerArm.groundAdjustRaycastCallback2)
	SpecializationUtil.registerFunction(vehicleType, "groundAdjustRaycastCallbackMid", GroundAdjustedSprayerArm.groundAdjustRaycastCallbackMid)
end

function GroundAdjustedSprayerArm:onLoad(savegame)
	self.spec_groundAdjustedSprayerArm = {}
	local spec = self.spec_groundAdjustedSprayerArm

	spec.nodeArm1 = I3DUtil.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.groundAdjustedSprayerArms#arm1"), self.i3dMappings)
	spec.raycastArm1 = I3DUtil.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.groundAdjustedSprayerArms#arm1Raycast"), self.i3dMappings)
	spec.distanceArm1 = 0
	spec.curRotArm1 = 0
	spec.curDirArm1 = 0
	
	spec.nodeArm2 = I3DUtil.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.groundAdjustedSprayerArms#arm2"), self.i3dMappings)
	spec.raycastArm2 = I3DUtil.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.groundAdjustedSprayerArms#arm2Raycast"), self.i3dMappings)
	spec.distanceArm2 = 0
	spec.curRotArm2 = 0
	spec.curDirArm2 = 0
	
	spec.raycastMid = I3DUtil.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.groundAdjustedSprayerArms#midRaycast"), self.i3dMappings)
	spec.distanceMid = 0
	
	spec.foldMin = getXMLFloat(self.xmlFile, "vehicle.groundAdjustedSprayerArms#foldMin") or 0
	spec.foldMax = getXMLFloat(self.xmlFile, "vehicle.groundAdjustedSprayerArms#foldMax") or 1
end

function GroundAdjustedSprayerArm:onUpdate(dt)
	local spec = self.spec_groundAdjustedSprayerArm
	if self.spec_foldable.foldAnimTime >= spec.foldMin and self.spec_foldable.foldAnimTime <= spec.foldMax then
		local x,y,z = getWorldTranslation(spec.raycastArm1)
		local dx,dy,dz = localDirectionToWorld(spec.raycastArm1, 0, -1, 0)
		raycastClosest(x, y, z, dx, dy, dz, "groundAdjustRaycastCallback1", 4, self)
		
		x,y,z = getWorldTranslation(spec.raycastArm2)
		dx,dy,dz = localDirectionToWorld(spec.raycastArm2, 0, -1, 0)
		raycastClosest(x, y, z, dx, dy, dz, "groundAdjustRaycastCallback2", 4, self)
		
		x,y,z = getWorldTranslation(spec.raycastMid)
		dx,dy,dz = localDirectionToWorld(spec.raycastMid, 0, -1, 0)
		raycastClosest(x, y, z, dx, dy, dz, "groundAdjustRaycastCallbackMid", 4, self)
		
		if spec.distanceArm1 < spec.distanceMid-0.05 and spec.curDirArm1 == 0 then
			spec.curDirArm1 = 1
		elseif spec.distanceArm1 >= spec.distanceMid and spec.curDirArm1 == 1 then
			spec.curDirArm1 = 0
		elseif spec.distanceArm1 > spec.distanceMid+0.05 and spec.curDirArm1 == 0 then
			spec.curDirArm1 = -1
		elseif spec.distanceArm1 <= spec.distanceMid and spec.curDirArm1 == -1 then
			spec.curDirArm1 = 0
		end
		spec.curRotArm1 = MathUtil.clamp(spec.curRotArm1 + 0.002*spec.curDirArm1*dt, -15, 15)
		
		if spec.distanceArm2 < spec.distanceMid-0.05 and spec.curDirArm2 == 0 then
			spec.curDirArm2 = -1
		elseif spec.distanceArm2 >= spec.distanceMid and spec.curDirArm2 == -1 then
			spec.curDirArm2 = 0
		elseif spec.distanceArm2 > spec.distanceMid+0.05 and spec.curDirArm2 == 0 then
			spec.curDirArm2 = 1
		elseif spec.distanceArm2 <= spec.distanceMid and spec.curDirArm2 == 1 then
			spec.curDirArm2 = 0
		end
		spec.curRotArm2 = MathUtil.clamp(spec.curRotArm2 + 0.002*spec.curDirArm2*dt, -15, 15)
		
		setRotation(spec.nodeArm1, 0, 0, math.rad(spec.curRotArm1))
		setRotation(spec.nodeArm2, 0, 0, math.rad(spec.curRotArm2))
	else
		spec.curRotArm1 = 0
		spec.curRotArm2 = 0
	end
end

function GroundAdjustedSprayerArm:groundAdjustRaycastCallback1(transformId, x, y, z, distance)
	self.spec_groundAdjustedSprayerArm.distanceArm1 = distance
end

function GroundAdjustedSprayerArm:groundAdjustRaycastCallback2(transformId, x, y, z, distance)
	self.spec_groundAdjustedSprayerArm.distanceArm2 = distance
end

function GroundAdjustedSprayerArm:groundAdjustRaycastCallbackMid(transformId, x, y, z, distance)
	self.spec_groundAdjustedSprayerArm.distanceMid = distance
end
