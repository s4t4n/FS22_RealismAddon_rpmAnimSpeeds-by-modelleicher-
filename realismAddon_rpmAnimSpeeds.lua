-- by modelleicher
-- 2021
-- BETA Release 10/2021 due to FS22 being close, script is nowhere near done yet 
-- update: 16.01.2023

realismAddon_rpmAnimSpeeds = {};


function realismAddon_rpmAnimSpeeds.prerequisitesPresent(specializations)
    return true;
end;

function realismAddon_rpmAnimSpeeds.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", realismAddon_rpmAnimSpeeds);
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", realismAddon_rpmAnimSpeeds);
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", realismAddon_rpmAnimSpeeds);
end;

function realismAddon_rpmAnimSpeeds:animationNodesLoad(spec)
	local hasScrollers = false;
	if spec.animationNodes ~= nil then
		for _, animation in ipairs(spec.animationNodes) do
			if animation.rotSpeed ~= nil then
				animation.rotSpeedBackup = animation.rotSpeed;
			end;
			if animation.scrollSpeed ~= nil then	
				animation.scrollSpeedBackup = animation.scrollSpeed;
				hasScrollers = true;
			end;
			-- added FL
			if animation.transSpeed ~= nil then
				animation.transSpeedBackup = animation.transSpeed;
			end;
		end;	
	end;
	return hasScrollers;
end;

--17er
function realismAddon_rpmAnimSpeeds:onLoad(savegame)
	self.movingToolBackup = {rotSpeed = {}, transSpeed = {}, animSpeed = {}}; -- create backup table
end;

