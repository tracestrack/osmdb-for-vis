local open = io.open

local tag_key = {}        -- table to collect fields

function fromCSV (s)
   s = s .. ';'        -- ending comma
   local t = {}        -- table to collect fields
   local fieldstart = 1
   repeat
      local nexti = string.find(s, ';', fieldstart)

      table.insert(t, string.sub(s, fieldstart, nexti-1))

      fieldstart = nexti + 1

   until fieldstart > string.len(s)
   return t
end

function trim1(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local wayid = 1
local nodeid = 1

function createNode(id)
   lat = id * 0.1
   return '<node id="-'..id..'" lat="'..lat..'" lon="10" /><node id="-'..id + 1 ..'" lat="'..lat..'" lon="20" />'
end

function createXML(tb)
   str = createNode(nodeid)
   str = str .. '<way id="-' .. wayid .. '"><nd ref="-' .. nodeid .. '"/><nd ref="-' .. nodeid + 1 .. '"/>'
   wayid = wayid + 1
   nodeid = nodeid + 2

   for k, v in pairs(tb) do
      str = str .. '<tag k="' .. k .. '" v="' .. v .. '"/>'
   end
   str = str .. '</way>'
   print(str)
end

read_file = function (path)
   local file = io.open(path, "rb")
   if not file then return nil end

   local lines = {}

   for line in io.lines(path) do
      t = fromCSV(line)
      if #tag_key == 0 then
         tag_key = t
      else
         tb = {}
         for i, v in pairs(t) do
            tv = trim1(v)
            if tv ~= "" then
               tb[tag_key[i]] = tv
               --print(i, string.byte(v))
            end

         end
         createXML(tb)
      end
   end

   file:close()
   return lines;
end

print([[<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="CGImap 0.0.2">]])

read_file("highway.csv")

print([[</osm>]])
