-- by modelleicher
-- 2021
-- BETA Release 10/2021 due to FS22 being close, script is nowhere near done yet 


realismAddon_rpmAnimSpeeds = {};


function realismAddon_rpmAnimSpeeds.prerequisitesPresent(specializations)
    return true;
end;

function realismAddon_rpmAnimSpeeds.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", realismAddon_rpmAnimSpeeds);
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", realismAddon_rpmAnimSpeeds);
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
		end;	
	end;
	return hasScrollers;
end;

function realismAddon_rpmAnimSpeeds:onPostLoad(savegame)
	self.animationNodesLoad = realismAddon_rpmAnimSpeeds.animationNodesLoad;
	self.animationNodesUpdate = realismAddon_rpmAnimSpeeds.animationNodesUpdate;
	
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
		
		
		
		
		-- foldable
		if self.spec_foldable ~= nil then
			local spec = self.spec_foldable;
			for _, foldingPart in pairs(spec.foldingParts) do
				foldingPart.speedScaleBackup = foldingPart.speedScale;
			end;
		end;
	
	
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
			if animation.rotSpeed ~= nil then
				animation.rotSpeed = animation.rotSpeedBackup * rpmValue;
			end;
			if animation.scrollSpeed ~= nil then
				animation.scrollSpeed = animation.scrollSpeedBackup * rpmValue;
			end;
		end;	
	end;
end;

function realismAddon_rpmAnimSpeeds:onUpdate(dt)
	
	if self.isClient then
	
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
			local rpm = motor:getEqualizedMotorRpm()
			local maxRpm = motor:getMaxRpm()
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
			
			self:animationNodesUpdate(spec, rpmValue);			
		end;	
		
		-- mower animations 
		if self.spec_mower ~= nil then
			local spec = self.spec_mower;
			
			self:animationNodesUpdate(spec, rpmValue);				
		end;	


		-- foldable
		if self.spec_foldable ~= nil then
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
					jointDesc.moveTime = jointDesc.moveTimeBackup / rpmValue;
				else
					jointDesc.moveTime = jointDesc.moveTimeBackup * 0.8; -- make lowering a bit faster than default since default lowering is quite slow, and even raising at full throttle might be slower than "falling"
				end;
			end;
			
		end;
		
		
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
