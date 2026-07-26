const Signal = require("../../Packages/Signal")
const ClientTypes = require("../../Shared/ClientTypes")
local MobileStore = {
	_buttons = {},
	changed = Signal.new(),
} :: {
	_buttons: { [string]: ClientTypes.MobileButton },
	changed: Signal.Signal<{ [string]: ClientTypes.MobileButton }>,

	add: (id: string, data: ClientTypes.MobileButton) -> (),
	remove: (id: string) -> (),
	getSnapshot: () -> { [string]: ClientTypes.MobileButton },
}

function MobileStore.add(id: string, data: ClientTypes.MobileButton): ()
	local new = table.clone(MobileStore._buttons)
	new[id] = data
	MobileStore._buttons = new
	MobileStore.changed:Fire(new)
end

function MobileStore.remove(id: string): ()
	local new = table.clone(MobileStore._buttons)

	if new[id] then
		new[id] = nil

		MobileStore._buttons = new
		MobileStore.changed:Fire(new)
	end
end

function MobileStore.getSnapshot(): { [string]: ClientTypes.MobileButton }
	return MobileStore._buttons
end

return MobileStore
