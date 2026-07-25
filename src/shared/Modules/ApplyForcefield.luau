local FORCEFIELD_TEXTURE = "rbxassetid://6838365481"

local function applyPart(part: BasePart)
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.TextureId = FORCEFIELD_TEXTURE
	specialMesh.MeshType = Enum.MeshType.FileMesh
	specialMesh.Scale = part.Size

	part.Material = Enum.Material.ForceField
	specialMesh.VertexColor = Vector3.new(53 / 255, 157 / 255, 243 / 255)
	specialMesh.Parent = part
end

return function(model: Model | BasePart)
	if model:IsA("Model") then
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				applyPart(part)
			end
		end
	elseif model:IsA("BasePart") then
		applyPart(model)
	else
		warn(`Forcefield Effect only works on Models and BaseParts!`)
	end
end
