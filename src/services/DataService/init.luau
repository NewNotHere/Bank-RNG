const Players = game:GetService("Players")
const Networker = require("@game/ReplicatedStorage/Packages/Networker")
const Signal = require("@game/ReplicatedStorage/Packages/Signal")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")
const Session = require("@self/Session")
const ServerTypes = require("../ServerOnly/ServerTypes")
type DataService = ServerTypes.DataService

local DataService = {}

function DataService.init(self: DataService)
	self._trove = Trove.new() :: any
	self._sessions = {}

	self.dataLoaded = Signal.new()
	self.dataRemoved = Signal.new()

	self.networker = Networker.server.new("DataService", self, {
		self.getPlayerData,
	})
end

function DataService.start(self: DataService)
	Players.PlayerAdded:Connect(function(player: Player)
		self:playerJoined(player)
	end)
	for _, player in Players:GetPlayers() do
		self:playerJoined(player)
	end

	Players.PlayerRemoving:Connect(function(player: Player, a1: Enum.PlayerExitReason)
		self:playerRemoved(player)
	end)
end

function DataService.abort(self: DataService)
	self._trove:Clean()
end

function DataService.playerJoined(self: DataService, player: Player)
	if self._sessions[player.UserId] then
		return
	end

	local newSession = Session.new(player)
	newSession.dataLoaded:Connect(function(profile: ServerTypes.PlayerProfile)
		self.networker:set(player, "Data", {
			Data = profile.Data,
			Diffs = nil,
		})
		self.dataLoaded:Fire(newSession)
	end)

	newSession.dataUpdated:Connect(function(key: string, newValue)
		self.networker:set(player, "Data", {
			Data = newSession:getAll(),
			Diffs = { key, newValue },
		})
	end)

	newSession:init()

	self._sessions[player.UserId] = newSession
end

function DataService.playerRemoved(self: DataService, player: Player)
	if self._sessions[player.UserId] then
		local session = self._sessions[player.UserId]
		session:destroy()

		self.dataRemoved:Fire(session)

		self._sessions[player.UserId] = nil
	end
end

function DataService.getPlayerData(self: DataService, player: Player)
	local session = self._sessions[player.UserId]

	if session then
		return session:getAll()
	end

	return nil
end

return DataService :: DataService
