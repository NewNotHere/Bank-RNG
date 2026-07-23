const Networker = require("../Packages/Networker")
const Signal = require("../Packages/Signal")
const Trove = require("../Packages/Trove")
const ClientTypes = require("../Shared/ClientTypes")
type PlotController = ClientTypes.PlotController

local PlotController = {}

function PlotController.init(self: PlotController)
	self._trove = Trove.new() :: any
	self.clientPlotLoaded = Signal.new()
	self.networker = Networker.client.new("PlotService", self)
end

function PlotController.start(self: PlotController) end

function PlotController.abort(self: PlotController)
	self._trove:Clean()
end

function PlotController.plotLoaded(self: PlotController, model: Model)
	self.clientPlotLoaded:Fire(model)
end

function PlotController.getPlot(self: PlotController)
	return self.networker:fetch("getPlayerPlot")
end

function PlotController.getPlotAxis(self: PlotController)
	return self.networker:fetch("getPlotAxis")
end

return PlotController :: PlotController
