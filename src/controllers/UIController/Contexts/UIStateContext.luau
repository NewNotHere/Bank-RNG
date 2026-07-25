const React = require("../../../Packages/React")

type Context = {
	state: string,
	setState: (newState: string) -> (),
}

local Context = React.createContext(nil :: Context?)

local e = React.createElement

local function provider(props)
	local uiState, setUIState = React.useState("Build")

	local value = {
		state = uiState,
		setState = function(newState: string)
			setUIState(newState)
		end,
	}

	return e(Context.Provider, {
		value = value,
	}, props.children)
end

return {
	context = Context,
	provider = provider,
}
