#compressor.rb

class Node
  def initialize(value, weight, left = nil, right = nil)
    @value = value
    @weight = weight
    @left = left
    @right = right
  end

  def combine(node)
    combined = Node.new(@value + node.value, @weight + node.weight)
    if self.weight < node.weight
      combined.left = self
      combined.right = node
    else
      combined.left = node
      combined.right = self
    end
    return combined
  end

  attr_accessor :value, :weight, :left, :right
end

def tally(string)
  log = {}
  for char in string
    log[char] == nil ? log[char] = 1 : log[char] += 1
  end
  return log
end

def create_nodes(hash)
  node_list = []
  for key, weight in hash
    node = Node.new(key, weight)
    node_list << node
  end
  return node_list
end

def sort(list)
  i = 0
  while i < list.length - 1
    if list[i].weight > list[i + 1].weight
      first = list[i].clone
      list[i] = list[i + 1]
      list[i + 1] = first
      sort(list)
      return list
    else
      i += 1
      next
    end
  end
  return list
end

def to_binary(string, root)
  origin = root.clone
  sequence = ""
  for char in string
    while true
      if root.value.include?(char) && root.value.length == 1
        root = origin
        break
      elsif
        root.left.value.include?(char)
        sequence += "0"
        root = root.left
      else
        sequence += "1"
        root = root.right
      end
    end
  end
  return sequence
end

def compress(string)
  string = string.split("")
  nodes = create_nodes(tally(string))
  while nodes.length > 1
    sorted = sort(nodes)
    weak = nodes.shift
    strong = nodes.shift
    nodes << weak.combine(strong)
  end
  return [nodes[0], string] 
end

def decompress(directory)
  root = Marshal.load(File.open("#{directory}/tree", "r"))
  sequence = File.open("#{directory}/sequence.txt", "r").read
  sequence = sequence.to_s.split("")
  chunk = []
  node = root
  while sequence.length > 0
    chunk << sequence.shift
    node = root
    for digit in chunk
      digit == "0" ? node = node.left : node = node.right
      if node.left == nil && node.right == nil
        value = node.value
        print value
        node = root
        chunk = []
        break
      end
    end
  end
  puts ""
end
