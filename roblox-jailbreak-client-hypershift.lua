local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local ATTRIBUTE_NAME = "HyperChromeAppliedName"
local HYPERSHIFT_VALUE = "HyperShift"
local RAINBOW_SPEED = 5


local function findOriginalResource(resourceName)
    for _, obj in ipairs(game:GetDescendants()) do
        if obj.Name == resourceName and (obj:IsA("ParticleEmitter") or obj:IsA("Attachment")) then
            return obj
        end
    end
    return nil
end

local originalShiftTemplate = findOriginalResource("HyperShiftAuraParticles")
if originalShiftTemplate then
else
end

local activeGlows = {}
local originalMaterials = {}

RunService.Heartbeat:Connect(function()
    local vehiclesFolder = Workspace:FindFirstChild("Vehicles")
    if not vehiclesFolder then return end
    
    local vehicles = vehiclesFolder:GetChildren()
    local hue = (os.clock() % RAINBOW_SPEED) / RAINBOW_SPEED
    local rainbowColor = Color3.fromHSV(hue, 1, 1)

    for _, vehicle in ipairs(vehicles) do
        if vehicle.Name == "Heli" then
            continue
        end
        
        local seat = vehicle:FindFirstChild("Seat")
        local isMyVehicle = false
        
        if seat and seat:FindFirstChild("PlayerName") and seat.PlayerName.Value == localPlayer.Name then
            isMyVehicle = true
        end
        
        if isMyVehicle then
            vehicle:SetAttribute(ATTRIBUTE_NAME, HYPERSHIFT_VALUE)
            
            local targetPart = vehicle:FindFirstChild("Engine") or vehicle:FindFirstChild("Body") or vehicle:FindFirstChildOfClass("BasePart")
            
            if targetPart and targetPart:IsA("BasePart") then
                if not activeGlows[vehicle] then
                    local attachment = Instance.new("Attachment")
                    attachment.Name = "ExactHyperShiftGlow"
                    attachment.Parent = targetPart
                    
                    if originalShiftTemplate then
                        local clonedFX = originalShiftTemplate:Clone()
                        clonedFX.Parent = attachment
                        
                        activeGlows[vehicle] = {
                            attachment = attachment,
                            emitter = clonedFX:IsA("ParticleEmitter") and clonedFX or clonedFX:FindFirstChildOfClass("ParticleEmitter")
                        }
                    end
                end
                
                local fxData = activeGlows[vehicle]
                if fxData and fxData.emitter then
                    fxData.emitter.Color = ColorSequence.new(rainbowColor)
                end
                
                for _, part in ipairs(vehicle:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "NewForce" and part.Name ~= "BodyForce" then
                        local partNameLower = string.lower(part.Name)
                        
                        if not string.find(partNameLower, "wheel") and not string.find(partNameLower, "glass") and not string.find(partNameLower, "window") then
                            part:SetAttribute(ATTRIBUTE_NAME, HYPERSHIFT_VALUE)
                            
                            if not originalMaterials[part] then
                                originalMaterials[part] = part.Material
                            end
                            
                            part.Color = rainbowColor
                            part.Material = Enum.Material.Neon
                        end
                    end
                end
            end
            
        else
            if activeGlows[vehicle] then
                if activeGlows[vehicle].attachment then
                    activeGlows[vehicle].attachment:Destroy()
                end
                activeGlows[vehicle] = nil
                
                vehicle:SetAttribute(ATTRIBUTE_NAME, nil)
                for _, part in ipairs(vehicle:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part:SetAttribute(ATTRIBUTE_NAME, nil)
                        
                        if originalMaterials[part] then
                            part.Material = originalMaterials[part]
                            originalMaterials[part] = nil
                        end
                    end
                end
            end
        end
    end
end)