function realismAddon_rpmAnimSpeeds:onPostLoad(savegame)
	self.animationNodesLoad = realismAddon_rpmAnimSpeeds.animationNodesLoad;
	self.animationNodesUpdate = realismAddon_rpmAnimSpeeds.animationNodesUpdate;
	
	-- for frontloader 17er
	-- load all movingTools speeds into backup table
	--[[for i = 1, #self.spec_cylindered.movingTools do  -- self.spec_cylindered was nil
		local tool = self.spec_cylindered.movingTools[i];
		if tool.rotSpeed ~= nil then
			self.movingToolBackup.rotSpeed[i] = tool.rotSpeed;
		end;
		if tool.transSpeed ~= nil then
			self.movingToolBackup.transSpeed[i] = tool.transSpeed;
		end;
		if tool.animSpeed ~= nil then
			self.movingToolBackup.animSpeed[i] = tool.animSpeed;
		end;				
	end;]]
	
	
	
	if self.realismAddon == nil then
		self.realismAddon = {}
	end;
	self.realismAddon.rpmAnimSpeeds = {};

	
	
	
	
	if self.isClient then
	
		-- turnOnVehicle animations
		if self.spec_turnOnVehicle ~= nil then
			local spec = self.spec_turnOnVehicle;
			for _, animation in ipairs(spec.turnedOnAnimations) do
				animation.speedScaleBackup = animation.speedScale;
			end;
			
			self:animationNodesLoad(spec);
					
		end;
		
		-- tedder animations
		if self.spec_tedder ~= nil then
			local spec = self.spec_tedder;
			self:animationNodesLoad(spec);				
		end;
		
		-- windrower animations 
		if self.spec_windrower ~= nil then
			local spec = self.spec_windrower;
			self:animationNodesLoad(spec);					
		end;
		
		-- combine animations 
		if self.spec_combine ~= nil then
			local spec = self.spec_combine;			
			self:animationNodesLoad(spec);		
		end;
		
		-- mower animations 
		if self.spec_mower ~= nil then
			local spec = self.spec_mower;
			self:animationNodesLoad(spec);		
		end;		
		
		
		--self.spec_cylindered.movingTools
		-- added frontloader maybe
		if self.spec_cylindered ~= nil then
			local spec = self.spec_cylindered;
			-- self:animationNodesLoad(spec);	
			for _, movingTool in pairs(spec.movingTools) do
				movingTool.moveTimeBkup = movingTool.moveTime;
			end;
		end;		
		
				
		
		-- foldable
		if self.spec_foldable ~= nil then
			local spec = self.spec_foldable;
			for _, foldingPart in pairs(spec.foldingParts) do
				foldingPart.speedScaleBackup = foldingPart.speedScale;
			end;
		end;
		
		-- Plough plow
		-- if self.spec_plow ~= nil then
			-- local spec = self.spec_plow;
			-- for _, rotationPart in pairs(spec.rotationPart) do
				-- foldingPart.speedScaleBackup = foldingPart.speedScale;
				-- -- rotationPart.turnAnimation
				-- -- self:setAnimationTime(spec.rotationPart.turnAnimation, turnAnimationTime, true)
			-- end;
		-- end;
	
	
		-- attacher Joints moveTime 
		if self.spec_attacherJoints ~= nil then
			local spec = self.spec_attacherJoints;
			for _, attacherJoint in pairs(spec.attacherJoints) do
				attacherJoint.moveTimeBackup = attacherJoint.moveTime;
			end;
		end;
		
		-- tippers tipping time 
		if self.spec_trailer ~= nil then
			local spec = self.spec_trailer;
			for _, tipSide in pairs(spec.tipSides) do
			
				-- animationNodes like rollers, belts etc. 
				local hasScrollers = self:animationNodesLoad(tipSide);			
				
				-- tip animations
				if tipSide.animation ~= nil then
					tipSide.animation.speedScaleBackup = tipSide.animation.speedScale;
				end;
				-- doorAnimation
				if tipSide.doorAnimation ~= nil then 
					tipSide.doorAnimation.speedScaleBackup = tipSide.doorAnimation.speedScale; 
				end;
				
				-- slower discharge if vehicle as a scroller/belt to unload instead of tipping 
				if hasScrollers then
					self.realismAddon.rpmAnimSpeeds.hasScrollers = true;
				end;
				
				-- if vehicle is not a scroller/belt unloader but tipper, make empty speed dependend on tip angle.. very not good way of doing but no way of 100% reading if its a tipper via script 
					
				
				--[[if tipSide.animation ~= nil then
					local doesTip = false;
					
					
					-- dischargeable  dischargeNode fillUnitIndex
					
					spec.fillUnits = {}
					
					if self.realismAddon.rpmAnimSpeeds.hasScrollers then
					if self.spec_dischargeable ~= nil then
						local dischargeNode = self.spec_dischargeable.currentDischargeNode;
						dischargeNode.emptySpeed = dischargeNode.emptySpeedBackup * rpmValue;
					end;
				end;				
					
					-- match animation to animation 
					for _ , animation in pairs(self.spec_animatedVehicle.animations) do
						if animation.name == tipSide.animation.name then 
							-- find anim parts with X or Z rotation 
							for _, part in pairs(animation.parts) do
								if part.endRot ~= nil then
									if math.abs(part.endRot[1]) > part.startRot[1] then
										tipSide.realismAddon_tipAnimation = {};
										tipSide.realismAddon_tipAnimation.partX = part;
										print("found partX");
										break;
									elseif math.abs(part.endRot[3]) > part.startRot[3] then
										tipSide.realismAddon_tipAnimation = {};
										tipSide.realismAddon_tipAnimation.partZ = part;	
										print("found partZ");
										break;
									end;
								end;
							end;
						end;
					end;
				end;
				]]
				
				-- save backup of discharge speed 
				if hasScrollers or tipSide.realismAddon_tipAnimation ~= nil then
					if self.spec_dischargeable ~= nil then
						for _, dischargeNode in pairs(self.spec_dischargeable.dischargeNodes) do
							dischargeNode.emptySpeedBackup = dischargeNode.emptySpeed;
						end;
					end;
				end;
			end;
		end;		
	end;	
end;

function realismAddon_rpmAnimSpeeds:animationNodesUpdate(spec, rpmValue)	
	if spec.animationNodes ~= nil then
		for _, animation in ipairs(spec.animationNodes) do
			if animation.rotSpeed ~= nil  and rpmValue ~= nil then
				animation.rotSpeed = animation.rotSpeedBackup * rpmValue;
			end;
			if animation.scrollSpeed ~= nil and rpmValue ~= nil then
				animation.scrollSpeed = animation.scrollSpeedBackup * rpmValue;
			end;
			if animation.transSpeed ~= nil and rpmValue ~= nil then
				animation.transSpeed = animation.transSpeedBackup * rpmValue;
			end;
		end;	
	end;
end;

