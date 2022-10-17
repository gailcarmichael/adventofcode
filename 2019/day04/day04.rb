def check_password_validity(password)
	digits = password.to_s.split('').map{|d| d.to_i}

	double_digits = decreasing = false
	0.upto(4).each do |index|
		double_digits = true if digits[index] == digits[index+1]
		decreasing = true if digits[index] > digits[index+1]
	end

	return double_digits && !decreasing
end


def check_password_validity_2(password)
	digits = password.to_s.split('').map{|d| d.to_i}

	num_repeated_so_far = 0
	digit_repeating = digits[0]
	found_exact_double = false
	decreasing = false

	1.upto(5).each do |index|
		if digits[index] == digit_repeating
			num_repeated_so_far += 1
			found_exact_double=true if index==5 && num_repeated_so_far == 1
		else
			found_exact_double=true if num_repeated_so_far == 1

			digit_repeating = digits[index]
			num_repeated_so_far = 0
		end
	end

	0.upto(4).each do |index|
		decreasing = true if digits[index] > digits[index+1]
	end

	return found_exact_double && !decreasing
	
end


valid_count = 0
130254.upto(678275) do |password|
	valid_count += 1 if check_password_validity(password)
end

puts "Part 1: There are #{valid_count} valid passwords in range."


valid_count = 0
130254.upto(678275) do |password|
	valid_count += 1 if check_password_validity_2(password)
end

puts "Part 2: There are #{valid_count} valid passwords in range."