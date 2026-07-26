local FORCEFIELD_TEXTURE = "rbxassetid://6838365481"

local DEFAULT_COLOUR = Color3.fromRGB(53, 157, 243)

local function applyPart(part: BasePart, color: Color3?)
	local newColor = color ~= nil and color or DEFAULT_COLOUR

	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.TextureId = FORCEFIELD_TEXTURE
	specialMesh.MeshType = Enum.MeshType.FileMesh
	specialMesh.Scale = part.Size

	part.Material = Enum.Material.ForceField
	specialMesh.VertexColor = Vector3.new(newColor.R, newColor.G, newColor.B)
	specialMesh.Parent = part
end

return function(model: Model | BasePart, color: Color3?)
	if model:IsA("Model") then
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				applyPart(part, color)
			end
		end
	elseif model:IsA("BasePart") then
		applyPart(model, color)
	else
		warn(`Forcefield Effect only works on Models and BaseParts!`)
	end
end
