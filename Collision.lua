local Collision = {}

-- basic circle - circle collision detection, simple and fast
-- passed objects are expected to be tables containing {x, y, radius} data
function Collision.check(obj1, obj2)
  return math.pow(obj2[1] - obj1[1], 2) + math.pow(obj2[2] - obj1[2], 2) <= math.pow(obj1[3] + obj2[3], 2)
end

return Collision