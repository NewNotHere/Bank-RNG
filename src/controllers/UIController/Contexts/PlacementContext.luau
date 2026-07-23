const React = require("../../../Packages/React")
const PlacementController = require("../../PlacementController")

type PlacementContext = {
	setBuildMode: () -> (),
	setTranslateMode: () -> (),
	setRotateMode: () -> (),
}

local Context = React.createContext(nil :: PlacementContext?)

local e = React.createElement

local function Provider(props)
	local value = {
		setBuildMode = function()
			PlacementController:buildingState()
		end,
		setTranslateMode = function()
			PlacementController:translateState()
		end,
		setRotateMode = function()
			PlacementController:rotateState()
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
