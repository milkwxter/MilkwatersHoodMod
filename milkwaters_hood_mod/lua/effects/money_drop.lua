function EFFECT:Init( data )
	self.offset = data:GetOrigin() + Vector( 0, 0, 0.2 )
	self.particles = 32
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	local emitter = ParticleEmitter( self.offset, false )
		for i=0, self.particles do
			local particle = emitter:Add( "particles/dollar", self.offset )
			if particle then
				local randomDirection = Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(1, 2))
				particle:SetVelocity(randomDirection * 150)
				
				particle:SetLifeTime(0)
				particle:SetDieTime(2)
				
				particle:SetStartSize(5)
				particle:SetEndSize(0)
				
				particle:SetRoll(math.random(0, 360))
				particle:SetRollDelta(math.random(-2, 2))

				particle:SetAirResistance(50)
				particle:SetGravity(Vector(0, 0, -300))
				particle:SetBounce(1)
				particle:SetCollide(true)
			end
		end
	emitter:Finish()
end