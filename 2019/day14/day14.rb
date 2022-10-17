class Rule
    attr_reader :result, :reqs

    def initialize(reqs, result)
        @result = result
        @reqs = reqs
    end

    def result_chemical
        @result.keys[0]
    end

    def result_number
        @result.values[0]
    end

    def to_s
        result = ""
        @reqs.each do |chemical, num|
            result += "#{num} #{chemical}, "
        end
        result = result[0..-3]
        result += " => #{result_number} #{result_chemical}"
        result
    end

    def applicable?(inputs)
        @reqs.each do |chemical, num|
            if not inputs.key? chemical
                return false
            elsif inputs[chemical] < num
                return false
            end
        end
        true
    end

    def apply(inputs) # returns what is left for a single application (no multiples)
        return unless applicable?(inputs)

        reqs.each do |chemical, num|
            inputs[chemical] -= num
        end

        inputs[result_chemical] += result_number
    end
end

######################################

class Nanofactory
    def initialize(rules_hash)
        @rules_hash = rules_hash
    end

    def work_forward_from_ore
        #inspired by https://github.com/Yardboy/advent-of-code/blob/master/2019/puzzle14b/solution.rb
        (1..1000000000000).bsearch do |ore|
            work_back_from_fuel(ore) > 1000000000000
        end - 1
    end

    def work_back_from_fuel(fuel_amount=1)
        chemical_pool = Hash.new(0)
        chemical_pool[:FUEL] = fuel_amount

        loop do
            prev_chemical_pool = chemical_pool.dup

            prev_chemical_pool.each do |current_chemical, current_number|
                next if current_chemical == :ORE

                rule = @rules_hash[current_chemical]
                multiple = (current_number.to_f / rule.result_number).ceil

                chemical_pool[current_chemical] -= rule.result_number * multiple

                rule.reqs.each do |new_chemical, new_number|
                    chemical_pool[new_chemical] += multiple*new_number
                end
            end

            break if prev_chemical_pool == chemical_pool
        end

        chemical_pool[:ORE]
    end
end

######################################

def process_file(filename)
    rules = {}
    File.read(filename).strip.split("\n").each do |rule_string|
        reqs_and_output = rule_string.split(" => ")
        
        reqs = {}
        reqs_and_output[0].split(",").each do |req|
            req_split = req.split(" ")
            reqs[req_split[1].to_sym] = req_split[0].to_i
        end

        output_split = reqs_and_output[1].split(" ")
        result_hash = {output_split[1].to_sym => output_split[0].to_i}

        new_rule = Rule.new(reqs, result_hash)
        rules[new_rule.result_chemical] = new_rule
    end
    rules
end

########################################

rules = process_file("day14-input.txt")
factory = Nanofactory.new(rules)
p factory.work_back_from_fuel
p factory.work_forward_from_ore