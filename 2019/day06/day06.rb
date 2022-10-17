require 'set'

class OrbitGraph
    def initialize
        @objects = Set.new
        @orbit_parent_hash = Hash.new
        @orbit_children_hash =  Hash.new { |hash, key| hash[key] = Set.new }

    end

    def add_orbit_relationship(base, orbiting)
        @objects.add(base)
        @objects.add(orbiting)
        @orbit_parent_hash[orbiting] = base
        @orbit_children_hash[base].add(orbiting)
    end

    def direct_orbits(object)
        @orbit_parent_hash.key?(object) ? 1 : 0
    end

    def indirect_orbits(object)
        return 0 if direct_orbits(object) == 0

        ancestor = @orbit_parent_hash[@orbit_parent_hash[object]]
        indirect_orbits = 0
        while ancestor != nil
            indirect_orbits += 1
            ancestor = @orbit_parent_hash[ancestor]
        end
        indirect_orbits
    end

    def total_orbits(object)
        direct_orbits(object) + indirect_orbits(object)
    end

    def total_orbits_all_objects
        @objects.reduce(0) { |memo, object| memo + direct_orbits(object) + indirect_orbits(object) }
    end

    def orbital_transfers_needed(object1, object2)
        object1_ancestors = all_ancestors(object1)
        object2_ancestors = all_ancestors(object2)
        first_common_ancestor = (object1_ancestors & object2_ancestors)[0]
        
        (object1_ancestors.find_index(first_common_ancestor)+1) +
            (object2_ancestors.find_index(first_common_ancestor)+1) -
            2 # remove the double-count of the common ancestor, and object1's first ancestor it is already orbiting
    end

    def all_ancestors(object)
        return [] if direct_orbits(object) == 0

        ancestors = [@orbit_parent_hash[object]]
        while ancestors.last != nil
            ancestors.push(@orbit_parent_hash[ancestors.last])
        end
        ancestors
    end
end



def process_file(filename)
    orbit_graph = OrbitGraph.new
    File.read(filename).strip.split("\n").each do |line|
        line = line.split(")")
        orbit_graph.add_orbit_relationship(line[0], line[1])
    end
    orbit_graph
end

test_graph = process_file("day06-input-test.txt")
# p test_graph.total_orbits("D")
# p test_graph.total_orbits("L")
# p test_graph.total_orbits("COM")
# p test_graph.total_orbits_all_objects
# p test_graph.orbital_transfers_needed("YOU", "SAN")

real_graph = process_file("day06-input.txt")
p real_graph.total_orbits_all_objects
p real_graph.orbital_transfers_needed("YOU", "SAN")
