const Networker = require("../Packages/Networker")
const Promise = require("../Packages/Promise")
const Signal = require("../Packages/Signal")
const Trove = require("../Packages/Trove")
const ClientTypes = require("../Shared/ClientTypes")
type DataController = ClientTypes.DataController

local TIMEOUT = 10

local DataController = {}

function DataController.init(self: DataController)
	self._trove = Trove.new() :: any
	self._replicatedData = nil

	self.dataUpdated = Signal.new()
	self.networker = Networker.client.new("DataService", self)
end

function DataController.start(self: DataController)
	self.networker:getServerChangedSignal("Data"):Connect(function(data: any)
		self._replicatedData = data.Data

		if data.Diffs then
			self.dataUpdated:Fire(unpack(data.Diffs))
		end
	end)
end

function DataController.abort(self: DataController)
	self._trove:Clean()
end

function DataController.waitForProfileLoaded(self: DataController)
	return Promise.new(function(resolve, reject, onCancel)
		local called = os.clock()

		if self._replicatedData then
			resolve(self._replicatedData)
			return
		end

		while os.clock() - called <= TIMEOUT do
			print(`Attempting to fetch profile!`)
			self._replicatedData = self.networker:fetch("getPlayerData")

			if self._replicatedData then
				print(`Got profile data!`)
				break
			end
		end

		if not self._replicatedData then
			reject(`Profile load timeout!`)
		end

		resolve(self._replicatedData)
	end)
end

return DataController :: DataController
