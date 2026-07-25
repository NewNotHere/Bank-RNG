const TweenService = game:GetService("TweenService")
const Trove = require("../../Packages/Trove")

return function(model: Model, tweenInfo: TweenInfo, endSize: number)
	local _trove = Trove.new()

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0

	_trove:Add(numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		local currentValue = math.max(numberValue.Value, 0.001)

		model:ScaleTo(currentValue)
	end))

	local tween = TweenService:Create(numberValue, tweenInfo, { Value = endSize })
	tween:Play()
	_trove:Add(tween)

	tween.Completed:Once(function(state: Enum.PlaybackState)
		if state == Enum.PlaybackState.Completed then
			_trove:Destroy()
		end
	end)

	return tween
end
