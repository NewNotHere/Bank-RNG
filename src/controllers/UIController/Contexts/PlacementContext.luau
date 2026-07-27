const RunService = game:GetService("RunService")
const React = require("../../../Packages/React")
const PlacementController = require("../../PlacementController")

type PlacementContext = {
	setPlacementModel: (name: string) -> (),
	setBuildMode: () -> (),
	setSelectMode: () -> (),
	revertMode: () -> (),
}

local Context = React.createContext(nil :: PlacementContext?)

local e = React.createElement

local function Provider(props)
	local value = {
		setPlacementModel = function(name: string)
			if PlacementController:getState() ~= "Build" then
				return
			end

			PlacementController:setPlacementModel(name)
		end,

		setBuildMode = function()
			PlacementController:buildingState()
		end,

		setSelectMode = function()
			PlacementController:selectState()
		end,

		revertMode = function()
			PlacementController:abort()
		end,
	}

	return e(Context.Provider, {
		value = value,
	}, props.children)
end

return {
	context = Context,
	provider = Provider,
}
