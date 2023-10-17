---@class Node3D A node used in the pathfinding algorithm.
---@field position vector Position of the node in the world.
---@field g integer Cost from the start node to this node.
---@field h integer Heuristic cost from this node to the goal node.
---@field f integer Total cost. (g + h)
---@field parent Node3D Reference to the parent Node in the path.
local Node3D = {}
Node3D.__index = Node3D

--- Constructor function to create a new Node.
---@param pos vector
---@return Node3D
function Node3D.new( pos )
  local self = setmetatable( {}, Node3D )
  self.position = pos
  self.g = 0
  self.h = 0
  self.f = 0
  self.parent = nil
  return self
end

---Compare two Nodes for equality.
---@param node1 Node3D Left hand side.
---@param node2 Node3D Right hand side.
---@return boolean # If they are equals.
function Node3D.__eq( node1, node2 )
  return node1.position == node2.position
end

--- A key used for dictonary.
---@return string
function Node3D:key()
  return self.position.x .. "." .. self.position.y .. "." .. self.position.z
end

return Node3D