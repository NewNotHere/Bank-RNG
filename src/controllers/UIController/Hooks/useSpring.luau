const RunService = game:GetService("RunService")
const React = require("../../../Packages/React")
const Spring = require("../../../Shared/Spring")
return function<T>(intial: T & (number | Vector3 | Vector2), speed: number, damping: number)
	local scale, setScale = React.useState(intial)
	local springRef = React.useRef(nil)

	if not springRef.current then
		local spring = Spring.new(intial)
		spring.Speed = speed
		spring.Damper = damping
		springRef.current = spring
	end

	React.useEffect(function()
		local con = nil

		con = RunService.PreRender:Connect(function(dt: number)
			setScale(springRef.current.Position)
		end)

		return function()
			con:Disconnect()
		end
	end)

	local setTarget = React.useCallback(function(newValue: T)
		springRef.current:SetTarget(newValue)
	end, {})

	return {
		position = scale,
		setTarget = setTarget,
	}
end
