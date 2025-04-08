function EFFECT:Init(data)
    self.offset = data:GetOrigin() + Vector(0, 0, 0.2)
    self.particles = 32
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
    local emitter = ParticleEmitter(self.offset, false)
    if not emitter then return end

    for i = 1, self.particles do
        local particle = emitter:Add("particles/steam", self.offset) -- Use a soft smoke-like material
        if particle then
            local randomDirection = Vector(math.Rand(-0.3, 0.3), math.Rand(-0.3, 0.3), math.Rand(1, 2))
            particle:SetVelocity(randomDirection * 100) -- Lower speed for smooth rising

            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1, 2)) -- Random lifespan for natural dispersion

            particle:SetStartAlpha(150) -- Semi-transparent at start
            particle:SetEndAlpha(0) -- Gradually fade out

            particle:SetStartSize(math.Rand(3, 5)) -- Small initial size
            particle:SetEndSize(math.Rand(10, 15)) -- Expands as it rises

            particle:SetRoll(math.random(0, 360))
            particle:SetRollDelta(math.Rand(-1, 1))

            particle:SetAirResistance(200) -- Simulate air resistance to slow down particles
            particle:SetGravity(Vector(0, 0, 10)) -- Slight upward gravity for rising motion

            particle:SetCollide(false) -- No collision for smoother effect
        end
    end

    emitter:Finish()
end