function realismAddon_rpmAnimSpeeds:onUpdate(dt)
	
	if self.isClient then
	
	-- 17er -------------------------------------------------------------
		--[[if self:getIsActive() then
			--local rpmFactor = nil; -- no need with rAGB ot CVTa | rpm factor stays nil unless vehicle or attacherVehicle has GBAddon installed and active
			-- if self.mrGbMS ~= nil and self.mrGbMS.IsOn then
			-- rpmFactor = (self:mrGbMGetCurrentRPM() / self.mrGbMS.CurMaxRpm) * 1.18; -- rpm factor is divided by RPM and multiplied by 1.18 to speed the loaders up just a little
			rpmFactor = (self.spec_motorized.motor:getLastMotorRpm() / self.spec_motorized.motor:getMaxRpm()) * 1.18; -- rpm factor is divided by RPM and multiplied by 1.18 to speed the loaders up just a little
			-- elseif self.attacherVehicle ~= nil and self.attacherVehicle.mrGbMS ~= nil and self.attacherVehicle.mrGbMS.IsOn then
			rpmFactor = (self.spec_motorized.motor:getLastMotorRpm() / self.spec_motorized.motor:getMaxRpm()) * 1.18;
			end;
			
			-- only if RPM Factor is not nil (e.g. gearbox is installed and active) change speed
			if rpmFactor ~= nil then			
				for i = 1, #self.spec_cylindered.movingTools do
					local tool = self.spec_cylindered.movingTools[i];
					if tool.rotSpeed ~= nil then
						tool.rotSpeed = self.movingToolBackup.rotSpeed[i] * rpmFactor;
					end;
					-- if tool.transSpeed ~= nil then
						-- tool.transSpeed = self.movingToolBackup.transSpeed[i] * rpmFactor;
					-- end;	
					-- if tool.animSpeed ~= nil then
						-- tool.animSpeed = self.movingToolBackup.animSpeed[i] * rpmFactor;
					-- end;				
				end;
			end;	
		end;]]    --// hat keinen Effekt und koppelt alle folgenden aus
	--------------------------------------------------------------------------------------
	
		local rpmValue = 1
		local motor = nil;
		if self.spec_motorized ~= nil then
			motor = self.spec_motorized.motor;
		else
			if self.getAttacherVehicle ~= nil then
				local attacherVehicle = self:getAttacherVehicle()		
				if attacherVehicle ~= nil then 
					if attacherVehicle.spec_motorized == nil then
						local attacherVehicle2 = attacherVehicle:getAttacherVehicle()	
						if attacherVehicle2 ~= nil and attacherVehicle2.spec_motorized ~= nil then 
							motor = attacherVehicle2.spec_motorized.motor;
						end;
					else
						motor = attacherVehicle.spec_motorized.motor;
					end;
				end;
			end;
		end;
		
		if motor ~= nil then
			-- local rpm = motor:getEqualizedMotorRpm()
			-- local rpm = self.spec_motorized.motor.lastMotorRpm
			
			local rpm = motor:getLastMotorRpm() -- work with CVTa and rAGB
			local maxRpm = motor:getMaxRpm() -- work with CVTa and rAGB
			spdValue = math.min(( self:getLastSpeed() / 20 ), 1)
			rpmValue = rpm / maxRpm;	
		end;	
		
		-- turnOnVehicle Animations
		if self.spec_turnOnVehicle ~= nil then
			if self.playAnimation ~= nil then
				local spec = self.spec_turnOnVehicle;
					
				for _, animation in ipairs(spec.turnedOnAnimations) do
					animation.speedScale = animation.speedScaleBackup * rpmValue;
					self:setAnimationSpeed(animation.name, animation.currentSpeed * animation.speedScale);
				end;
				
				self:animationNodesUpdate(spec, rpmValue);
			end;
		end;
		
		-- tedder Animations		
		if self.spec_tedder ~= nil then
			local spec = self.spec_tedder;
			
			self:animationNodesUpdate(spec, rpmValue);				
		end;
		
		-- windrower animations 
		if self.spec_windrower ~= nil then
			local spec = self.spec_windrower;
			
			self:animationNodesUpdate(spec, rpmValue);					
		end;
		
		-- combine animations 
		if self.spec_combine ~= nil then
			local spec = self.spec_combine;
			if spdValue ~= 0 then
				self:animationNodesUpdate(spec, spdValue);			
			else
				self:animationNodesUpdate(spec, rpmValue);
			end
		end;	
		
		-- mower animations 
		if self.spec_mower ~= nil then
			local spec = self.spec_mower;
			
			self:animationNodesUpdate(spec, rpmValue);				
		end;	


		-- foldable
		if self.spec_foldable ~= nil and not self.spec_windrower then -- SbSh - took out windrower, because saddled Windrower doesn't get lowered, it swap the move direction or something
			local spec = self.spec_foldable;
			for _, foldingPart in pairs(spec.foldingParts) do
				foldingPart.speedScale = foldingPart.speedScaleBackup * rpmValue;
				if foldingPart.animationName ~= nil then
					self:setAnimationSpeed(foldingPart.animationName, foldingPart.speedScale * spec.foldMoveDirection);
				end;
			end;
		end;
		
		-- attacher Joints moveTime 
		if self.spec_attacherJoints ~= nil then
			local spec = self.spec_attacherJoints;

			-- go through all attached implements, have to do it this way for easy access to implement.object for getIsLowered, since lowered state is not stored anywhere else
			for _, implement in pairs(spec.attachedImplements) do
				local jointDesc = spec.attacherJoints[implement.jointDescIndex]
				if implement.object:getIsLowered() == false then
					jointDesc.moveTime = math.max(jointDesc.moveTimeBackup / rpmValue, 0.4);
				else
					jointDesc.moveTime = jointDesc.moveTimeBackup / rpmValue * 1.2; -- make lowering a bit faster than default since default lowering is quite slow, and even raising at full throttle might be slower than "falling"
				end;
			end;	
		end;
		
		-----------------------------------------------------------------------------
		-- copy from above, attacherJoints, as base for
		-- frontLoader, WheelLoader moveTime ? tool.lastInputTime @Cylindered.lua ---HIER---
		--[[if self.spec_cylindered ~= nil then
			-- local spec = self.spe
			local spec = self.spec_cylindered;
			-- self.spec_cylindered.movingTools
			
			for _, implement in pairs(spec.movingTools) do
				local jointFL = spec.attacherJoints[implement.object] -- jointDescIndex replace with? attacherJoints nil need replace for FL
				if implement.object:getIsLowered() == false then
					jointFL.moveTime = jointFL.moveTimeBkup / rpmValue;
				else
					jointFL.moveTime = jointFL.moveTimeBkup / rpmValue * 1.22; -- make lowering a bit faster than lifting
				end;
			end;
			
		end;]]
		------------------------------------------------------------------------------
		-- g_currentMission:addExtraPrintText("movingTool axis: "..tostring(self.spec_cylindered.movingTools.axis))
		
		-- tippers tipping time 
		if self.spec_trailer ~= nil then
			local spec = self.spec_trailer;
			
			local tipSide = spec.tipSides[spec.currentTipSideIndex]	
			if tipSide ~= nil then
				
				-- animationNodes like rollers, belts etc. 
				self:animationNodesUpdate(tipSide, rpmValue);				
				
				-- tip animations
				if tipSide.animation ~= nil then
					if spec.tipState == Trailer.TIPSTATE_OPENING then
						self:setAnimationSpeed(tipSide.animation.name, tipSide.animation.speedScaleBackup * rpmValue);
					elseif spec.tipState == Trailer.TIPSTATE_CLOSING then
						self:setAnimationSpeed(tipSide.animation.name, -tipSide.animation.speedScaleBackup * 1.2);
					end;
				end;
				-- doorAnimation
				if tipSide.doorAnimation ~= nil then 
					if spec.tipState == Trailer.TIPSTATE_OPENING then
						self:setAnimationSpeed(tipSide.doorAnimation.name, tipSide.doorAnimation.speedScaleBackup * rpmValue);
					elseif spec.tipState == Trailer.TIPSTATE_CLOSING then
						self:setAnimationSpeed(tipSide.doorAnimation.name, -tipSide.doorAnimation.speedScaleBackup * 1.2);
					end;
				end;
				
				-- slower discharge if vehicle as a scroller/belt to unload instead of tipping 
				if self.realismAddon.rpmAnimSpeeds.hasScrollers then
					if self.spec_dischargeable ~= nil then
						local dischargeNode = self.spec_dischargeable.currentDischargeNode;
						dischargeNode.emptySpeed = dischargeNode.emptySpeedBackup * rpmValue;
					end;
				end;		


				-- if vehicle is not a scroller/belt unloader but tipper, make empty speed dependend on tip angle.. very not good way of doing but no way of 100% reading if its a tipper via script 
				--[[if tipSide.animation ~= nil then
					
					if tipSide.realismAddon_tipAnimation ~= nil then
					
						local tipValue = 1;
						
						local partX = tipSide.realismAddon_tipAnimation.partX;
						local partZ = tipSide.realismAddon_tipAnimation.partZ;
						
						if partX ~= nil then
							if partX.curRot ~= nil then
								tipValue = partX.curRot[1] / partX.endRot[1];
							end;
						elseif partZ ~= nil then
							if partZ.curRot ~= nil then
								tipValue = partZ.curRot[1] / partZ.endRot[1];
							end;						
						end;
	
						-- discharge according to percentage 
						if self.spec_dischargeable ~= nil then
							local dischargeNode = self.spec_dischargeable.currentDischargeNode;
							dischargeNode.emptySpeed = (dischargeNode.emptySpeedBackup * 2) * tipValue;
						end;
					end;
						
				end;
				]]
						
			end;
			
		end;
		
		
	
	
	end;	
end;

