const React = require("../../../Packages/React")
const TableUtil = require("../../../Packages/TableUtil")
local e = React.createElement

return function(props)
	local combined = TableUtil.Assign(props, {
		FontFace = Font.fromId(11702779240, Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
		TextScaled = true,
	})

	return e("TextLabel", combined, props.children)
end
