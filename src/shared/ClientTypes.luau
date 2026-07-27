const Networker = require("../Packages/Networker")
const Promise = require("../Packages/Promise")
const ReactRoblox = require("../Packages/ReactRoblox")
const Signal = require("../Packages/Signal")
const Trove = require("../Packages/Trove")

export type Controller<T> = {
	_trove: Trove.Trove,

	init: (self: T) -> (),
	start: (self: T) -> (),
	abort: (self: T) -> (),
}

export type InputMap = {
	Key: Enum.KeyCode | Enum.UserInputType,
	Value: number | Vector2,
}

export type PlacementController = Controller<PlacementController> & {
	_mouse: Mouse,
	_plotModel: Model?,
	_placing: Model?,
	_state: string,
	_highlight: Highlight?,
	_selected: Model?,

	networker: Networker.Client,
	placementStateChanged: Signal.Signal<string>,

	getState: (self: PlacementController) -> string,
	buildingState: (self: PlacementController) -> (),
	selectState: (self: PlacementController) -> (),

	setPlacementVisual: (self: PlacementController, model: Model) -> (),
	setPlacementModel: (self: PlacementController, modelName: string) -> (),
	getPlacementModel: (self: PlacementController) -> Model?,
	setPlotModel: (self: PlacementController, model: Model) -> (),
	getSelected: (self: PlacementController) -> Model?,
	select: (self: PlacementController, modelToSelect: Model) -> (),

	_buildUpdate: (self: PlacementController, dt: number) -> (),
	_hoverUpdate: (self: PlacementController, dt: number) -> (),
	_getPlotFacing: (self: PlacementController) -> Vector3,

	tryPlace: (self: PlacementController) -> (),
}

export type PlotController = Controller<PlotController> & {
	networker: Networker.Client,
	clientPlotLoaded: Signal.Signal<Model>,

	plotLoaded: (self: PlotController, plot: Model) -> (),
	getPlot: (self: PlotController) -> Model?,
	getPlotAxis: (self: PlotController) -> CFrame?,
}

export type CameraController = Controller<CameraController> & {
	camera: DefaultCamera<{}>,

	switchCam: (self: CameraController, newCam: DefaultCamera<{}>) -> (),
	getCamera: (self: CameraController) -> Camera,
	getActiveCamera: (self: CameraController) -> DefaultCamera<{}>,
}

export type UIController = Controller<UIController> & {}
export type InputController = Controller<InputController> & {
	_actions: { string },
	_mappings: { InputMap },
	_values: { [Enum.KeyCode | Enum.UserInputType]: number | Vector2 },
	_inputType: Enum.PreferredInput,
	_defaultControls: any?,
	_mobileButtons: { MobileButton },

	deviceChanged: Signal.Signal<Enum.PreferredInput>,

	registerInputMap: (self: InputController, inputMap: InputMap) -> (),
	getInputValue: (self: InputController, key: Enum.KeyCode | Enum.UserInputType) -> (number | Vector2)?,
	getDeviceInput: (self: InputController) -> Enum.PreferredInput,
	getInputAxis: (self: InputController) -> Vector2,
	addMobileButton: (self: InputController, mobileButtonProps: MobileButton, cb: (...any?) -> (), ...any?) -> string,
	removeMobileButtons: (self: InputController, btnId: string) -> (),
}
export type MobileButton = {
	Position: UDim2,
	Type: "Big" | "Small",
	Icon: string,
	ScaleRatio: number,
	Callback: () -> (),
}

export type DataController = Controller<DataController> & {
	_replicatedData: any,
	networker: Networker.Client,

	dataUpdated: Signal.Signal<string, any>,

	publishDataLoad: (self: DataController) -> (),
	replicatePlayerData: (self: DataController, key: string, newValue: any) -> (),
	waitForProfileLoaded: (self: DataController) -> typeof(Promise.new()),
}

export type Mouse = {
	_camera: Camera,

	GetHit: (self: Mouse, raycastParams: RaycastParams?) -> RaycastResult,
	getMouseRay: (self: Mouse) -> Ray,
}

export type DefaultCamera<T> = {
	_camera: Camera,
	_trove: Trove.Trove,
	_cframe: CFrame,
	_bindName: string,

	new: () -> T,
	init: (self: T) -> (),
	enable: (self: T) -> (),
	disable: (self: T) -> (),

	update: (self: T, dt: number) -> (),
	getCFrame: (self: T) -> CFrame,
	projectVirtualCursor: (self: T, virtualCursor: Vector2) -> Ray,
}

export type PlotCamera = DefaultCamera<PlotCamera> & {
	_plot: Model,
	_xOffset: number,
	_zOffset: number,
	_inspecting: Model?,

	moveX: (self: PlotCamera, direction: number) -> (),
	moveZ: (self: PlotCamera, direction: number) -> (),
	inspectWall: (self: PlotCamera, wallModel: Model) -> (),
	stopWallInspection: (self: PlotCamera) -> (),
}

export type Gizmo<T> = {
	_trove: Trove.Trove,
	_camera: Camera,
	_model: Model,
	_mouse: Mouse,
	_hoveringInstance: BasePart?,
	_cframe: CFrame,
	cframeChanged: Signal.Signal<CFrame>,

	init: (self: T) -> (),
	onCreated: (self: T) -> (),
	onUpdate: (self: T, dt: number) -> (),
	onMoveAttempt: (self: T, moveDelta: Vector2, dt: number, hitPosition: Vector3?) -> (),
	onDestroyed: (self: T) -> (),
	createGizmo: (self: T, position: Vector3, lookVector: Vector3?, rightVector: Vector3?, upVector: Vector3?) -> (),
	updateGizmo: (self: T) -> (),
	getNewCFrame: (self: T) -> CFrame,
	getHovering: (self: T) -> BasePart?,
	destroy: (self: T) -> (),
}

export type TranslateGizmo = Gizmo<TranslateGizmo> & {
	_xAxis: Vector3,
	_yAxis: Vector3,
	_zAxis: Vector3,
	_grid: number,
	_rawCFrame: CFrame,

	moveX: (self: TranslateGizmo, moveDelta: Vector2, dt: number) -> (),
	moveY: (self: TranslateGizmo, moveDelta: Vector2, dt: number) -> (),
	moveZ: (self: TranslateGizmo, moveDelta: Vector2, dt: number) -> (),
}

export type RotateGizmo = Gizmo<RotateGizmo> & {
	_xAxis: Vector3,
	_yAxis: Vector3,
	_zAxis: Vector3,
	_grid: number,
	_rawCFrame: CFrame,
	_dragging: boolean,
	_currentAngle: number,
}

return {}
