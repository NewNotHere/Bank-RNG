const React = require("../../Packages/React")
const ReactRoblox = require("../../Packages/ReactRoblox")
const App = require("./App")

const e = React.createElement

return function(target)
	local root = ReactRoblox.createRoot(target)
	print(target)
	root:render(e(App))

	return function()
		root:unmount()
	end
end
