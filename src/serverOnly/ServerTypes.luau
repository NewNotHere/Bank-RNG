const Networker = require("@game/ReplicatedStorage/Packages/Networker")
const Signal = require("@game/ReplicatedStorage/Packages/Signal")
const Trove = require("@game/ReplicatedStorage/Packages/Trove")
const Template = require("../Services/DataService/Template")
const ProfileStore = require("../ServerPackages/ProfileStore")
const ClientTypes = require("@game/ReplicatedStorage/Shared/ClientTypes")
type Service<T> = ClientTypes.Controller<T>

export type Plot = {
	Player: number,
	Plot: Model,
	Spawn: SpawnLocation,
}

export type PlayerProfile = ProfileStore.Profile<Template>

export type Template = typeof(Template)

export type Session = {
	_player: Player,
	_profile: PlayerProfile?,

	dataLoaded: Signal.Signal<PlayerProfile>,
	dataUpdated: Signal.Signal<string, any>,

	init: (self: Session) -> (),
	getAll: (self: Session) -> Template,
	get: (self: Session, key: string) -> any,
	destroy: (self: Session) -> (),
}

export type DataService = Service<DataService> & {
	_sessions: { [number]: Session },
	networker: Networker.Server,

	dataLoaded: Signal.Signal<Session>,
	dataRemoved: Signal.Signal<Session>,

	playerJoined: (self: DataService, player: Player) -> (),
	playerRemoved: (self: DataService, player: Player) -> (),
	getPlayerData: (self: DataService, player: Player) -> Template?,
	getSession: (self: DataService, player: Player) -> Session?,
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
	createFloors: (self: PlotService, player: Player, numFloors: number) -> (),
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
