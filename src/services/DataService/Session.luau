const Players = game:GetService("Players")
const Signal = require("@game/ReplicatedStorage/Packages/Signal")
const ServerTypes = require("../../ServerOnly/ServerTypes")
const ProfileStore = require("../../ServerPackages/ProfileStore")
const Template = require("./Template")
type Session = ServerTypes.Session

local PlayerStore = ProfileStore.New("PlayerData", Template)

local session = {}
session.__index = session

function session.new(player: Player)
	local self = setmetatable({}, session)

	self._player = player
	self._profile = nil
	self.dataLoaded = Signal.new()
	self.dataUpdated = Signal.new()

	return self
end

function session.init(self: Session)
	local profile = PlayerStore:StartSessionAsync(`{self._player.UserId}`, {
		Cancel = function()
			return self._player.Parent ~= Players
		end,
	})

	if profile then
		profile:AddUserId(self._player.UserId)
		profile:Reconcile()

		profile.OnSessionEnd:Connect(function()
			self._profile = nil
			self._player:Kick(`Profile Session ended, please rejoin`)
		end)

		if self._player.Parent == Players then
			self._profile = profile
			self.dataLoaded:Fire(profile)
		else
			profile:EndSession()
		end
	else
		self._player:Kick(`Profile load failed! Please rejoin`)
	end
end

function session.getAll(self: Session)
	if self._profile then
		return self._profile.Data
	end

	return nil
end

function session.get(self: Session, key: string)
	local data = self:getAll()

	return data[key]
end

function session.set(self: Session, key: string, fn: (oldValue: any) -> ())
	if not self._profile then
		return
	end

	if self._profile.Data[key] then
		local success, newValue = pcall(fn, self._profile.Data[key])

		if not success then
			error(`Error updating new Value for {key}!: {newValue}`)
		end

		self._profile.Data[key] = newValue

		self.dataUpdated:Fire(key, newValue)
	end
end

function session.destroy(self: Session)
	if self._profile then
		self._profile:EndSession()
		self._profile = nil
	end

	self.dataLoaded:DisconnectAll()
	self.dataUpdated:DisconnectAll()
end

return session
