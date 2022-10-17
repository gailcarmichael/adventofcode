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

    # def applicable?(inputs)
    #     @reqs.each do |chemical, num|
    #         if not inputs.key? chemical
    #             return false
    #         elsif inputs[chemical] < num
    #             return false
    #         end
    #     end
    #     true
    # end

    # def apply(inputs) # returns what is left for a single application (no multiples)
    #     return unless applicable?(inputs)

    #     reqs.each do |chemical, num|
    #         inputs[chemical] -= num
    #     end

    #     inputs[result_chemical] += result_number
    # end
end

######################################

class Nanofactory
    def initialize(rules_hash)
        @rules_hash = rules_hash
    end

    def work_back_from_fuel
        extras = Hash.new(0)
        
        # how_much_ore(:FUEL, 1, extras) - how_much_less_ore_from_extras(extras)

        ore_amount = how_much_ore(:FUEL, 1, extras)
        
        extra_ore_amount = 0
        loop do
            prev_extras = extras.dup
            
            extras.each do |chem, num|
                extra_ore_amount += how_much_ore(chem, num, extras)
            end

            puts "extra_ore_amount=#{extra_ore_amount} extras=#{extras.inspect}"
            
            break if prev_extras == extras
        end

        ore_amount - extra_ore_amount
    end

    private 

    def how_much_ore(current_chemical, current_number, extras=nil)
        rule = @rules_hash[current_chemical]
        multiple = (current_number.to_f / rule.result_number).ceil
        extras[current_chemical] += (multiple * rule.result_number) - current_number if extras

        ore_amount = 0
        rule.reqs.each do |new_chemical, new_number|
            # puts "current=#{current_chemical}(#{current_number})\tnew=#{new_chemical}(#{new_number})\tmultiple=#{multiple}"
            if new_chemical == :ORE
                ore_amount += multiple * new_number
            else
                # ore_amount += how_much_ore(new_chemical, multiple*new_number + extras[new_chemical], extras)
                # extras[current_chemical] = 0

                ore_amount += how_much_ore(new_chemical, multiple*new_number, extras)
            end
        end
        ore_amount
    end

    def how_much_less_ore_from_extras(extras)
        p extras
        how_much_less_ore = 0
        extras.each do |chemical, number|
            rule = @rules_hash[chemical]
            if (rule.reqs.key? :ORE)
                how_much_less_ore += (number / rule.result_number) * rule.reqs[:ORE]
            end
        end
        puts "#{how_much_less_ore} less ore needed"
        how_much_less_ore
    end

    # def how_much_less_ore_from_extras(extras)
    #     p extras
    #     how_much_less_ore = 0
    #     extras.each do |chemical, number|
    #         how_much_less_ore += how_much_ore(chemical, number)
    #     end
    #     how_much_less_ore
    # end
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

rules = process_file("day14-input-test1.txt")
factory = Nanofactory.new(rules)
p factory.work_back_from_fuel