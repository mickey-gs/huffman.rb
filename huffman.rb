#huffman_master.rb

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

puts " >Hi! Welcome to Huffman.rb. This program exists to help you compress text.\n"
while true
  print " >Would you like to compress or decompress a message? (C/D) "
  answer = gets.chomp.to_s
  break unless answer.match?(/[CcDd]/) == false
end

if answer.downcase == "c"
  puts " >Would you like to compress a text file (1), or compress text typed into the terminal (2)? "
  while true
    option = gets.chomp.to_s
    option.match?(/[12]/) ? break : puts(" >Please pick option 1 or option 2.")
  end
  
  if option == "1"
    puts(" >What is the name of the text file? ( [name].txt )")
    while true
      text_file = gets.chomp.to_s
      File.exist?(text_file + ".txt") ? break : puts(" >File doesn't exist! Please try again.")
    end
    input = File.open("#{text_file}.txt", "r").read
  else
    puts " >Simply enter the text that you'd like to compress, hit enter, and a file will be generated with your " +
    "compressed text and a Huffman tree (this is needed to decrypt the message)."
    while true
      print "Your text: "
      input = gets.chomp.to_s
      input.length == 0 ? (puts "Invalid length!") : break
    end
  end
  puts " >Thanks!"
  puts " >Under what name do you want to save your files? It is important to pick a memorable name," +
  "as you will need to use the same directory to decompress your files later. "
  while true
    name = gets.chomp.to_s
    Dir.exist?(name) ? puts("That directory already exists! Please enter a different name.") : break
  end
  Dir.mkdir(name)
  path = "./#{name}"
  output = compress(input)
  root = output[0]
  sequence = to_binary(output[1], root)
  File.open("#{path + "/tree"}", "w") do |f|
    Marshal.dump(root, f)
    f.close
  end
  File.open("#{path + "/sequence.txt"}", "w") do |f|
    f.write sequence
    f.close
  end


else
  print " >Under what directory is your compressed text saved? "
  while true
    dir = gets.chomp.to_s
    break if Dir.exist?(dir) == true
    print " >Oops! Looks like that directory doesn't exist. Please try again. "
  end
  puts " >Here is your text: "
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  decompress(dir)
end

puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
puts ">Thank you for using Huffman.rb!"
