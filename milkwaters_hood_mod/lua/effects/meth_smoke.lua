EFFECT.LifeTime = 1 -- Effect lasts for 0.9 seconds

function EFFECT:Init(data)
    -- Starting position for the particles
    self.startPos = data:GetOrigin()
    self.emitter = ParticleEmitter(self.startPos)
    self.startTime = CurTime()
    self.particleCount = 0
end

function EFFECT:Think()
    -- Calculate elapsed time
    local elapsedTime = CurTime() - self.startTime

    -- Emit particles gradually
    if elapsedTime < self.LifeTime and self.emitter then
        local targetParticleCount = math.floor((elapsedTime / self.LifeTime) * 10) -- Emit 9 particles over time

        while self.particleCount < targetParticleCount do
            local particle = self.emitter:Add("particles/steam", self.startPos)
            if particle then
                local randomDirection = Vector(math.Rand(-0.3, 0.3), math.Rand(-0.3, 0.3), math.Rand(1, 2))
                particle:SetVelocity(randomDirection * 50)
				
                particle:SetLifeTime(0)
                particle:SetDieTime(math.Rand(5, 7))
				
                particle:SetStartAlpha(150)
                particle:SetEndAlpha(0)
				
                particle:SetStartSize(math.Rand(3, 5))
                particle:SetEndSize(math.Rand(10, 15))
				
                particle:SetRoll(math.random(0, 360))
                particle:SetRollDelta(math.Rand(-1, 1))
				
                particle:SetAirResistance(100)
                particle:SetGravity(Vector(0, 0, 10))
				
                particle:SetCollide(false)
            end
            self.particleCount = self.particleCount + 1
        end

        return true -- Keep the effect running
    end

    -- Cleanup the particle emitter after all particles are emitted
    if self.emitter then
        self.emitter:Finish()
        self.emitter = nil
    end
    return false -- End the effect
end

function EFFECT:Render()
    -- No specific rendering needed for this effect
end
