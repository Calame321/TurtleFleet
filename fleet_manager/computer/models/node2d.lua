---@class Node2D A node used in the pathfinding algorithm.
---@field x integer X position of the node in the world.
---@field z integer Z position of the node in the world.
---@field g integer Cost from the start node to this node.
---@field h integer Heuristic cost from this node to the goal node.
---@field f integer Total cost. (g + h)
---@field parent Node2D Reference to the parent Node in the path.
local Node2D = {}
Node2D.__index = Node2D

--- Constructor function to create a new Node.
---@param x integer
---@param z integer
---@return Node2D # New node object.
function Node2D.new( x, z )
  local self = setmetatable( {}, Node2D )
  self.x = x
  self.z = z
  self.g = 0
  self.h = 0
  self.f = 0
  self.parent = nil
  return self
end

---Compare two Nodes for equality.
---@param node1 Node2D Left hand side.
---@param node2 Node2D Right hand side.
---@return boolean # If they are equals.
function Node2D.__eq( node1, node2 )
  return node1.x == node2.x and node1.z == node2.z
end

return Node2D