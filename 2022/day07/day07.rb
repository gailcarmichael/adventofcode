class FilesystemItem
    attr_reader :name
    attr_reader :type
    attr_reader :size
    attr_reader :parent
    attr_reader :children

    def initialize(parent, name, type, size=0)
        @name = name
        @type = type
        @size = size
        @parent = parent
        @children = Array.new
    end

    def compute_size
        if @type == :dir && @size <= 0
            @size = @children.inject(0) do |so_far, child| 
                so_far + child.compute_size
            end
        end

        @size
    end

    def this_and_all_subdirectories
        return [] if @type == :file

        [self] + @children.inject(Array.new) {|so_far, child| so_far + child.this_and_all_subdirectories}
    end
end

class Filesystem
    attr_reader :root
    attr_reader :curr_dir

    def initialize
        @root = FilesystemItem.new(nil, '/', :dir)
        @curr_dir = @root
        @name_to_node = {'/' => @root}
    end

    def to_s
        to_s_internal(@root, 0)
    end

    def find_node(name_to_find)
        @name_to_node[name_to_find]
    end

    def move_up_one_dir
        if @curr_dir != @root
            @curr_dir = @curr_dir.parent
        end
    end

    def change_dir(new_dir_name)
        new_dir = @curr_dir.children.filter {|child| child.name == new_dir_name}[0]
        if new_dir == nil
            puts "Could not change to #{new_dir_name}"
        else
            @curr_dir = new_dir
        end
    end

    def add_item(parent_node, name, type, size=0)
        new_node = FilesystemItem.new(parent_node, name, type, size)
        parent_node.children.push(new_node)
        @name_to_node[name] = new_node
    end

    def all_directories
        @root.this_and_all_subdirectories
    end

    def size_dir_to_delete
        @root.compute_size
        initial_unused_space = 70000000 - @root.size
        min_delete_size = 30000000 - initial_unused_space
        candidates = all_directories.filter{|dir| dir.size >= min_delete_size }
        candidates.map{|dir| dir.size}.min
    end

    private 

    def to_s_internal(node, num_indents)
        result = "#{"\n" if num_indents >= 1}"
        result += "#{"\t" * num_indents}- #{node.name} (#{node.type}"
        result += ", size=#{node.size}"
        result += ")"

        result += node.children.inject("") do |so_far, child_node|
            so_far + to_s_internal(child_node, num_indents + 1)
        end
        
        result
    end
end

#######################

def process_file(filename)
    filesystem = Filesystem.new

    lines = File.read(filename).strip.split("\n")[1..-1] # skip first command which changes to root dir

    while !lines.empty?
        next_line = lines.shift

        if next_line[0..6] == "$ cd .."
            filesystem.move_up_one_dir
        elsif next_line[0..3] == "$ cd"
            filesystem.change_dir(next_line[5..-1])
        elsif next_line[0..3] == "$ ls"
            loop do
                break if lines.empty?

                next_line = lines.shift
                
                if next_line[0] == "$"
                    lines.unshift(next_line)
                    break
                end
                
                next_line_parts = next_line.split(" ")
                if next_line_parts[0] == "dir"
                    filesystem.add_item(filesystem.curr_dir, next_line_parts[1], :dir)
                else
                    filesystem.add_item(filesystem.curr_dir, next_line_parts[1], :file, next_line_parts[0].to_i)
                end
            end
        end
    end

    filesystem
end

filesystem_test = process_file("day07-input-test.txt")
filesystem_test.root.compute_size
puts "Sum of total directory sizes max 100000 (test):
    #{filesystem_test.all_directories.filter {|dir| dir.size <= 100000}
                                     .inject(0) {|so_far, item| so_far + item.size}}"

puts "Size of directory to delete (test): #{filesystem_test.size_dir_to_delete}"


filesystem_real = process_file("day07-input.txt")
filesystem_real.root.compute_size
directories = filesystem_real.all_directories.filter {|dir| dir.size <= 100000}
puts "Sum of total directory sizes max 100000 (real):
    #{directories.inject(0) {|so_far, item| so_far + item.size}}"

puts "Size of directory to delete (real): #{filesystem_real.size_dir_to_delete}"