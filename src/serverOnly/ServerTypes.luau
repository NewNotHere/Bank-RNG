const Networker = require("@game/ReplicatedStorage/Packages/Networker")
const Signal = require("@game/ReplicatedStorage/Packages/Signal")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")
const ClientTypes = require("@game/ReplicatedStorage/Shared/ClientTypes")
type Service<T> = ClientTypes.Controller<T>

export type Plot = {
	Player: number,
	Plot: Model,
	Spawn: SpawnLocation,
}

export type PlotService = Service<PlotService> & {
	_allPlots: { Plot },

	networker: Networker.Server,
	plotLoaded: Signal.Signal<Player, Plot>,

	loadAllPlots: (self: PlotService) -> (),
	givePlotToPlayer: (self: PlotService, player: Player) -> (),
	removePlayerPlot: (self: PlotService, player: Player) -> (),

	getPlayerPlot: (self: PlotService, player: Player) -> Model?,
	getPlotAxis: (self: PlotService, player: Player) -> CFrame?,
}

export type PlacementService = Service<PlacementService> & {
	networker: Networker.Server,

	tryPlace: (self: PlacementService, player: Player, name: string, cframe: CFrame) -> (),
}

export type BaseAsset<T> = {
	_model: Model,
	_trove: Trove.Trove,

	init: (self: T) -> (),
	update: (self: T, dt: number) -> (),
	destroy: (self: T) -> (),
}

export type LaserArray = BaseAsset<LaserArray> & {
	setVisible: (self: LaserArray, visible: boolean) -> (),
}

return {}
